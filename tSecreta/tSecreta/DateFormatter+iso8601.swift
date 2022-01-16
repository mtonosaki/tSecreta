//
//  StrUtils.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import Foundation

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
        formatter.timeZone = TimeZone(secondsFromGMT: 9 * 3600)
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
