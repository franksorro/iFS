//
//  iFSExtensions.swift
//  iFS
//
//  Created by Francesco Sorrentino on 25/10/17.
//  Copyright © 2017 Francesco Sorrentino. All rights reserved.
//

import CommonCrypto

extension UIApplication {

    class func topMostViewController() -> UIViewController? {
        guard
            let keyWindow = UIApplication.shared.keyWindow,
            let rootViewController = keyWindow.rootViewController
            else {
                return nil
        }

        return rootViewController
    }

    class func topViewController(controller: UIViewController?
        = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }

        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }

        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }

        return controller
    }

}

extension UIViewController {

    @objc open func goRoot() {
        guard
            let root = UIStoryboard(name: FsManager.Resources.mainStoryboard,
                                    bundle: Bundle.main).instantiateInitialViewController()
            else {
                return
        }

        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        self.present(root, animated: true, completion: nil)
    }

    @objc open func goBack() {
        if self.navigationController != nil {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
            self.navigationController!.popViewController(animated: true)
        }
    }

    public func msgBox(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor.red

        alertController.addAction(UIAlertAction(title: "Chiudi", style: .default, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }))

        if self.presentedViewController == nil {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @objc fileprivate func toastClose(_ sender: UITapGestureRecognizer) {
        if sender.view != nil {
            var senderTopFrame: CGRect = sender.view!.frame
            senderTopFrame.origin.y = -1 * (senderTopFrame.height)

            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                sender.view!.frame = senderTopFrame

            }, completion: { (_) in
                sender.view!.removeFromSuperview()
            })
        }
    }

    public func toast(message: String,
                      isChild: Bool = false,
                      delay: TimeInterval = FsManager.Resources.toastDelay,
                      textFont: UIFont = FsManager.Resources.toastTextFont,
                      textColor: UIColor = FsManager.Resources.toastTextColor,
                      background: UIColor = FsManager.Resources.toastBackgroundColor,
                      padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                      isRounded: Bool = false,
                      callBack: @escaping (_ result: Bool) -> Void = { _ in }) {

        let vwToast = UIView(frame: CGRect(x: padding.left,
                                           y: padding.top,
                                           width: self.view.frame.width - (padding.left * 2),
                                           height: 1))

        if isChild {
            self.view.addSubview(vwToast)
            self.view.bringSubview(toFront: vwToast)

        } else {
            guard let topVC = UIApplication.shared.keyWindow?.rootViewController else { return }
            vwToast.frame = CGRect(x: padding.left, y: padding.top, width: topVC.view.frame.width, height: 1)
            topVC.view.addSubview(vwToast)
            topVC.view.bringSubview(toFront: vwToast)
        }

        vwToast.backgroundColor = background

        if isRounded {
            vwToast.borderRounded()
        }

        let lbMsg = UILabel(frame: CGRect(x: 5, y: 25, width: vwToast.frame.width - 10, height: 1))
        vwToast.addSubview(lbMsg)
        lbMsg.textAlignment = .center
        lbMsg.text = message
        lbMsg.font = textFont
        lbMsg.textColor = textColor
        lbMsg.numberOfLines = 0
        lbMsg.lineBreakMode = .byWordWrapping
        lbMsg.sizeToFit()
        lbMsg.isUserInteractionEnabled = true
        lbMsg.frame.size.height += 5
        vwToast.frame.size.height = lbMsg.frame.origin.y + lbMsg.frame.height + 25
        lbMsg.frame.origin = CGPoint(x: (vwToast.frame.width - lbMsg.frame.width) / 2,
                                     y: (vwToast.frame.height - lbMsg.frame.height) / 2)

        vwToast.frame.origin.y = vwToast.frame.height * -1

        var vwToastTopFrame: CGRect = vwToast.frame
        vwToastTopFrame.origin.y = padding.top

        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            vwToast.frame = vwToastTopFrame
        })

        if delay > 0 { //---Delay seconds before close toast---
            let when = DispatchTime.now() + delay
            DispatchQueue.main.asyncAfter(deadline: when) {
                var senderTopFrame: CGRect = vwToast.frame
                senderTopFrame.origin.y = -1 * senderTopFrame.height

                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    vwToast.frame = senderTopFrame

                }, completion: { (_) in
                    vwToast.removeFromSuperview()
                    DispatchQueue.main.async {
                        callBack(true)
                    }
                })
            }

        } else { //---Close toast by tap event---
            vwToast.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toastClose(_:))))
        }
        //---*---
    }
}

extension UIImageView {

    public func getImageFromURL(_ url: URL,
                                filePathToSave: String = "",
                                callBack: @escaping (_ sizeResult: CGSize) -> Void = { _ in }) {
        let request = URLRequest(url: url,
                                 cachePolicy: FsManager.Resources.urlCachePolicy,
                                 timeoutInterval: FsManager.Resources.urlCacheTimeoutInterval)

        URLCache.shared = FsManager.Resources.urlCache

        let cacheResponse = URLCache.shared.cachedResponse(for: request) //---Read data from cache---
        if cacheResponse == nil { //---Empty cache---

            let configuration = URLSessionConfiguration.default
            configuration.urlCache = URLCache.shared

            let session = URLSession(configuration: configuration)

            let task = session.dataTask(with: request as URLRequest,
                                        completionHandler: {(data, response, error) -> Void in

                guard
                    error == nil,
                    let httpResponse = response as? HTTPURLResponse,
                    let receivedData = data
                    else {
                        callBack(CGSize(width: 0, height: 0))
                        return
                }

                if httpResponse.statusCode > 400 {
                    if let error = NSString(data: receivedData, encoding: String.Encoding.utf8.rawValue) {
                        var errorMsg = "Error download image, statusCode: \(httpResponse.statusCode)"
                        errorMsg += ", errore: \(error)"
                        FsManager.shared.debug(errorMsg)

                    } else {
                        let errorMsg = "Error download image, statusCode: \(httpResponse.statusCode)"
                        FsManager.shared.debug(errorMsg)
                    }

                    callBack(CGSize(width: 0, height: 0))
                    return
                }

                DispatchQueue.global(qos: .background).async {
                    if !filePathToSave.isEmpty { //---Write data on local file---
                        try? receivedData.write(to: URL(fileURLWithPath: filePathToSave), options: [])
                    }

                    DispatchQueue.main.async {
                        self.image = UIImage(data: receivedData)

                        if self.image != nil {
                            callBack(self.image!.size)

                        } else {
                            callBack(CGSize(width: 0, height: 0))
                        }
                    }
                }

            })

            task.resume()

        } else {
            DispatchQueue.main.async {
                self.image = UIImage(data: cacheResponse!.data)

                if self.image != nil {
                    callBack(self.image!.size)

                } else {
                    callBack(CGSize(width: 0, height: 0))
                }
            }
        }
    }

    public func getImage(_ urlString: String,
                         alternativeFolderName: String = "",
                         placeHolder: String = "",
                         callBack: @escaping (_ sizeResult: CGSize) -> Void = { _ in }) {
        let folderName = alternativeFolderName.isEmpty ? FsManager.Resources.imageFolderName : alternativeFolderName

        guard
            let url = URL(string: urlString),
            let fileName = URL(fileURLWithPath: urlString).pathComponents.last,
            let urlString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let path = URL(string: urlString),
            let imagePath = path.appendingPathComponent(folderName, isDirectory: true).absoluteString as String?
            else {
                callBack(CGSize.zero)
                return
        }

        if !FileManager.default.fileExists(atPath: imagePath) {
            do {
                try FileManager.default.createDirectory(atPath: imagePath,
                                                        withIntermediateDirectories: false,
                                                        attributes: nil)

            } catch {
                var errorMsg = "Error creating image folder: "
                errorMsg += "[\(error.localizedDescription)]"
                FsManager.shared.debug(errorMsg)
                callBack(CGSize.zero)
                return
            }
        }

        guard
            FileManager.default.fileExists(atPath: imagePath + fileName),
            let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath + fileName))
            else {
                getImageFromURL(url, filePathToSave: imagePath + fileName, callBack: { (size) in
                    callBack(size)
                })
                return
        }

        self.image = UIImage(data: imageData)

        if self.image != nil {
            callBack(self.image!.size)

        } else {
            callBack(CGSize.zero)
        }
    }

}

extension UIFont {

    public func withTraits(_ traits: UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }

    public func bold() -> UIFont {
        return withTraits(.traitBold)
    }

    public func italic() -> UIFont {
        return withTraits(.traitItalic)
    }

    public func boldItalic() -> UIFont {
        return withTraits(.traitBold, .traitItalic)
    }

}

extension UINavigationController {

    public func setLayout() {
        self.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationBar.shadowImage = nil
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = FsManager.Resources.navigationBarColor
        self.navigationBar.barStyle = .black
        self.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: FsManager.Resources.navigationBarFont,
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
    }

    public func navBarTrasparent() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
    }
}

extension UINavigationItem {

    public func customBackButton(_ sender: UIViewController, isInitialView: Bool = false) {
        let btBack = UIButton(type: .custom)
        btBack.setImage(FsManager.Resources.navigationBackImage, for: UIControlState())
        btBack.imageView?.tintColor = FsManager.Resources.navigationBackColor
        btBack.sizeToFit()
        btBack.addTarget(sender,
                         action: isInitialView ? #selector(sender.goRoot) : #selector(sender.goBack),
                         for: UIControlEvents.touchUpInside)
        self.leftBarButtonItem = UIBarButtonItem(customView: btBack)
    }

}

extension UITableViewCell {

    public func getHeight() -> CGFloat {
        self.layoutIfNeeded()
        var height: CGFloat = self.frame.height
        let size = self.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        if size.height > height {
            height = size.height

        }
        return height
    }

}

extension Data {

    var md5String: String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        var digestHex = ""
        self.withUnsafeBytes { (bytes: UnsafePointer<CChar>) -> Void in
            CC_MD5(bytes, CC_LONG(self.count), &digest)
            for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
                digestHex += String(format: "%02x", digest[index])
            }
        }
        return digestHex
    }

    func hexString() -> String {
        let nsdataStr = NSData.init(data: self)
        let trim = nsdataStr.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        return trim.replacingOccurrences(of: " ", with: "")
    }

    internal var attributedString: NSAttributedString? {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8
        ]

        guard
            let attrib = try? NSAttributedString(data: self,
                                                   options: options,
                                                   documentAttributes: nil)
            else {
                return nil
        }

        return attrib
    }

    public func appendToURL(_ fileURL: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
            defer {
                fileHandle.closeFile()
            }

            fileHandle.seekToEndOfFile()
            fileHandle.write(self)

        } else {
            try write(to: fileURL, options: .atomic)
        }
    }

}

extension String {

    func md5() -> Data {
        let messageData = self.data(using: .utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData
    }

    public func md5() -> String {
        return self.data(using: .utf8)!.md5String
    }

    public func isValidEmail() -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regEx).evaluate(with: self)
    }

    public func isValidFiscalCode() -> Bool {
        let regEx = "[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]"
        return NSPredicate(format: "SELF MATCHES %@", regEx).evaluate(with: self)
    }

    public var html2String: String {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
        ]

        guard
            let htmlData = self.data(using: String.Encoding.unicode),
            let attribText = try? NSAttributedString(data: htmlData,
                                                     options: options,
                                                     documentAttributes: nil)
            else {
                return ""
        }

        return attribText.string
    }

    func appendingPathComponent(_ string: String) -> String {
        return URL(fileURLWithPath: self).appendingPathComponent(string).path
    }

    internal var utf8Data: Data? {
        return data(using: String.Encoding.utf8)
    }

    public func appendLineToURL(_ fileURL: URL) throws {
        try "\(self)\n".appendToURL(fileURL)
    }

    public func appendToURL(_ fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.appendToURL(fileURL)
    }

    public func left(_ chars: Int) -> String {
        if chars < 1 || chars > self.count {
            return ""
        }

        let range = self.startIndex ..< self.index(self.startIndex, offsetBy: chars)
        let subString = self[range]
        return String(subString)
    }

    public func right(_ chars: Int) -> String {
        if chars < 1 || chars > self.count {
            return ""
        }

        let range = self.index(self.startIndex, offsetBy: chars) ..< self.endIndex
        let subString = self[range]
        return String(subString)
    }

    public func subString(_ start: Int, end: Int) -> String {
        if start < 1 || start > self.count || end < 0 || end > self.count {
            return ""
        }

        let range = self.index(self.startIndex, offsetBy: start) ..< self.index(self.startIndex, offsetBy: end)
        let subString = self[range]
        return String(subString)
    }

    public func replace(_ target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target,
                                         with: withString,
                                         options: NSString.CompareOptions.literal,
                                         range: nil)
    }

    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public func stripTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    public func equalsIgnoreCase(_ compareTo: String) -> Bool {
        return self.compare(compareTo,
                            options: .caseInsensitive,
                            range: nil,
                            locale: nil) == ComparisonResult.orderedSame
    }

    public func encoding() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }

    public func toBool() -> Bool {
        switch self {
        case "True", "true", "yes", "1":
            return true

        case "False", "false", "no", "0":
            return false

        default:
            return false
        }
    }

    public func decodeUTF8() -> String {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
        ]

        guard
            !self.isEmpty,
            let attribText = try? NSAttributedString(data: self.data(using: String.Encoding.utf8)!,
                                                       options: options,
                                                       documentAttributes: nil)
            else {
                return ""
        }

        return attribText.string
    }

    public func decode() -> String {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8
        ]

        guard
            !self.isEmpty,
            let attribText = try? NSAttributedString(data: self.data(using: String.Encoding.utf8)!,
                                                     options: options,
                                                     documentAttributes: nil)
            else {
                return ""
        }

        return attribText.string
    }

    public func escape() -> (String) {
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        if let escapedString = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            return escapedString
        }

        return ""
    }

    public func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedStringKey.font: font],
                                            context: nil)
        return boundingBox.height
    }

    public var first: String {
        return String(self.prefix(through: self.index(self.startIndex, offsetBy: 0)))
    }

    public var last: String {
        return String(self.suffix(from: self.index(self.startIndex, offsetBy: self.count - 1)))
    }

    public var capitalize: String {
        guard !self.isEmpty else {
            return ""
        }
        return first.uppercased() + String(self.dropFirst()).lowercased()
    }

}

extension UIView {

    public func borderRounded() {
        self.layer.cornerRadius = 3.0
        self.clipsToBounds = true
    }

    public func cyrcle() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }

    public func addBorderTop(size: CGFloat, color: UIColor) {
        addBorderUtility(posX: 0, posY: 0, width: frame.width, height: size, color: color)
    }

    public func addBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(posX: 0, posY: frame.height - size, width: frame.width, height: size, color: color)
    }

    public func addBorderLeft(size: CGFloat, color: UIColor) {
        addBorderUtility(posX: 0, posY: 0, width: size, height: frame.height, color: color)
    }

    public func addBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(posX: frame.width - size, posY: 0, width: size, height: frame.height, color: color)
    }

    fileprivate func addBorderUtility(posX: CGFloat, posY: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: posX, y: posY, width: width, height: height)
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }

    public func loadingShow(blockActions: Bool = true) {
        var isLoading = false
        self.subviews.forEach({
            if $0 is UIActivityIndicatorView {
                isLoading = true
            }
        })

        if !isLoading {
            let loading = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            self.addSubview(loading)

            loading.hidesWhenStopped = true
            loading.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            loading.activityIndicatorViewStyle = .whiteLarge
            loading.layer.cornerRadius = 10.0
            loading.translatesAutoresizingMaskIntoConstraints = false
            loading.startAnimating()

            NSLayoutConstraint.activate(
                [loading.widthAnchor.constraint(equalToConstant: 80),
                 loading.heightAnchor.constraint(equalToConstant: 80),
                 loading.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                 loading.centerYAnchor.constraint(equalTo: self.centerYAnchor)]
            )

            if blockActions {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
        }
    }

    public func loadingHide() {
        self.subviews.forEach {
            if let subView = $0 as? UIActivityIndicatorView {
                subView.stopAnimating()
                subView.removeFromSuperview()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    //---*---
}

extension Date {

    func monthName(isShort: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate(isShort ? "MMM": "MMMM")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }

    func dayName(isShort: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate(isShort ? "EEE" : "EEEE")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }

    public func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        var isGreater = false

        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }

        return isGreater
    }

    public func isLessThanDate(_ dateToCompare: Date) -> Bool {
        var isLess = false

        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }

        return isLess
    }

    public func equalToDate(_ dateToCompare: Date) -> Bool {
        var isEqualTo = false

        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }

        return isEqualTo
    }

    public func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        return dateWithDaysAdded
    }

    public func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        return dateWithHoursAdded
    }
}

extension JSON {

    mutating func appendIfArray(json: JSON) {
        if var arr = self.array {
            arr.append(json)
            self = JSON(arr)
        }
    }

    mutating func appendIfDictionary(key: String, json: JSON) {
        if var dict = self.dictionary {
            dict[key] = json
            self = JSON(dict)
        }
    }
}

extension UIView {

    class var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

}
