//
//  Device.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

import AdSupport
import UIKit

extension FsManager {

    public class Device: NSObject {

        private override init() {}

        public static let shared: Device = Device()

        public class var iOSVersion: Int {
            guard
                let version = Int(String(Array(UIDevice.current.systemVersion)[0]))
                else {
                    return 0
            }
            return version
        }

        public class var uniqueID: String {
            guard
                let idForVendor = UIDevice.current.identifierForVendor
                else {
                    return ""
            }
            return idForVendor.uuidString
        }

        public class var idFa: String {
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return ""
            }
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }

        public class var model: String {
            return UIDevice.current.model
        }

        /// Return informations about device
        public func info() -> InfoResult {
            var type = Types.DeviceTypes.real
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)

            var identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }

            if let simulatorModel = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                type = Types.DeviceTypes.simulator
                identifier = simulatorModel
            }

            let identifiers: [String: InfoResult] = [
                 //---iPhone---
                "iPhone1,1": (type, .iPhone, .iPhone, "iPhone 1G", 3.5),
                "iPhone1,2": (type, .iPhone, .iPhone3G, "iPhone 3G", 3.5),
                "iPhone2,1": (type, .iPhone, .iPhone3GS, "iPhone 3Gs", 3.5),
                "iPhone3,1": (type, .iPhone, .iPhone4, "iPhone 4 (Gsm)", 3.5),
                "iPhone3,2": (type, .iPhone, .iPhone4, "iPhone 4 (Gsm Rev. A)", 3.5),
                "iPhone3,3": (type, .iPhone, .iPhone4, "iPhone 4 (Cdma)", 3.5),
                "iPhone4,1": (type, .iPhone, .iPhone4S, "iPhone 4S", 3.5),
                "iPhone5,1": (type, .iPhone, .iPhone5, "iPhone 5 (Gsm)", 4),
                "iPhone5,2": (type, .iPhone, .iPhone5, "iPhone 5 (Global)", 4),
                "iPhone5,3": (type, .iPhone, .iPhone5C, "iPhone 5C (Gsm)", 4),
                "iPhone5,4": (type, .iPhone, .iPhone5C, "iPhone 5C (Global)", 4),
                "iPhone6,1": (type, .iPhone, .iPhone5S, "iPhone 5S (Gsm)", 4),
                "iPhone6,2": (type, .iPhone, .iPhone5S, "iPhone 5S (Global)", 4),
                "iPhone7,1": (type, .iPhone, .iPhone6Plus, "iPhone 6 Plus", 5.5),
                "iPhone7,2": (type, .iPhone, .iPhone6, "iPhone 6", 4.7),
                "iPhone8,1": (type, .iPhone, .iPhone6S, "iPhone 6S", 4.7),
                "iPhone8,2": (type, .iPhone, .iPhone6SPlus, "iPhone 6S Plus", 5.5),
                "iPhone8,4": (type, .iPhone, .iPhoneSE, "iPhone Se", 4),
                "iPhone9,1": (type, .iPhone, .iPhone7, "iPhone 7", 4.7),
                "iPhone9,2": (type, .iPhone, .iPhone7Plus, "iPhone 7 Plus", 5.5),
                "iPhone9,3": (type, .iPhone, .iPhone7, "iPhone 7", 4.7),
                "iPhone9,4": (type, .iPhone, .iPhone7Plus, "iPhone 7 Plus", 5.5),
                "iPhone10,1": (type, .iPhone, .iPhone8, "iPhone 8", 4.7),  //---US (Verizon), China, Japan---
                "iPhone10,2": (type, .iPhone, .iPhone8Plus, "iPhone 8 Plus", 5.5), //---US (Verizon), China, Japan---
                "iPhone10,3": (type, .iPhone, .iPhoneX, "iPhone X", 5.8), //---US (Verizon), China, Japan---
                "iPhone10,4": (type, .iPhone, .iPhone8, "iPhone 8", 4.7), //---AT&T, Global---
                "iPhone10,5": (type, .iPhone, .iPhone8Plus, "iPhone 8 Plus", 5.5), //---AT&T, Global---
                "iPhone10,6": (type, .iPhone, .iPhoneX, "iPhone X", 5.8), //---AT&T, Global---
                "iPhone11,2": (type, .iPhone, .iPhoneXS, "iPhone Xs", 5.8),
                "iPhone11,4": (type, .iPhone, .iPhoneXSMax, "iPhone Xs Max", 6.5),
                "iPhone11,6": (type, .iPhone, .iPhoneXSMax, "iPhone Xs Max", 6.5),
                "iPhone11,8": (type, .iPhone, .iPhoneXR, "iPhone Xr", 6.1),
                "iPhone12,1": (type, .iPhone, .iPhone11, "iPhone 11", 6.1),
                "iPhone12,3": (type, .iPhone, .iPhone11Pro, "iPhone 11 Pro", 5.8),
                "iPhone12,5": (type, .iPhone, .iPhone11ProMax, "iPhone 11 Pro Max", 6.5),

                //---iPad---
                "iPad1,1": (type, .iPad, .iPad, "iPad 1G", 9.7),
                "iPad2,1": (type, .iPad, .iPad2, "iPad 2 (Wi-Fi)", 97),
                "iPad2,2": (type, .iPad, .iPad2, "iPad 2 (Gsm)", 9.7),
                "iPad2,3": (type, .iPad, .iPad2, "iPad 2 (Cdma)", 9.7),
                "iPad2,4": (type, .iPad, .iPad2, "iPad 2 (Rev. A)", 9.7),
                "iPad2,5": (type, .iPad, .iPadMini, "iPad Mini 1G (Wi-Fi)", 7.9),
                "iPad2,6": (type, .iPad, .iPadMini, "iPad Mini 1G (Gsm)", 7.9),
                "iPad2,7": (type, .iPad, .iPadMini, "iPad Mini 1G (Global)", 7.9),
                "iPad3,1": (type, .iPad, .iPad3, "iPad 3 (Wi-Fi)", 9.7),
                "iPad3,2": (type, .iPad, .iPad3, "iPad 3 (Gsm)", 9.7),
                "iPad3,3": (type, .iPad, .iPad3, "iPad 3 (Global)", 9.7),
                "iPad3,4": (type, .iPad, .iPad4, "iPad 4 (Wi-Fi)", 9.7),
                "iPad3,5": (type, .iPad, .iPad4, "iPad 4 (Gsm)", 9.7),
                "iPad3,6": (type, .iPad, .iPad4, "iPad 4 (Global)", 9.7),
                "iPad4,1": (type, .iPad, .iPadAir, "iPad Air (Wi-Fi)", 9.7),
                "iPad4,2": (type, .iPad, .iPadAir, "iPad Air (Cellular)", 9.7),
                "iPad4,4": (type, .iPad, .iPadMini2, "iPad Mini (2th gen.) (Wi-Fi)", 7.9),
                "iPad4,5": (type, .iPad, .iPadMini2, "iPad Mini (2th gen.) (Cellular)", 7.9),
                "iPad4,6": (type, .iPad, .iPadMini2, "iPad Mini (2th gen.) (Cellular Lte)", 7.9),
                "iPad4,7": (type, .iPad, .iPadMini3, "iPad Mini (3th gen.) (Wi-Fi)", 7.9),
                "iPad4,8": (type, .iPad, .iPadMini3, "iPad Mini (3th gen.) (Cellular)", 7.9),
                "iPad4,9": (type, .iPad, .iPadMini3, "iPad Mini (3th gen.) (Cellular)", 7.9),
                "iPad5,1": (type, .iPad, .iPadMini4, "iPad Mini (4th gen.) (Wi-Fi)", 7.9),
                "iPad5,2": (type, .iPad, .iPadMini4, "iPad Mini (4th gen.) (Cellular)", 7.9),
                "iPad5,3": (type, .iPad, .iPadAir2, "iPad Air 2 (Wi-Fi)", 9.7),
                "iPad5,4": (type, .iPad, .iPadAir2, "iPad Air 2 (Cellular)", 9.7),
                "iPad6,3": (type, .iPad, .iPadPro97, "iPad Pro (9.7\") (Wi-Fi)", 9.7),
                "iPad6,4": (type, .iPad, .iPadPro97, "iPad Pro (9.7\") (Cellular)", 9.7),
                "iPad6,7": (type, .iPad, .iPadPro129, "iPad Pro (12.9\") (Wi-Fi)", 12.9),
                "iPad6,8": (type, .iPad, .iPadPro129, "iPad Pro (12.9\") (Cellular)", 12.9),
                "iPad6,11": (type, .iPad, .iPad5Th, "iPad (5th gen.) (Wi-Fi)", 9.7),
                "iPad6,12": (type, .iPad, .iPad5Th, "iPad (5th gen.) (Cellular)", 9.7),
                "iPad7,1": (type, .iPad, .iPadPro2129, "iPad Pro (2th gen.) (12.9\") (Wi-Fi)", 12.9),
                "iPad7,2": (type, .iPad, .iPadPro2129, "iPad Pro (2th gen.) (12.9\") (Cellular)", 12.9),
                "iPad7,3": (type, .iPad, .iPadPro105, "iPad Pro (10.5\") (Wi-Fi)", 10.5),
                "iPad7,4": (type, .iPad, .iPadPro105, "iPad Pro (10.5\") (Cellular)", 10.5),
                "iPad7,5": (type, .iPad, .iPad6Th, "iPad (6th gen.) (Wi-Fi)", 9.7),
                "iPad7,6": (type, .iPad, .iPad6Th, "iPad (6th gen.) (Cellular)", 9.7),
                "iPad8,1": (type, .iPad, .iPadPro11, "iPad Pro (11\") (Cellular)", 9.7),
                "iPad8,2": (type, .iPad, .iPadPro11, "iPad Pro (11\") (Wi-Fi, 1TB)", 9.7),
                "iPad8,3": (type, .iPad, .iPadPro11, "iPad Pro (11\") (Cellular)", 9.7),
                "iPad8,4": (type, .iPad, .iPadPro11, "iPad Pro (11\") (Cellular, 1TB)", 9.7),
                "iPad8,5": (type, .iPad, .iPadPro3129, "iPad Pro (3th gen.) (12.9\") (Cellular)", 12.9),
                "iPad8,6": (type, .iPad, .iPadPro3129, "iPad Pro (3th gen.) (12.9\") (Wi-Fi, 1TB)", 12.9),
                "iPad8,7": (type, .iPad, .iPadPro3129, "iPad Pro (3th gen.) (12.9\") (Cellular)", 12.9),
                "iPad8,8": (type, .iPad, .iPadPro3129, "iPad Pro (3th gen.) (12.9\") (Cellular, 1TB)", 12.9),
                "iPad11,3": (type, .iPad, .iPadAir3, "iPad Air (3th gen.) (10.5\") (Wi-Fi)", 10.5),
                "iPad11,4": (type, .iPad, .iPadAir3, "iPad Air (3th gen.) (10.5\") (Cellular)", 10.5),

                //---iPod---
                "iPod1,1": (type, .iPod, .iPodTouch, "iPod touch", 0.0),
                "iPod2,1": (type, .iPod, .iPodTouch2, "iPod touch (2th gen.)", 0.0),
                "iPod3,1": (type, .iPod, .iPodTouch3, "iPod touch (3th gen.)", 0.0),
                "iPod4,1": (type, .iPod, .iPodTouch4, "iPod touch (4th gen.)", 0.0),
                "iPod5,1": (type, .iPod, .iPodTouch5, "iPod touch (5th gen.)", 0.0),
                "iPod7,1": (type, .iPod, .iPodTouch6, "iPod touch (6th gen.)", 0.0), //---iPod6,1 never released---

                //---Apple tv---
                "AppleTV1,1": (type, .appleTv, .appleTv, "Apple TV", 0.0),
                "AppleTV2,1": (type, .appleTv, .appleTv2, "Apple TV (2th gen.)", 0.0),
                "AppleTV3,1": (type, .appleTv, .appleTv3, "Apple TV (3th gen.)", 0.0),
                "AppleTV3,2": (type, .appleTv, .appleTv3, "Apple TV (3th gen.)", 0.0),
                "AppleTV5,2": (type, .appleTv, .appleTv4, "Apple TV (4th gen.)", 0.0),
                "AppleTV5,3": (type, .appleTv, .appleTv4, "Apple TV (4th gen.)", 0.0),
                "AppleTV6,2": (type, .appleTv, .appleTv4K, "Apple TV 4K", 0.0),

                //---Apple Watch---
                "Watch1,1": (type, .appleWatch, .appleWatch, "Apple Watch", 0.0),
                "Watch1,2": (type, .appleWatch, .appleWatch, "Apple Watch", 0.0),
                "Watch2,6": (type, .appleWatch, .appleWatch1, "Apple Watch Series 1", 0.0),
                "Watch2,7": (type, .appleWatch, .appleWatch1, "Apple Watch Series 1", 0.0),
                "Watch2,3": (type, .appleWatch, .appleWatch2, "Apple Watch Series 2", 0.0),
                "Watch2,4": (type, .appleWatch, .appleWatch2, "Apple Watch Series 2", 0.0),
                "Watch3,1": (type, .appleWatch, .appleWatch3, "Apple Watch Series 3", 0.0),
                "Watch3,2": (type, .appleWatch, .appleWatch3, "Apple Watch Series 3", 0.0),
                "Watch3,3": (type, .appleWatch, .appleWatch3, "Apple Watch Series 3", 0.0),
                "Watch3,4": (type, .appleWatch, .appleWatch3, "Apple Watch Series 3", 0.0),
                "Watch4,1": (type, .appleWatch, .appleWatch4, "Apple Watch Series 4", 0.0),
                "Watch4,2": (type, .appleWatch, .appleWatch4, "Apple Watch Series 4", 0.0),
                "Watch4,3": (type, .appleWatch, .appleWatch4, "Apple Watch Series 4", 0.0),
                "Watch4,4": (type, .appleWatch, .appleWatch4, "Apple Watch Series 4", 0.0),

                //---HomePod---
                "AudioAccessory1,1": (type, .homePod, .homePod, "HomePod", 0.0),

                //---Simulator---
                "i386": (type, .simulator, .simulator, "Simulator", 0.0),
                "x86_64": (type, .simulator, .simulator, "Simulator", 0.0)
            ]

            guard let result = identifiers[identifier] else {
                return (.undefined, .undefined, .undefined, "Unknow", 0)
            }

            return result
        }
    }
}
