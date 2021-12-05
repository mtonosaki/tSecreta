//
//  StrUtils.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import Foundation

extension String {
    public func Mid(start: Int, len: Int = 999999999) -> String.SubSequence {
        if start >= self.count {
            return self[self.endIndex..<self.endIndex]
        }
        var safeStart: Int = start
        var safeLen: Int = len
        if start < 0 {
            safeLen = safeLen + start
            safeStart = 0
        }
        if safeStart + safeLen >= self.count {
            safeLen = self.count - safeStart
        }
        let i0 = self.startIndex
        let i1 = self.index(i0, offsetBy: safeStart)
        if safeLen < 1 {
            return self[i1..<i1]
        }
        let i2 = self.index(i1, offsetBy: safeLen)
        return self[i1..<i2]
    }
}

extension DateFormatter {
    static let iso8601PlusMilliSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    static let iso8601PlusMilliSecondsJst: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'+09:00'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

func findBrandLogo(name: String) -> String {
    return "cellNoImg"
}

extension Bool {
    public static func parseFuzzy(_ str: String, _ defaultValue: Bool = false) -> Bool {
        let s = str.lowercased()
        switch s {
        case "true": return true
        case "yes": return true
        case "ok": return true
        default:
            return defaultValue
        }
    }
}
