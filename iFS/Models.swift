//
//  Models.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

import RealmSwift

extension FsManager {

    public class Models: NSObject {

        public static let shared: Models = Models()

        public var serviceDirName = "Services"

        private override init() {}

        public func clearCache() {
            DispatchQueue.global(qos: .background).async {
                var isDir: ObjCBool = false

                guard
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
                    let servicePath = URL(string: path)?.appendingPathComponent(self.serviceDirName),
                    FileManager.default.fileExists(atPath: servicePath.absoluteString, isDirectory: &isDir)
                    else {
                        return
                }

                do {
                    try FileManager.default.removeItem(atPath: servicePath.absoluteString)

                } catch {}
            }
        }

        public func toCache(_ serviceName: String,
                            _ fileContent: Data) {
            DispatchQueue.global(qos: .utility).async {
                guard
                    !serviceName.isEmpty,
                    let path = try? FileManager.default.url(for: .documentDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true),
                    let servicePath = path.appendingPathComponent(self.serviceDirName) as URL? else {
                        return
                }

                do {
                    try FileManager.default.createDirectory(atPath: servicePath.path,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)

                } catch {}

                guard let filePath = servicePath.appendingPathComponent(serviceName
                    .replace("/", withString: "_"))
                    .appendingPathExtension("json") as URL? else {
                    return
                }

                do {
                    try fileContent.write(to: filePath, options: [])

                } catch {
                    return
                }
            }
        }

        public func fromCache(_ serviceName: String) -> JSON {
            guard
                !serviceName.isEmpty,
                let path = try? FileManager.default.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true),
                let servicePath = path.appendingPathComponent(self.serviceDirName) as URL?
                else {
                    return JSON.null
            }

            do {
                try FileManager.default.createDirectory(atPath: servicePath.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)

            } catch {
                return JSON.null
            }

            guard
                let filePath = servicePath.appendingPathComponent(serviceName
                    .replace("/", withString: "_"))
                    .appendingPathExtension("json") as URL?,
                let content = try? String(contentsOf: filePath, encoding: .utf8),
                let data = content.data(using: .utf8),
                let json = try? JSON(data: data)
                else {
                    return JSON.null
            }

            return json
        }

        public func toFile<T: Codable>(_ fileName: String,
                                       _ model: T) {
            DispatchQueue.global(qos: .background).async {
                guard
                    let data = self.toData(model),
                    let path = try? FileManager.default.url(for: .documentDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true),
                    let servicePath = path.appendingPathComponent(self.serviceDirName) as URL? else {
                        return
                }

                do {
                    try FileManager.default.createDirectory(atPath: servicePath.path,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)

                } catch {
                    return
                }

                guard let filePath = servicePath.appendingPathComponent(fileName
                    .replace("/", withString: "_"))
                    .appendingPathExtension("json") as URL? else {
                    return
                }

                do {
                    try data.write(to: filePath, options: [])

                } catch {
                    return
                }
            }
        }

        public func fromFile<T: Codable>(_ fileName: String,
                                         _ model: T) -> T? {
            guard
                fileName.isEmpty,
                let path = try? FileManager.default.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true),
                let servicePath = path.appendingPathComponent(self.serviceDirName) as URL?
                else {
                    return nil
            }

            do {
                try FileManager.default.createDirectory(atPath: servicePath.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)

            } catch {
                return nil
            }

            guard
                let filePath = servicePath.appendingPathComponent(fileName
                    .replace("/", withString: "_"))
                    .appendingPathExtension("json") as URL?,
                let content = try? String(contentsOf: filePath, encoding: .utf8),
                let data = content.data(using: .utf8),
                let json = try? JSON(data: data),
                let decoded = decode(json) as T?
                else {
                    return nil
            }

            return decoded
        }

        public func toData<T: Codable>(_ model: T) -> Data? {
            guard let data = try? JSONEncoder().encode(model) else {
                return nil
            }

            return data
        }

        public func toJSON<T: Codable>(_ model: T) -> JSON? {
            guard
                let data = toData(model),
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
                else {
                    return nil
            }

            let result = JSON(jsonData)

            guard result != JSON.null else {
                return nil
            }

            return result
        }

        public func toString<T: Codable>(_ model: T) -> String? {
            guard
                let data = toData(model),
                let result = String(data: data, encoding: .utf8)
                else {
                    return nil
            }

            return result
        }

        public func decode<T: Codable>(_ json: JSON,
                                       toRealm: Bool = false,
                                       toRealmUpdate: Bool = false) -> T? {
            guard
                let data = try? json.rawData(),
                let result = try? JSONDecoder().decode(T.self, from: data)
                else {
                    var error = "Error: \(Types.ErrorLevels.jsonParse) "
                    error += "/ \(Types.ErrorLevels.jsonDecoder)"
                    FsManager.shared.debug(error)
                    return nil
            }

            if toRealm {
                RealmManager.shared.save(nil,
                                         content: result,
                                         type: .realmObject,
                                         isUpdate: toRealmUpdate)
            }

            return result
        }

        public func decodeArray<T: Codable>(_ json: JSON,
                                            toRealm: Bool = false,
                                            toRealmUpdate: Bool = false) -> [T]? {
            guard
                let data = try? json.rawData(),
                let result = try? JSONDecoder().decode([T].self, from: data)
                else {
                    var error = "Error: \(Types.ErrorLevels.jsonParseArray) "
                    error += "/ \(Types.ErrorLevels.jsonDecoder)"
                    FsManager.shared.debug(error)
                    return nil
            }

            if toRealm {
                RealmManager.shared.save(nil,
                                         content: result,
                                         type: .realmObjectArray,
                                         isUpdate: toRealmUpdate)
            }

            return result
        }
    }

}
