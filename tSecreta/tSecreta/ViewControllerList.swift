//
//  ViewControllerList.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit
import Tono

final class ViewControllerList : UITableViewController {
    
    public var noteList: NoteList? = nil
    public var userObjectId: String = ""
    private var noteTarget: Array<Note>? = nil
    private var sectionNotes = Dictionary<String, Array<Note>>()
    private var sectionOrder = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        tableView.sectionIndexColor = UIColor.magenta
        tableView.sectionIndexTrackingBackgroundColor = UIColor.blue
        tableView.sectionIndexMinimumDisplayRowCount = 4
        resetList()
    }
    
    func resetList() {
        let notes = noteList?.Notes
        if let notes = notes {
            noteTarget  = notes.filter{ $0.CheckDeleted() == false }.sorted(by: {
                let rubia = ($0.GetLatest(key: "CaptionRubi") ?? $0.GetLatest(key: "Caption") ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let rubib = ($1.GetLatest(key: "CaptionRubi") ?? $1.GetLatest(key: "Caption") ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return rubia < rubib
            })
            sectionNotes = Dictionary(grouping: noteTarget!, by: { String($0.GetLatest(key: "CaptionRubi")?.first ?? ".") })
            sectionOrder = sectionNotes.keys.sorted(by: { $0 < $1 })
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionOrder
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        tableView.scrollToRow(at: [0, index], at: .top, animated: true)
        return index
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionOrder.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionOrder[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionNotes[sectionOrder[section]]?.count ?? 0
    }
    
    private func getNote(at indexPath: IndexPath) -> Note {
        guard let notes = sectionNotes[sectionOrder[indexPath.section]] else {
            fatalError()
        }
        let note = notes[indexPath.row]
        return note
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        let note = getNote(at: indexPath)
        let caption = note.GetLatest(key: "Caption") ?? ""
        cell.textLabel?.text = caption
        cell.detailTextLabel?.text = note.GetLatest(key: "AccountID")
        cell.imageView?.image = UIImage(named: findBrandLogo(name: caption))
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let actionId = UIContextualAction(
            style: .normal,
            title:  "ID",
            handler: {
                (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
                let note = self.getNote(at: indexPath)
                if let id = note.GetLatest(key: "AccountID") {
                    UIPasteboard.general.string = id
                    showToast(message: "Copy account ID", color: UIColor.systemGreen, view: self.parent?.view ?? self.view)
                    success(true)
                } else {
                    success(false)
                }
            }
        )
        //actionId.image = UIImage(named: "swipeId")
        actionId.backgroundColor = .systemGreen
        
        let actionPw = UIContextualAction(
            style: .normal,
            title:  "PW",
            handler: {
                (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
                let note = self.getNote(at: indexPath)
                if let pw = note.GetLatest(key: "Password") {
                    UIPasteboard.general.string = pw
                    showToast(message: "! Copy Password !", color: UIColor.systemOrange, view: self.parent?.view ?? self.view)
                    success(true)
                } else {
                    success(false)
                }
            }
        )
        //actionPw.image = UIImage(named: "swipePw")
        actionPw.backgroundColor = .systemOrange
        
//        let actionDelete = UIContextualAction(
//            style: .normal,
//            title: "Delete",
//            handler: {
//                (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
//                success(true)
//            }
//        )
//        //actionDelete.image = UIImage(named: "trash")
//        actionDelete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [actionPw, actionId])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? ViewControllerDetail else {
                    fatalError("\(segue.destination)")
                }
                destination.note = getNote(at: indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToDetail", sender: self)
    }
    
    @IBAction func didTapCloudSync(_ sender: Any) {
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(.iso8601PlusMilliSecondsJst)
            let jsonPlaneData = try encoder.encode(noteList!)
            let jsonPlane = String(data: jsonPlaneData, encoding: .utf8)!
                        
            let sec = EncryptUtils.rijndaelEncode(planeText: jsonPlane, filter: userObjectId)
            guard let sec = sec else {
                showToast(message: "JSON encoding error", color: UIColor.systemRed, view: self.parent?.view ?? self.view)
                return;
            }
            UploadText(text: sec, userObjectId: userObjectId) {
                (success, error) in
                
                if let error = error {
                    showToast(message: error, color: UIColor.systemRed, view: self.parent?.view ?? self.view)
                } else {
                    showToast(message: "Cloud Sync OK!", color: UIColor.blue, view: self.parent?.view ?? self.view)
                }
            }
        }
        catch let ex {
            showToast(message: ex.localizedDescription, color: UIColor.systemRed, view: self.parent?.view ?? self.view)
        }
    }
}
