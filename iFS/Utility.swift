//
//  Utility.swift
//  iFS
//
//  Created by Francesco Sorrentino on 21/09/18.
//  Copyright © 2018 Francesco Sorrentino. All rights reserved.
//

extension FsManager {

    public class Utility: NSObject {

        public static let shared: Utility = Utility()

        private override init() {}

        /// Return a String token from token data
        public func getToken(_ deviceToken: Data) -> String {
            let charSet: CharacterSet = CharacterSet(charactersIn: "<>")
            let deviceToken = (deviceToken.description as NSString)
                .trimmingCharacters(in: charSet)
                .replacingOccurrences(of: " ", with: "") as String
            return deviceToken
        }

        /// Return a UIColor from hexadecimal string color
        public func colorFromHEX(_ hex: String) -> UIColor {
            var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

            if cString.hasPrefix("#") {
                cString = (cString as NSString).substring(from: 1)
            }

            if cString.count != 6 {
                return UIColor.gray

            }

            let rString = (cString as NSString).substring(to: 2)
            let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
            let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)

            var red: CUnsignedInt = 0, green: CUnsignedInt = 0, blue: CUnsignedInt = 0

            Scanner(string: rString).scanHexInt32(&red)
            Scanner(string: gString).scanHexInt32(&green)
            Scanner(string: bString).scanHexInt32(&blue)

            return UIColor(red: CGFloat(red) / 255.0,
                           green: CGFloat(green) / 255.0,
                           blue: CGFloat(blue) / 255.0,
                           alpha: CGFloat(1))
        }

        /// Convert to Date a TimeInterval starting from 01/01/1900 considering also summer time
        public func getDateFrom1900(_ timeInterval: TimeInterval) -> Date {
            let dateFromCompare = "1900-01-01 00:00:00"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            guard
                var dateRif = dateFormatter.date(from: dateFromCompare)
                else {
                    return Date()
            }

            if NSTimeZone.local.isDaylightSavingTime() {
                dateRif = dateRif.addingTimeInterval(-3600)
            }

            return Date(timeInterval: timeInterval / 1000, since: dateRif)
        }

        /// Convert to Date a TimeInterval starting from 1970-01-01 considering also summer time (optional default on)
        open static func getDateFrom1970(_ timeInterval: TimeInterval, noDayLightTime: Bool = false) -> Date {
            var dateRif = Date(timeIntervalSince1970: timeInterval / 1000)

            if !noDayLightTime {
                if NSTimeZone.local.isDaylightSavingTime() {
                    dateRif = dateRif.addingTimeInterval(-3600)
                }
            }

            return dateRif
        }

        /// Returns a TimeInterval of a certain Date with an optional date format (default: yyyy-MM-dd HH:mm:ss)
        /// starting from 1970-01-01. Return 0 if date in not in the correct format
        public func getTimeIntervalFrom1970(dateString: String,
                                            dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> TimeInterval {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            if let date = dateFormatter.date(from: dateString) {
                return date.timeIntervalSince1970
            }
            return 0
        }

        public func getDayName(_ day: Int, itIT: Bool = false) -> String {
            let days: [Int: String] = [
                1: itIT ? "Domenica" : "Sunday",
                2: itIT ? "Lunedi" : "Monday",
                3: itIT ? "Martedi" : "Tuesday",
                4: itIT ? "Mercoledi": "Wednesday",
                5: itIT ? "Giovedi": "Thursday",
                6: itIT ? "Venerdi": "Friday",
                7: itIT ? "Sabato": "Saturday"
            ]

            guard let result = days[day] else {
                return ""
            }

            return result
        }

        public func getMonthName(_ month: Int, itIT: Bool = false) -> String {
            let months: [Int: String] = [
                1: itIT ? "Gennaio" : "January",
                2: itIT ? "Febbraio" : "February",
                3: itIT ? "Marzo" : "March",
                4: itIT ? "Aprile" : "April",
                5: itIT ? "Maggio" : "May",
                6: itIT ? "Giugno" : "June",
                7: itIT ? "Luglio" : "July",
                8: itIT ? "Agosto" : "August",
                9: itIT ? "Settembre" : "September",
                10: itIT ? "Ottobre" : "October",
                11: itIT ? "Novembre" : "November",
                12: itIT ? "Dicembre" : "December"
            ]

            guard let result = months[month] else {
                return ""
            }

            return result
        }

        /// Return a Date from a JSON
        public func getDateFromJSON(_ jsonDate: JSON, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
            guard
                jsonDate != JSON.null
                else {
                return Date()
            }

            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.dateFormat = dateFormat

            let year = jsonDate["year"].stringValue
            let month = jsonDate["month"].stringValue
            let day = jsonDate["day"].stringValue

            var stringResult = "\(year)-\(month)-\(day)"

            let hour = jsonDate["hour"].stringValue
            let minute = jsonDate["minute"].stringValue
            let second = jsonDate["second"].stringValue

            stringResult += " \(hour):\(minute):\(second)"

            guard
                let resultDate = dateFormatter.date(from: stringResult)
                else {
                    return Date()
            }

            return resultDate
        }

        /// Return Date from a string
        public func getDateFromString(_ stringDate: String, dateFormat: String = "dd/MM/yyyy") -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.dateFormat = dateFormat

            guard
                let returnDate = dateFormatter.date(from: stringDate)
                else {
                return Date()
            }
            return returnDate
        }

        /// Returns a JSON by unpacking the date in day, month, year,
        /// hours, minutes, seconds, calculating how many days the month contains
        /// and the first and last day of the month
        public func getJSONFromDate(_ date: String, dateFormat: String) -> JSON {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent

            guard
                !date.isEmpty,
                dateFormatter.date(from: date) != nil,
                let dateIsOk = dateFormatter.date(from: date)
                else {
                    return JSON.null
            }

            return getJSONFromDate(dateIsOk)
        }

        /// Returns a JSON by unpacking the date in day, month, year,
        /// hours, minutes, seconds, calculating how many days the month contains
        /// and the first and last day of the month
        public func getJSONFromDate(_ date: Date) -> JSON {
            var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            calendar.timeZone = TimeZone.autoupdatingCurrent

            let components = (calendar as NSCalendar).components([.year, .month], from: date)
            var dateComponents = DateComponents()

            guard
                let lastOfMonth = calendar.date(from: components),
                let startOfMonth = (calendar as NSCalendar).date(byAdding: dateComponents,
                                                                 to: lastOfMonth,
                                                                 options: [])
                else {
                    return JSON.null
            }

            dateComponents.month = 1
            dateComponents.day = -1

            guard
            let endOfMonth = (calendar as NSCalendar).date(byAdding: dateComponents,
                                                           to: lastOfMonth,
                                                           options: [])
                else {
                    return JSON.null
            }

            return JSON(
                [
                    "day": String(format: "%02d", (calendar as NSCalendar).component(.day, from: date)),
                    "dayName": date.dayName(),
                    "dayNameShort": date.dayName(isShort: true),
                    "month": String(format: "%02d", (calendar as NSCalendar).component(.month, from: date)),
                    "monthName": date.monthName(),
                    "monthNameShort": date.monthName(isShort: true),
                    "year": String(format: "%04d", (calendar as NSCalendar).component(.year, from: date)),
                    "hour": String(format: "%02d", (calendar as NSCalendar).component(.hour, from: date)),
                    "minute": String(format: "%02d", (calendar as NSCalendar).component(.minute, from: date)),
                    "second": String(format: "%02d", (calendar as NSCalendar).component(.second, from: date)),
                    "days": (calendar as NSCalendar).component(.day, from: endOfMonth),
                    "fistDayName": startOfMonth.dayName(),
                    "fistDayNameShort": startOfMonth.dayName(isShort: true),
                    "LastDayName": endOfMonth.dayName(),
                    "LastDayNameShort": endOfMonth.dayName(isShort: true)
                ]
            )
        }

        /// Return TRUE if email string is valid
        public func isValidEmail(_ email: String) -> Bool {
            let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", regEx)
            return emailTest.evaluate(with: email)
        }

        public func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size

            let widthRatio = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height

            var newSize: CGSize
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)

            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }

            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)

            guard
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                else {
                    UIGraphicsEndImageContext()
                    return UIImage()
            }

            UIGraphicsEndImageContext()
            return newImage
        }

    }

}
