//
//  ViewControllerList.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit
import Tono

final class ViewControllerList : UITableViewController {
    
    @IBOutlet weak var filterSegment: UISegmentedControl!

    public var noteList: NoteList? = nil
    public var userObjectId: String = ""
    private var noteTarget: Array<Note>? = nil
    private var sectionNotes = Dictionary<String, Array<Note>>()
    private var sectionOrder = Array<String>()
    private var noteRequestedDetail: Note? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        tableView.sectionIndexColor = UIColor.magenta
        tableView.sectionIndexTrackingBackgroundColor = UIColor(red: 1, green: 1, blue: 0.75, alpha: 1)
        tableView.sectionIndexMinimumDisplayRowCount = 4
    }
    
    @IBAction func didFilterChanged(_ sender: Any) {
        resetList()
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        resetList()
        tableView.reloadData()
    }
    
    func getSectionName(_ note: Note) -> String {
        let c = note.getValue(field: .captionRubi)?.trimmingCharacters(in: .whitespacesAndNewlines).first
        return Japanese.def.Getあかさたな(String(c ?? "."))
    }
    
    enum Filters: Int {
        case Home = 0
        case Work = 1
        case Deleted = 2
        case All = 3
    }
    
    func resetList() {
        let notes = noteList?.Notes
        guard let notes = notes else {
            return
        }
        let filterMode = Filters(rawValue: filterSegment.selectedSegmentIndex) ?? .Home
        switch filterMode {
            case .Home:
                noteTarget  = notes
                    .filter{ $0.getFlag(.isDeleted) == false }
                    .filter{ $0.getFlag(.isFilterHome) == true }
            case .Work:
                noteTarget  = notes
                    .filter{ $0.getFlag(.isDeleted) == false }
                    .filter{ $0.getFlag(.isFilterWork) == true }
            case .Deleted:
                noteTarget  = notes
                    .filter{ $0.getFlag(.isDeleted) == true }
            default:
                noteTarget  = notes
        }
        noteTarget = noteTarget!.sorted(by: {
            let rubia = ($0.getValue(field: .captionRubi) ?? $0.getValue(field: .caption) ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let rubib = ($1.getValue(field: .captionRubi) ?? $1.getValue(field: .caption) ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return rubia < rubib
        })

        sectionNotes = Dictionary(grouping: noteTarget!, by: { getSectionName($0) })
        sectionOrder = sectionNotes.keys.sorted(by: { $0 < $1 })
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionOrder
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else {
            fatalError()
        }
        let note = getNote(at: indexPath)
        let caption = note.getValue(field: .caption) ?? ""
        cell.labelTitle.text = caption
        cell.labelSubtitle.text = note.getValue(field: .accountID)
        cell.imageFilterHome.layer.opacity = note.getFlag(.isFilterHome) ? 1.0 : 0.25
        cell.imageFilterWork.layer.opacity = note.getFlag(.isFilterWork) ? 1.0 : 0.25
        cell.imageFilterDeleted.layer.opacity = note.getFlag(.isDeleted) ? 1.0 : 0.25
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
                if let id = note.getValue(field: .accountID) {
                    UIPasteboard.general.string = id
                    self.showToast(message: "Copy account ID", color: UIColor.systemGreen, view: self.parent?.view ?? self.view)
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
                if let pw = note.getValue(field: .password) {
                    UIPasteboard.general.string = pw
                    self.showToast(message: "! Copy Password !", color: UIColor.systemOrange, view: self.parent?.view ?? self.view)
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
            guard let destination = segue.destination as? ViewControllerDetail else {
                fatalError("\(segue.destination)")
            }
            if noteRequestedDetail != nil {
                destination.note = noteRequestedDetail
                noteRequestedDetail = nil
                return
            }
            if let indexPath = self.tableView.indexPathForSelectedRow {
                destination.note = getNote(at: indexPath)
                return
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
                    self.showToast(message: error, color: UIColor.systemRed, view: self.parent?.view ?? self.view)
                } else {
                    self.showToast(message: "Cloud Sync OK!", color: UIColor.blue, view: self.parent?.view ?? self.view)
                }
            }
        }
        catch let ex {
            self.showToast(message: ex.localizedDescription, color: UIColor.systemRed, view: self.parent?.view ?? self.view)
        }
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        let newNote = Note()
        noteList?.Notes.append(newNote)
        noteRequestedDetail = newNote
        performSegue(withIdentifier: "ToDetail", sender: self)
    }
 }
