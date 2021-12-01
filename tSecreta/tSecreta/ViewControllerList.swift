//
//  ViewControllerList.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit

final class ViewControllerList : UITableViewController {

    public var noteList: NoteList? = nil
    private var noteTarget: Array<Note>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
    }
    
    func resetList() {
        if noteTarget == nil {
            let notes = noteList?.Notes
            if let notes = notes {
                noteTarget  = notes.filter{ $0.CheckDeleted() == false }
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
            cell.textLabel?.text = note.GetLatest(key: "Caption")
        }
        return cell
    }

    // Support swipe and [DEL]
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //resetList()
//        reminders.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .automatic )
//    }
}
