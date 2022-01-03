//
//  ViewControllerList.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit

final class ViewControllerList : UITableViewController {
    
    public var noteList: NoteList? = nil
    public var userObjectId: String = ""
    private var noteTarget: Array<Note>? = nil
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
    }
    
    func resetList() {
        if noteTarget == nil {
            let notes = noteList?.Notes
            if let notes = notes {
                noteTarget  = notes.filter{ $0.CheckDeleted() == false }.sorted(by: {
                    let rubia = ($0.GetLatest(key: "CaptionRubi") ?? $0.GetLatest(key: "Caption") ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    let rubib = ($1.GetLatest(key: "CaptionRubi") ?? $1.GetLatest(key: "Caption") ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    return rubia < rubib
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resetList()
        return noteTarget?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        resetList()
        let note = noteTarget?[indexPath.row]
        if let note = note {
            let caption = note.GetLatest(key: "Caption") ?? ""
            cell.textLabel?.text = caption
            cell.detailTextLabel?.text = note.GetLatest(key: "AccountID")
            cell.imageView?.image = UIImage(named: findBrandLogo(name: caption))
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let actionId = UIContextualAction(
            style: .normal,
            title:  "ID",
            handler: {
                (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
                guard let note = self.noteTarget?[indexPath.row] else {
                    success(false)
                    return
                }
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
                guard let note = self.noteTarget?[indexPath.row] else {
                    success(false)
                    return
                }
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
        
        let actionDelete = UIContextualAction(
            style: .normal,
            title: "Delete",
            handler: {
                (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
                //                let note = self.noteTarget?[indexPath.row]
                //                guard let note = note else {
                //                    success(false)
                //                    return
                //                }
                //                note.SetDeletedFlag(true)
                //                tableView.deleteRows(at: [indexPath], with: .automatic )
                //                self.resetList()
                success(true)
            }
        )
        //actionDelete.image = UIImage(named: "trash")
        actionDelete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [actionDelete, actionPw, actionId])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? ViewControllerDetail else {
                    fatalError("\(segue.destination)")
                }
                guard let note = self.noteTarget?[indexPath.row] else {
                    return
                }
                destination.note = note
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
