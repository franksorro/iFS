//
//  Files.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

import Foundation
import SwiftyJSON

extension FsManager {

    public class Files: NSObject {

        public static let shared: Files = Files()

        private override init() {}

        public func getPath() -> String {
            guard
                let dirPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                        .userDomainMask,
                                                                        true).first,
                let dirPathUrl = URL(string: dirPathString),
                let dirPath = dirPathUrl.appendingPathComponent(Resources.filesFolderName, isDirectory: true) as URL?
                else {
                    return ""
            }

            return dirPath.absoluteString
        }

        public func list() -> [String] {
            guard let files = FileManager.default.enumerator(atPath: getPath()) else {
                return []
            }

            var filesInPath: [String] = []
            files.forEach({
                if let file = $0 as? String {
                    filesInPath.append(file)
                }
            })

            return filesInPath
        }

        public func read(_ fileName: String) -> String {
            let filePath = getPath().appendingPathComponent(fileName)
            guard
                let fileContent = try? NSString(contentsOfFile: filePath,
                                                encoding: String.Encoding.utf8.rawValue) as String
                else {
                    return ""
            }

            return fileContent
        }

        public func save(_ fileName: String, content: Any) {
            DispatchQueue.global(qos: .background).async {
                let filePath = self.getPath().appendingPathComponent(fileName)

                if !FileManager.default.fileExists(atPath: self.getPath()) {
                    try? FileManager.default.createDirectory(atPath: self.getPath(),
                                                             withIntermediateDirectories: false,
                                                             attributes: nil)
                }

                guard let data = try? JSON(content).rawData(options: []) else {
                    return
                }

                if !FileManager.default.fileExists(atPath: filePath) {
                    FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)

                } else {
                    if let fileData: FileHandle = FileHandle(forWritingAtPath: filePath) {
                        fileData.write(data)
                        fileData.closeFile()
                    }
                }
            }
        }

        public func delete(_ fileName: String) {
            DispatchQueue.global(qos: .background).async {
                let filePath = self.getPath().appendingPathComponent(fileName)

                if FileManager.default.fileExists(atPath: filePath) {
                    try? FileManager.default.removeItem(atPath: filePath)

                }
            }
        }

        public func clear(_ fileName: String) {
            DispatchQueue.global(qos: .background).async {
                if FileManager.default.fileExists(atPath: self.getPath()) {
                    try? FileManager.default.removeItem(atPath: self.getPath())
                }
            }
        }
    }
}
