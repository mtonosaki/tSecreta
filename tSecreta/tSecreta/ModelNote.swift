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
    
    
    public func GetLatest(key: String) -> String? {
        let histList = UniversalData[key]
        return histList?.last?.Value
    }
    
    public func CheckDeleted() -> Bool {
        let sw = GetLatest(key: "IsDeleted")
        if let sw = sw {
            return Bool(sw) ?? false
        }
        return false
    }
}

public class NoteList  : Codable {
    public var Attributes = Dictionary<String, String>()
    public var Notes = Array<Note>()
}

