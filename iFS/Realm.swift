//
//  Realm.swift
//  iFS
//
//  Created by Francesco Sorrentino on 08/10/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

extension FsManager {

    public class RealmManager: NSObject {

        public static let shared: RealmManager = RealmManager()

        private override init() {}

        private let schemaVersion: UInt64 = 0

        private var configuration: Realm.Configuration {
            return Realm.Configuration(schemaVersion: schemaVersion,
                                       deleteRealmIfMigrationNeeded: true)
        }

        private var connection: Realm? {
            guard let realm = try? Realm() else {
                FsManager.shared.debug("Error: \(Types.ErrorLevels.noRealmConnection)")
                return nil
            }

            return realm
        }

        public func get() -> Realm? {
            Realm.Configuration.defaultConfiguration = configuration

            guard
                let realm = connection
                else {
                    FsManager.shared.debug("Error: \(Types.ErrorLevels.noRealmConnection)")
                    return nil
            }

            realm.autorefresh = true
            return realm
        }

        public func delete(_ realmObject: Object.Type,
                           content: Any? = nil,
                           pkValueForDelete: Any? = nil,
                           type: Types.RealmSaveTypes = .json,
                           completion: @escaping (Types.ErrorLevels) -> Void = { _ in }) {
            DispatchQueue.global(qos: .background).async {
                guard
                    let realm = self.get()
                    else {
                        FsManager.shared.debug("Error: \(Types.ErrorLevels.noRealmConnection)")
                        completion(.noRealmConnection)
                        return
                }

                if content != nil {
                    switch type {
                    case .jsonArray:
                        FsManager.shared.debug("Error: \(Types.ErrorLevels.notAvailable)")
                        completion(.notAvailable)
                        return

                    default: //---Delete from primary key into JSON object---
                        guard
                            let primaryKey = realmObject.primaryKey()
                            else {
                                FsManager.shared.debug("Error: \(Types.ErrorLevels.noPrimaryKeyDefined)")
                                completion(.noPrimaryKeyDefined)
                                return
                        }

                        guard
                            let json = content as? JSON
                            else {
                                FsManager.shared.debug("Error: \(Types.ErrorLevels.jsonParse)")
                                completion(.jsonParse)
                                return
                        }

                        guard
                            let realmObjectToDelete = realm.objects(realmObject)
                                .filter("\(primaryKey) = %@", json["\(primaryKey)"]).first
                            else {
                                FsManager.shared.debug("Error: \(Types.ErrorLevels.realmObjectToDeleteNotFound)")
                                completion(.realmObjectToDeleteNotFound)
                                return
                        }

                        realm.beginWrite()
                        realm.delete(realmObjectToDelete)
                    }

                } else if pkValueForDelete != nil { //---Delete from primary Key---
                    guard
                        let primaryKey = realmObject.primaryKey()
                        else {
                            FsManager.shared.debug("Error: \(Types.ErrorLevels.noPrimaryKeyDefined)")
                            completion(.noPrimaryKeyDefined)
                            return
                    }

                    guard
                        let realmObjectToDelete = realm.objects(realmObject)
                            .filter("\(primaryKey) = %@", pkValueForDelete!).first
                        else {
                            FsManager.shared.debug("Error: \(Types.ErrorLevels.realmObjectToDeleteNotFound)")
                            completion(.realmObjectToDeleteNotFound)
                            return
                    }

                    realm.beginWrite()
                    realm.delete(realmObjectToDelete)

                } else { //---All object content---
                    let realmObjectToDelete = realm.objects(realmObject)
                    realm.beginWrite()
                    realm.delete(realmObjectToDelete)
                }

                do {
                    try realm.commitWrite()
                    completion(.realmTransactionSuccess)

                } catch {
                    FsManager.shared.debug("Error: \(Types.ErrorLevels.realmTransactionFailure)")
                    realm.cancelWrite()
                    completion(.realmTransactionFailure)
                }
            }
        }

        public func save(_ realmObject: Object.Type?,
                         content: Any,
                         type: Types.RealmSaveTypes = .json,
                         isUpdate: Bool = false,
                         deleteBeforeInsert: Bool = false,
                         pkValueForDelete: Any? = nil,
                         completion: @escaping (Types.ErrorLevels) -> Void = { _ in }) {
            DispatchQueue.global(qos: .background).async {
                autoreleasepool {
                    guard
                        let realm = self.get()
                        else {
                            FsManager.shared.debug("Error: \(Types.ErrorLevels.noRealmConnection)")
                            completion(.noRealmConnection)
                            return
                    }

                    do {
                        try realm.write {
                            //---Delete first option---
                            if deleteBeforeInsert && realmObject != nil {
                                let realmObjectToDelete = realm.objects(realmObject!)
                                realm.delete(realmObjectToDelete)
                            }
                            //---*---

                            switch type {
                            case .realmObject:
                                guard
                                    let realmContent = content as? Object
                                    else {
                                        FsManager.shared.debug("Error: \(Types.ErrorLevels.realmParseObject)")
                                        completion(.realmParseObject)
                                        return
                                }

                                if realmObject != nil {
                                    realm.create(realmObject!, value: realmContent, update: .all)

                                } else {
                                    if isUpdate {
                                        realm.add(realmContent, update: .all)

                                    } else {
                                        realm.add(realmContent)
                                    }

                                }

                            case .realmObjectArray:
                                guard
                                    let realmObjects = content as? [Object]
                                    else {
                                        FsManager.shared.debug("Error: \(Types.ErrorLevels.realmParseObjectArray)")
                                        completion(.realmParseObjectArray)
                                        return
                                }

                                guard
                                    realmObjects.count > 0
                                    else {
                                        FsManager.shared.debug("Error: \(Types.ErrorLevels.realmParseObjectArrayEmpty)")
                                        completion(.realmParseObjectArrayEmpty)
                                        return
                                }

                                realmObjects.forEach({ (realmObject) in
                                    if isUpdate {
                                        realm.add(realmObject, update: .all)

                                    } else {
                                        realm.add(realmObject)
                                    }
                                })

                            case .jsonArray:
                                guard realmObject != nil
                                    else {
                                        FsManager.shared.debug("Error: \(Types.ErrorLevels.realmObjectNotDefined)")
                                        completion(.realmObjectNotDefined)
                                        return
                                }

                                guard
                                    let jsons = content as? JSON
                                    else {
                                        FsManager.shared.debug("Error: \(Types.ErrorLevels.jsonParse)")
                                        completion(.jsonParse)
                                        return
                                }

                                guard
                                    jsons.arrayValue.count > 0
                                    else {
                                        FsManager.shared.debug("Error: \(Types.ErrorLevels.jsonParseArrayEmpty)")
                                        completion(.jsonParseArrayEmpty)
                                        return
                                }

                                jsons.arrayValue.forEach({ (json) in
                                    guard
                                        let jData = try? json.rawData(),
                                        let jRealm = try? JSONSerialization.jsonObject(with: jData,
                                                                                       options: .mutableContainers)
                                        else {
                                            FsManager.shared.debug("Error: \(Types.ErrorLevels.jsonParseFromItemArray)")
                                            realm.cancelWrite()
                                            completion(.jsonParseFromItemArray)
                                            return
                                    }

                                    if isUpdate {
                                        realm.create(realmObject!, value: jRealm, update: .all)

                                    } else {
                                        realm.create(realmObject!, value: jRealm)
                                    }
                                })

                            default:
                                guard realmObject != nil
                                    else {
                                        FsManager.shared.debug("Error: \(Types.ErrorLevels.realmObjectNotDefined)")
                                        completion(.realmObjectNotDefined)
                                        return
                                }

                                guard
                                    let json = content as? JSON,
                                    let jData = try? json.rawData(),
                                    let jRealm = try? JSONSerialization.jsonObject(with: jData,
                                                                                   options: .mutableContainers)
                                    else {
                                        FsManager.shared.debug("Error: \(Types.ErrorLevels.jsonParse)")
                                        completion(.jsonParse)
                                        return
                                }

                                if isUpdate {
                                    realm.create(realmObject!, value: jRealm, update: .all)

                                } else {
                                    realm.create(realmObject!, value: jRealm)
                                }
                            }
                        }

                        completion(.realmTransactionSuccess)

                    } catch {
                        FsManager.shared.debug("Error: \(Types.ErrorLevels.realmTransactionFailure)")
                        completion(.realmTransactionFailure)
                    }
                }
            }
        }

        public func read<T: Object>(_ realmObject: Object.Type) -> Results<T>? {
            guard
                let realm = get(),
                let result = realm.objects(realmObject) as? Results<T>
            else {
                    return nil
            }

            return result
        }

    }

}
