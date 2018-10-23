//
//  Resources.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

extension FsManager {

    public class Resources {

        //---Api---
        private static let kMegabyte: Int = 1024 * 1024
        public static var urlCachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad
        public static var urlCacheTimeoutInterval: TimeInterval = 20.0
        public static var urlCacheMemoryCapacity: Int = 1 * kMegabyte
        public static var urlCacheDiskCapacity: Int = 5 * kMegabyte
        public static var urlCacheDiskPath = "iFSApiCache"
        public static var urlCacheStoragePolicy = URLCache.StoragePolicy.allowed
        public static var urlCacheExpires = TimeInterval(30) //---Cache life---
        public static var urlConfigurationTimoutRequest = 20.0
        public static let urlCache = URLCache(memoryCapacity: urlCacheMemoryCapacity,
                                              diskCapacity: urlCacheDiskCapacity,
                                              diskPath: urlCacheDiskPath)
        //---*---

        //---Default font---
        public static var fontDefaultName = "Arial"
        public static var fontDefaultSize: CGFloat = 15.0

        public class var fontDefault: UIFont {
            guard
                let font = UIFont.init(name: fontDefaultName, size: fontDefaultSize)
                else {
                    return UIFont.systemFont(ofSize: fontDefaultSize)
            }

            return font
        }
        //---*---

        //---Toast---
        public static var toastDelay: TimeInterval = 5
        public static var toastTextColor = UIColor.white
        public static var toastBackgroundColor = UIColor.black.withAlphaComponent(0.5)
        public static var toastTextFont = fontDefault
        //---*---

        public static var filesFolderName = "Files" //---Default folder name for save data---

        //---If TRUE, write into debug console---
        public static var isDebugMode: Bool = false

        //---If TRUE, write debug into log file---
        public static var isLoggingMode: Bool = false

        public static var logFileName = "logServices.txt"  //---Default log file name---
        public static var imageFolderName = "Images" //---Default images folder name---

        public static var mainStoryboard = "Main" //---Default main storyboard name---

        //---Navigation bar---
        public static var navigationBarColor = UIColor.black
        public static var navigationBackColor = UIColor.white
        public static var navigationBackImageName = "ic_back"

        public class var navigationBackImage: UIImage {
            guard
                let backImage = UIImage(named: navigationBackImageName)?.withRenderingMode(.alwaysTemplate)
                else {
                    return UIImage()
            }

            return backImage
        }

        public class var navigationBarFont: UIFont {
            guard
                let font = UIFont.init(name: fontDefaultName, size: 16.0)
                else {
                return UIFont.systemFont(ofSize: 16.0)
            }

            return font
        }
        //---*---
    }

}
