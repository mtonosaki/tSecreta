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
    case isDeleted = "IsDeleted" // "True" / "False"
    case memo = "Memo"
    case createdDateTime = "CreatedDateTime" // "yyyy/mm/dd HH:MM:SS"
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
    
    public func setValue(field: FieldNames, text: String) {
        
        if UniversalData.keys.contains(field.rawValue) == false {
            UniversalData[field.rawValue] = Array<NoteHistRecord>()
        }
        var histList = UniversalData[field.rawValue]!
        if histList.count == 0 {
            let newItem = NoteHistRecord(DT: Date(), Value: text)
            histList.append(newItem)
            UniversalData[field.rawValue] = histList
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
            return
        }

        let newRecord = NoteHistRecord(DT: Date(), Value: text)
        histList.append(newRecord)
        UniversalData[field.rawValue] = histList
    }
    
    public func getDeletedFlag() -> Bool {
        let sw = getValue(field: .isDeleted)
        if let sw = sw {
            return Bool.parseFuzzy(sw, false)
        }
        return false
    }
    
    public func setDeletedFlag(_ sw: Bool ) {
        var histList = UniversalData[FieldNames.isDeleted.rawValue]
        let lastitem = histList?.last?.Value ?? "False"
        let lastsw = Bool(lastitem)
        if lastsw != sw {
            let rec = NoteHistRecord(DT: Date(), Value: String(sw))
            histList?.append(rec)
        }
    }
}

public class NoteList  : Codable {
    public var Attributes = Dictionary<String, String>()
    public var Notes = Array<Note>()
}

