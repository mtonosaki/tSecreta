//
//  ModelNote.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import Foundation

public enum FieldNames: String {
    case na = "(n/a)"
    case caption = "Caption"
    case captionRubi = "CaptionRubi"
    case accountID = "AccountID"
    case password = "Password"
    case email = "Email"
    case isDeleted = "IsDeleted"         // "True" / "False"
    case isFilterHome = "isFilterHome"   // "True" / "False"
    case isFilterWork = "isFilterWork"   // "True" / "False"
    case memo = "Memo"
    case createdDateTime = "CreatedDateTime" // "yyyy/mm/dd HH:MM:SS"
    case logoFilename = "logoFilename"
}

public struct NoteHistRecord : Codable {
    public var DT: Date
    public var Value: String
}

public class Note  : Codable {
    public var ID: String
    public var UniversalData = Dictionary<String, Array<NoteHistRecord>>()
    
    init() {
        ID = UUID().uuidString
    }
    
    public func getValue(field: FieldNames) -> String? {
        let histList = UniversalData[field.rawValue]
        return histList?.last?.Value
    }
    
    public func removeValueNoHistory(field: FieldNames) {
        UniversalData.removeValue(forKey: field.rawValue)
    }

    public func setValueNoHistory(field: FieldNames, text: String) {
        UniversalData[field.rawValue] = Array<NoteHistRecord>()
        var histList = UniversalData[field.rawValue]!
        let newItem = NoteHistRecord(DT: Date(), Value: text)
        histList.append(newItem)
        UniversalData[field.rawValue] = histList
        normalize(field)
    }
    
    public func setValueToHistory(field: FieldNames, text: String) {
        
        if UniversalData.keys.contains(field.rawValue) == false {
            UniversalData[field.rawValue] = Array<NoteHistRecord>()
        }
        var histList = UniversalData[field.rawValue]!
        if histList.count == 0 {
            let newItem = NoteHistRecord(DT: Date(), Value: text)
            histList.append(newItem)
            UniversalData[field.rawValue] = histList
            normalize(field)
            return
        }
        var last = histList.last!
        
        if last.Value.trimmingCharacters(in: .whitespacesAndNewlines) == text.trimmingCharacters(in: .whitespacesAndNewlines) {
            return  // do nothing
        }

        guard
            let span = Calendar(identifier: .gregorian).dateComponents([.second], from: last.DT, to: Date()).second
                , span > 3600
        else {
            last.DT = Date()
            last.Value = text
            histList[histList.count - 1] = last
            UniversalData[field.rawValue] = histList
            normalize(field)
            return
        }

        let newRecord = NoteHistRecord(DT: Date(), Value: text)
        histList.append(newRecord)
        UniversalData[field.rawValue] = histList
        normalize(field)
    }
    
    public func getFlag(_ fieldName: FieldNames) -> Bool {
        let sw = getValue(field: fieldName)
        if let sw = sw {
            return Bool.parseFuzzy(sw, false)
        }
        return false
    }
    
    public func setFlag(_ fieldName: FieldNames, _ sw: Bool ) {
        let histList = UniversalData[fieldName.rawValue]
        let lastSwitchString = histList?.last?.Value ?? "False"
        let lastSwitch = Bool(lastSwitchString)
        if lastSwitch != sw {
            let rec = NoteHistRecord(DT: Date(), Value: sw ? "True" : "False")
            if var histList = histList {
                if let lastItem = histList.last {
                    let diffSeconds = abs(lastItem.DT.timeIntervalSinceNow)
                    if( diffSeconds > 600 ){
                        histList.append(rec)
                        UniversalData[fieldName.rawValue] = histList
                        normalize(fieldName)
                    } else {
                        histList[histList.count - 1] = rec
                        UniversalData[fieldName.rawValue] = histList
                        normalize(fieldName)
                    }
                } else {
                    histList.append(rec)
                    UniversalData[fieldName.rawValue] = histList
                    normalize(fieldName)
                }
            } else {
                UniversalData[fieldName.rawValue] = [rec]
                normalize(fieldName)
            }
        }
    }
    
    public func normalize(_ fieldName: FieldNames) {
        guard var histList = UniversalData[fieldName.rawValue] else {
            return
        }
        if histList.count < 2 {
            return
        }
        let item1 = histList[histList.count - 2]
        let item2 = histList[histList.count - 1]
        if item1.Value == item2.Value {
            histList.removeLast()
            UniversalData[fieldName.rawValue] = histList
        }
    }
}

public class NoteList  : Codable {
    public var Attributes = Dictionary<String, String>()
    public var Notes = Array<Note>()
}

