//
//  InAppPurchase.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

import Foundation
import SwiftyJSON

extension FsManager {

    public class InAppPurchase: NSObject {

        public static let shared: InAppPurchase = InAppPurchase()

        private override init() {}

        public func verifyReceipt(_ productID: String,
                                  sharedKey: String,
                                  isSandBox: Bool = false,
                                  completion: @escaping (_ jResult: JSON) -> Void = { _ in }) {
            var result: Types.InAppPurchaseResults = .noTest

            var iapResult: JSON = [
                "product_id": productID,
                "result": String(describing: result),
                "transaction_id": "",
                "receipt": JSON.null
            ]

            guard
                Bundle.main.appStoreReceiptURL != nil,
                let receiptData = NSData(contentsOf: Bundle.main.appStoreReceiptURL!)
                else {
                    completion(iapResult)
                    return
            }

            let params = [
                "receipt-data": receiptData.base64EncodedString(options: .endLineWithCarriageReturn),
                "password": sharedKey
            ]

            var url = "https://buy.itunes.apple.com/verifyReceipt"
            if isSandBox {
                url = "https://sandbox.itunes.apple.com/verifyReceipt"
            }

            let request = NSMutableURLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
                guard
                    error == nil,
                    data != nil,
                    let jData = try? JSONSerialization.jsonObject(with: data!, options: []),
                    case let json = JSON(jData),
                    let lastReceipt = json["latest_receipt_info"].arrayValue
                        .filter({ $0["product_id"].stringValue == productID }).last
                    else {
                        completion(iapResult)
                        return
                }

                let transactionId = lastReceipt["transaction_id"].stringValue

                let now = Int64(Date().timeIntervalSince1970) * 1000

                var expire: Int64 = 0
                if let jExpireValue = Int64(lastReceipt["expires_date_ms"].stringValue) {
                    expire = jExpireValue
                }

                var cancel: Int64 = 0
                if let jCancelValue = Int64(lastReceipt["cancel_date_ms"].stringValue) {
                    cancel = jCancelValue
                }

                if now <= expire {
                    result = .valid

                } else {
                    result = .expired
                }

                if cancel > 0 && now >= cancel {
                    result = .refunded
                }

                iapResult["result"].stringValue = String(describing: result)
                iapResult["transaction_id"].stringValue = transactionId
                iapResult["receipt"] = lastReceipt

                completion(iapResult)
            }).resume()
        }

    }
}
