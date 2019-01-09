//
//  iFS.swift
//
//  Created by Francesco Sorrentino on 21/10/16.
//  Copyright © 2016 Francesco Sorrentino. All rights reserved.
//

import Foundation

public class FsManager: NSObject {

    public static let shared: FsManager = FsManager()

    private override init() {}

    public func debug(_ msg: String,
                      functionName: String = #function,
                      fileName: String = #file,
                      lineNumber: Int = #line) {
        let fileName = (fileName as NSString).lastPathComponent
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        let stringError = "[\(date)]\n\(fileName)->\(functionName) [#\(lineNumber)]: \(msg)\r\n"

        if Resources.isDebugMode {
            print(stringError)
        }

        if Resources.isLoggingMode {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let fileUrl = URL(string: path)!.appendingPathComponent(Resources.logFileName).absoluteString
            do {
                let url = URL(fileURLWithPath: fileUrl)
                try stringError.appendLineToURL(url)
            } catch {}
        }
    }

    /// Return string version
    public func version() -> String {
        var mainVersion = "0.0.0"

        if let infoDictionary = Bundle.main.infoDictionary {
            if let main = infoDictionary["CFBundleShortVersionString"] as? String {
                mainVersion = main
            }
        }

        return mainVersion
    }

    /// Return integer version
    public func version() -> Int {
        guard
            let returnVersion = Int(version().replace(".", withString: ""))
            else {
                return 0
        }
        return returnVersion
    }

    /// Return full string version
    public func versionVerbose() -> String {
        var mainVersion = "0.0.0"
        var buildVersion = "0"

        if let infoDictionary = Bundle.main.infoDictionary {
            if let main = infoDictionary["CFBundleShortVersionString"] as? String {
                mainVersion = main
            }

            if let build = infoDictionary["CFBundleVersion"] as? String {
                buildVersion = build
            }
        }

        return mainVersion + "(" + buildVersion + ")"
    }

    /// Return full integer version
    public func getFullVersion() -> Int {
        let version = versionVerbose()
            .replace(".", withString: "")
            .replace("(", withString: "")
            .replace(")", withString: "")

        guard
            let returnVersion = Int(version)
            else {
                return 0
        }

        return returnVersion
    }
}
