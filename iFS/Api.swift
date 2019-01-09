//
//  Api.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

import Foundation

extension FsManager {

    public class Api: NSObject {

        public static let shared: Api = Api()

        private override init() {}

        private let kUrlCacheExpiresName = "iFSApiCacheExpires"

        private var urlSessionConfiguration: URLSessionConfiguration {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = Resources.urlConfigurationTimoutRequest
            configuration.urlCache = nil
            return configuration
        }

        private func addParams(_ params: Any?) -> Data? {
            guard
                params != nil,
                let jsonData = try? JSONSerialization.data(withJSONObject: params!, options: [])
                else {
                    FsManager.shared.debug("Error during parsing parameters to JSON")
                    return nil
            }

            return jsonData
        }

        private func getUrlRequest(url: URL, useCache: Bool) -> URLRequest {
            if useCache {
                return URLRequest(url: url,
                                     cachePolicy: Resources.urlCachePolicy,
                                     timeoutInterval: Resources.urlCacheTimeoutInterval)

            } else {
                return URLRequest(url: url)
            }
        }

        private func getCacheResponse(request: URLRequest,
                                      useCache: Bool) -> CachedURLResponse? {
            if useCache {
                return Resources.urlCache.cachedResponse(for: request)

            } else {
                Resources.urlCache.removeCachedResponse(for: request)
                return nil
            }
        }

        public func rest(_ stringUrl: String,
                         _ method: Types.HttpMethods = .get,
                         _ headers: [String: String] = [:],
                         _ params: Any? = nil,
                         _ apiEncoding: Types.ApiEncoding = .json,
                         _ useCache: Bool = false,
                         completion: @escaping RestResult) {
            DispatchQueue.global(qos: .background).async {
                guard
                    let url = URL(string: stringUrl) as URL?
                    else {
                        completion(false,
                                   nil,
                                   nil,
                                   .noUrl,
                                   "URL not valid")
                        return
                }

                var request = self.getUrlRequest(url: url, useCache: useCache)
                request.httpMethod = String(describing: method)

                if params != nil {
                    request.httpBody = self.addParams(params!)
                }

                headers.forEach({ (key, value) in
                    request.addValue(value, forHTTPHeaderField: key)
                })

                if let cacheResponse = self.getCacheResponse(request: request, useCache: useCache) {
                    guard
                        let apiData = try? JSONSerialization.jsonObject(with: cacheResponse.data, options: []),
                        let apiResponse = cacheResponse.response as? HTTPURLResponse
                        else {
                            completion(false,
                                       nil,
                                       nil,
                                       .error,
                                       "Error during parse cache data in JSON")
                            return
                    }

                    completion(true,
                               apiData as AnyObject?,
                               apiResponse.allHeaderFields,
                               .success,
                               "") //---Return cache data---

                } else {
                    let urlSession = URLSession(configuration: self.urlSessionConfiguration)
                    urlSession.dataTask(with: request, completionHandler: {(data, response, error) -> Void in

                        guard
                            error == nil,
                            let httpResponse = response as? HTTPURLResponse,
                            let receivedData = data
                            else {
                                let errorType: Types.ErrorLevels = error != nil ? .error : .noConnection
                                let errorMsg = error != nil ? "Response error in API rest call: \(error!)"
                                    : "HTTP/HTTPS response not valid: \(String(describing: response))"
                                completion(false,
                                           nil,
                                           nil,
                                           errorType,
                                           errorMsg)
                                return
                        }

                        switch httpResponse.statusCode {
                        case 200...299:
                            if useCache { //---Save cache data, if enabled---
                                let expire = Date().timeIntervalSince1970 + Resources.urlCacheExpires
                                let userInfo: [AnyHashable: Any] = [
                                    self.kUrlCacheExpiresName: expire
                                ]
                                let storagePolicy = Resources.urlCacheStoragePolicy
                                let cachedResponseToSave = CachedURLResponse(response: httpResponse,
                                                                             data: receivedData,
                                                                             userInfo: userInfo,
                                                                             storagePolicy: storagePolicy)
                                Resources.urlCache.storeCachedResponse(cachedResponseToSave,
                                                                       for: request)
                            }

                            switch apiEncoding {
                            case .data: //---Return server data---
                                completion(true,
                                           receivedData as AnyObject?,
                                           httpResponse.allHeaderFields,
                                           .success,
                                           "")

                            case .string: //---Return server data in string format---
                                guard
                                    let apiData = String(data: receivedData, encoding: .utf8)
                                    else {
                                        let errorMsg = "Error during convertion to string of response content"
                                        completion(false,
                                                   "" as AnyObject?,
                                                   httpResponse.allHeaderFields,
                                                   .error,
                                                   errorMsg)
                                        return
                                }

                                completion(true,
                                           apiData as AnyObject?,
                                           httpResponse.allHeaderFields,
                                           .success,
                                           "")

                            default:
                                guard
                                    let apiData = try? JSONSerialization.jsonObject(with: receivedData,
                                                                                    options: [])
                                    else {
                                        completion(false,
                                                   nil,
                                                   httpResponse.allHeaderFields,
                                                   .error,
                                                   "Error during parse response content to JSON")
                                        return
                                }

                                completion(true,
                                           apiData as AnyObject?,
                                           httpResponse.allHeaderFields,
                                           .success,
                                           "")
                            }

                        default:
                            completion(false,
                                       nil,
                                       nil,
                                       .error,
                                       "HTTP/HTTPS response error: \(httpResponse)")
                        }
                    }).resume()
                }
            }
        }
    }
}
