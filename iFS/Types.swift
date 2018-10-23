//
//  Types.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

public typealias RestResult = ((
    _ success: Bool,
    _ result: AnyObject?,
    _ response: [AnyHashable: Any]?,
    _ errorLevel: Types.ErrorLevels,
    _ errorMsg: String) -> Void
)

public typealias InfoResult = ((
    type: Types.DeviceTypes,
    category: Types.DeviceCategories,
    model: Types.DeviceModels,
    modelName: String,
    displaySize: Double)
)

public typealias SideMenuResult = ((
    _ result: Bool) -> Void
)

public struct Types {

    public enum DeviceTypes {
        case real
        case simulator
        case undefined
    }

    public enum DeviceCategories {
        case iPhone
        case iPad
        case iPod
        case appleTv
        case simulator
        case undefined
    }

    public enum DeviceModels {
        case iPhone
        case iPhone3G
        case iPhone3GS
        case iPhone4
        case iPhone4S
        case iPhone5
        case iPhone5C
        case iPhone5S
        case iPhone6Plus
        case iPhone6
        case iPhone6S
        case iPhone6SPlus
        case iPhoneSE
        case iPhone7
        case iPhone7Plus
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        case iPhoneXS
        case iPhoneXSMax
        case iPhoneXR

        //---iPad---
        case iPad
        case iPad2
        case iPadMini
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPad3
        case iPad4
        case iPadAir
        case iPadAir2
        case iPadPro97
        case iPadPro129
        case iPadPro2129
        case iPadPro105
        case iPad5Th
        case iPad6Th

        case iPodTouch
        case iPodTouch2
        case iPodTouch3
        case iPodTouch4
        case iPodTouch5
        case iPodTouch6

        case appleTv
        case appleTv2
        case appleTv3
        case appleTv4
        case appleTv4K

        case simulator
        case undefined
    }

    public enum ErrorLevels: Int {
        case success
        case error
        case notAvailable

        case noConnection
        case noUrl
        case noRealmConnection
        case noDeleteKeyDefined
        case noPrimaryKeyDefined

        case jsonParse
        case jsonParseArray
        case jsonParseFromItemArray
        case jsonParseArrayEmpty
        case jsonDecoder

        case realmTransactionSuccess
        case realmTransactionFailure
        case realmObjectNotDefined
        case realmObjectToDeleteNotFound
        case realmParseObject
        case realmParseObjectArray
        case realmParseObjectArrayEmpty
    }

    public enum HttpMethods {
        case get
        case post
        case put
        case delete
    }

    public enum ContentTypes: String {
        case json = "application/json"
        case formUrlEncoded = "application/x-www-form-urlencoded"
    }

    public enum AcceptTypes: String {
        case json = "application/json"
    }

    public enum ApiEncoding {
        case json
        case string
        case data
    }

    public enum LocalStorageKeys {
        case int
        case double
        case float
        case data
        case string
        case bool
        case array
        case url
        case any
    }

    public enum InAppPurchaseResults: Int {
        case noTest = 0
        case valid = 1
        case expired = 2
        case refunded = 3

        public static func fromString(string: String) -> InAppPurchaseResults? {
            var index = 0
            while let item = InAppPurchaseResults(rawValue: index) {
                if String(describing: item) == string {
                    return item
                }
                index += 1
            }

            return nil
        }
    }

    public enum SideMenuDirections: Int {
        case left = 0
        case right = 1
        case top = 2
        case bottom = 3
    }

    public enum RealmSaveTypes {
        case json
        case jsonArray
        case realmObject
        case realmObjectArray
    }

}
