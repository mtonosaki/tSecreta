//
//  ModelNote.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//

import Foundation

public class NoteHistRecord : Codable {
    public var DT = Date()
    public var Value = ""
}

public class Note  : Codable {
    public var ID: String = ""
    public var UniversalData = Dictionary<String, Array<NoteHistRecord>>()
    
    //--------------------------
    // ["Caption"]
    // ["CaptionRubi"]
    // ["AccountID"]
    // ["Password"]
    // ["Email"]
    // ["IsDeleted"] = "True" / "False"
    // ["Memo"]
    // ["CreatedDateTime"] = "yyyy/mm/dd HH:MM:SS"
    //--------------------------
    
    public func GetLatest(key: String) -> String? {
        let histList = UniversalData[key]
        return histList?.last?.Value
    }
    
    public func SetToLatest(key: String, text: String) {
        let histList = UniversalData[key]
        histList?.last?.Value = text
    }
    
    public func CheckDeleted() -> Bool {
        let sw = GetLatest(key: "IsDeleted")
        if let sw = sw {
            return Bool.parseFuzzy(sw, false)
        }
        return false
    }
    
    public func SetDeletedFlag(_ sw: Bool ) {
        var histList = UniversalData["IsDeleted"]
        let lastitem = histList?.last?.Value ?? "False"
        let lastsw = Bool(lastitem)
        if lastsw != sw {
            let rec = NoteHistRecord()
            rec.DT = Date()
            rec.Value = String(sw)
            histList?.append(rec)
        }
    }
}

public class NoteList  : Codable {
    public var Attributes = Dictionary<String, String>()
    public var Notes = Array<Note>()
}

