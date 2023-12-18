//
//  StringExtension.swift
//  Tauch
//
//  Created by Musa Yazuju on 2022/08/10.
//

import Foundation

extension String {
    
    static let homeTabSearch = "さがす"
    static let homeTabLikeCard = "趣味カード"
    
    static let categoryFriend  = "友達募集"
    static let categoryWorries = "お悩み"
    static let categoryTeaser  = "お誘い"
    static let categoryTweet  = "つぶやき"
    
    func calcAge() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.dateStyle = .long
        let calendar = Calendar(identifier: .gregorian)
        
        guard let date = dateFormatter.date(from: self) else { return "未設定" }
        guard let formatDate = calendar.date(byAdding: .day, value: 1, to: date) else { return "未設定" }
        
        let birthDateCalendar = calendar.dateComponents([.year, .month, .day], from: formatDate)
        let nowCalendar = calendar.dateComponents([.year, .month, .day], from: Date())
        let ageComponents = calendar.dateComponents([.year], from: birthDateCalendar, to: nowCalendar)
        let age = ageComponents.year ?? 0
        if age == 0 { return "未設定" }
        let ageStr = "\(age)歳"
        return ageStr
    }
    
    func calcAgeForInt() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.dateStyle = .long
        let calendar = Calendar(identifier: .gregorian)
        
        guard let date = dateFormatter.date(from: self) else { return 0 }
        guard let formatDate = calendar.date(byAdding: .day, value: 1, to: date) else { return 0 }
        
        let birthDateCalendar = calendar.dateComponents([.year, .month, .day], from: formatDate)
        let nowCalendar = calendar.dateComponents([.year, .month, .day], from: Date())
        let ageComponents = calendar.dateComponents([.year], from: birthDateCalendar, to: nowCalendar)
        let age = ageComponents.year ?? 0
        return age
    }
    
    func getDiffDateComponents() -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.dateStyle = .long
        let calendar = Calendar(identifier: .gregorian)
        
        guard let date = dateFormatter.date(from: self) else { return DateComponents() }
        
        let birthDateCalendar = calendar.dateComponents([.year, .month, .day], from: date)
        let nowCalendar = calendar.dateComponents([.year, .month, .day], from: Date())
        
        let diffDateComponents = calendar.dateComponents([.year, .month, .day], from: nowCalendar, to: birthDateCalendar)
        
        return diffDateComponents
    }
    
    // 日時を特定のフォーマットに変換 (String => Date)
    func dateFromString(format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let date = formatter.date(from: self) ?? Date()
        return date
    }
    
    /// replace prefecture characters to space
    func removePrefectureCharacters() -> String {
        var replacedArea = self
        if self == "東京都" {
            replacedArea = self.replacingOccurrences(of: "都", with: "")
        } else if self == "大阪府" || self == "京都府" {
            replacedArea = self.replacingOccurrences(of: "府", with: "")
        } else if self.contains("県") {
            replacedArea = self.replacingOccurrences(of: "県", with: "")
        }
        return replacedArea
    }
    
    func toKatakana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            if 0x3041 <= scalar.value && scalar.value <= 0x3096 {
                if let unicodeScalar = UnicodeScalar(scalar.value + 96) {
                    return unicodeScalar
                }
            }
            return scalar
        }
        return String(String.UnicodeScalarView(result))
    }
    
    func toHiragana() -> String {
        let result = self.unicodeScalars.map { scalar -> UnicodeScalar in
            if 0x30A1 <= scalar.value && scalar.value <= 0x30F6 {
                if let unicodeScalar = UnicodeScalar(scalar.value - 96) {
                    return unicodeScalar
                }
            }
            return scalar
        }
        return String(String.UnicodeScalarView(result))
    }
    
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }

    func ranges(of searchString: String, options mask: NSString.CompareOptions = [], locale: Locale? = nil) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        while let range = range(of: searchString, options: mask, range: (ranges.last?.upperBound ?? startIndex)..<endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }

    func nsRanges(of searchString: String, options mask: NSString.CompareOptions = [], locale: Locale? = nil) -> [NSRange] {
        let ranges = self.ranges(of: searchString, options: mask, locale: locale)
        return ranges.map { nsRange(from: $0) }
    }
}
