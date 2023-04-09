//
//  ModelNote.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/01.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import Foundation
import Tono

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

public struct NoteHistRecord {
    public var DT: Date
    public var Value: String
    
    public func makeInstanceCode() -> String {
        var ret = ""
        ret.append("HIST:")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Etc/GMT")
        ret.append(dateFormatter.string(from: DT))
        ret.append("=")
        ret.append(Value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
        return ret
    }
    
    public static func makeObjectFrom(_ lines: [String.SubSequence], startIndex: Int) throws -> (NoteHistRecord, Int) {
        var step = startIndex
        
        step += 1
        let line = lines[step];
        if !line.starts(with: "HIST:") {
            throw FormatError.UnexpectedHistoryFormat
        }

        let pos = line.firstIndex(of: "=") ?? line.startIndex
        let dtstr = String(line[line.index(line.startIndex, offsetBy: 5)..<pos])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Etc/GMT")
        let dt = dateFormatter.date(from: dtstr)
        guard let dt = dt else {
            throw FormatError.dateTimeFormatError
        }
        let val = String(line[line.index(pos, offsetBy: 1)..<line.endIndex])
        
        return (NoteHistRecord(DT: dt, Value: val.removingPercentEncoding ?? val), step)
    }
}

public class Note {
    public var ID: String
    public var UniversalData = Dictionary<String, Array<NoteHistRecord>>()
    
    public func makeInstanceCode() -> String {
        var ret = ""

        ret.append("%NOTE%-\(ID)")
        ret.append("\n")
        ret.append("\(UniversalData.count)")
        ret.append("\n")
        for kv in UniversalData {
            ret.append("\(kv.key)=\(kv.value.count)")
            ret.append("\n")
            for hist in kv.value {
                ret.append(hist.makeInstanceCode())
                ret.append("\n")
            }
        }
        return ret
    }
    
    public static func makeObjectFrom(_ lines: [String.SubSequence], startIndex: Int) throws -> (Note, Int) {
        do {
            let ret = Note()
            var step = startIndex
            
            step += 1
            var line = lines[step]
            if !line.starts(with: "%NOTE%-") {
                throw FormatError.unexpectedNoteIdPrefix
            }
            ret.ID = String(StrUtil.mid(line, start: 7))
            
            step += 1
            line = lines[step]
            let universalDataCont = Int(line) ?? -1
            if universalDataCont < 0 || universalDataCont > 9999 {
                throw FormatError.universaCountError
            }
            ret.UniversalData.removeAll()
            for _ in 0..<universalDataCont {
                step += 1
                line = lines[step]
                let kn = line.split(separator: "=")
                let key = String(kn[0])
                let historyCount = Int(kn[1]) ?? -1
                if historyCount < 0 || historyCount > 9999 {
                    throw FormatError.historyCountError
                }
                ret.UniversalData[key] = []
                for _ in 0..<historyCount {
                    let (noteHistoryRecord, lastStep) = try NoteHistRecord.makeObjectFrom(lines, startIndex: step)
                    ret.UniversalData[key]?.append(noteHistoryRecord);
                    step = lastStep
                }
            }
            
            return (ret, step)
        }
        catch {
            throw FormatError.unexpectedNoteIdPrefix
        }
    }
    
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

public class NoteList {
    public var Attributes = Dictionary<String, String>()
    public var Notes = Array<Note>()
    
    public func version() -> String {
        return self.Attributes["Version"] ?? ""
    }
    
    public func makeInstanceCode() -> String {
        var ret = ""
        
        ret.append("TSECRET:DATA:VERSION:")
        ret.append(version())
        ret.append("\n")
        
        ret.append("%%%%----SEGMENT-ATTRIBUTES----%%%%")
        ret.append("\n")
        ret.append("\(self.Attributes.count)")
        ret.append("\n")
        for kv in self.Attributes {
            ret.append("\(kv.key)=\(kv.value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")")
            ret.append("\n")
        }
                
        ret.append("%%%%----SEGMENT-NOTES----%%%%")
        ret.append("\n")
        ret.append("\(Notes.count)")
        ret.append("\n")
        for note in self.Notes {
            ret.append(note.makeInstanceCode())
        }

        ret.append("TSECRET:DATA:END")
        return ret
    }
    
    public static func makeObjectFrom(str: String, expectedVersion: String? = nil) throws -> NoteList {
        let ret = NoteList()
        let lines = str.split(separator: "\n")
        var step = 0
        
        var line = lines[step]
        let startTag = "TSECRET:DATA:VERSION:"
        if !line.starts(with: startTag) {
            throw FormatError.startTagIsNotExpectedOne
        }
        
        if let expectedVersion = expectedVersion {
            let version = StrUtil.left(line, length: startTag.count)
            if version != expectedVersion {
                throw FormatError.versionNumberIsNotSame
            }
        }
        
        step += 1
        line = lines[step]
        if line != "%%%%----SEGMENT-ATTRIBUTES----%%%%" {
            throw FormatError.segmentError1
        }
        
        ret.Attributes.removeAll()
        step += 1
        line = lines[step]
        let attributeCount = Int(line) ?? -1
        if attributeCount > 99999 || attributeCount < 0 {
            throw FormatError.attributeCountOverflow
        }
        for _ in 0..<attributeCount {
            step += 1
            line = lines[step];
            guard let pos = line.firstIndex(of: "=") else {
                throw FormatError.segmentError1
            }
            let key = line[line.startIndex..<pos]
            let val = line[line.index(pos, offsetBy: 1)..<line.endIndex]
            ret.Attributes[String(key)] = val.removingPercentEncoding
        }
        step += 1
        line = lines[step];
        if line != "%%%%----SEGMENT-NOTES----%%%%" {
            throw FormatError.segmentError2
        }

        step += 1
        line = lines[step];
        let noteCount = Int(line) ?? -1
        if noteCount > 99999 || noteCount < 0 {
            throw FormatError.noteCountOverflow
        }
        ret.Notes.removeAll()
        for _ in 0..<noteCount {
            let (note, lastStep) = try Note.makeObjectFrom(lines, startIndex: step)
            step = lastStep
            ret.Notes.append(note)
        }

        return ret
    }
}

enum FormatError : Error {
    case startTagIsNotExpectedOne
    case versionNumberIsNotSame
    case segmentError1
    case segmentError2
    case attributeCountOverflow
    case noteCountOverflow
    case unexpectedNoteIdPrefix
    case universaCountError
    case historyCountError
    case UnexpectedHistoryFormat
    case dateTimeFormatError
}
