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
    
    private func getNote(at indexPath: IndexPath) -> Note {
        guard let notes = sectionNotes[sectionOrder[indexPath.section]] else {
            fatalError()
        }
        let note = notes[indexPath.row]
        return note
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            case "openMenu":
                if let menu = segue.destination as? ViewControllerListMenu {
                    menu.delegate = self
                }
            case "ToDetail":
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
            case .none:
                break
            case .some(_):
                break
        }
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        let newNote = Note()
        newNote.setFlag(.isFilterHome, true)
        newNote.setFlag(.isFilterWork, true)
        noteList?.Notes.append(newNote)
        noteRequestedDetail = newNote
        performSegue(withIdentifier: "ToDetail", sender: self)
    }
}

extension ViewControllerList {
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
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        var isLogoLoaded = false
        if let logoFileName = note.getValue(field: .logoFilename) {
            if let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(logoFileName) {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    cell.imageLogo.image = image
                    isLogoLoaded  = true
                }
            }
        }
        if isLogoLoaded == false {
            cell.imageLogo.image = UIImage(named: "cellNoImg")
        }
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
        actionPw.backgroundColor = .systemOrange

        return UISwipeActionsConfiguration(actions: [actionPw, actionId])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToDetail", sender: self)
    }
}

extension ViewControllerList : HambergerMenuDelegate {
    
    func didTapBackToAuthentication() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didTapUploadToCloud() {
        
        do {
            let planeCode = noteList!.makeInstanceCode()
            let secureCode = EncryptUtils.rijndaelEncode(planeText: planeCode, filter: userObjectId)
            guard let secureCode = secureCode else {
                showToast(message: "JSON encoding error", color: UIColor.systemRed, view: self.parent?.view ?? self.view)
                return;
            }
            UploadText(text: secureCode, userObjectId: userObjectId) {
                (success, error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        self.showToast(message: error, color: UIColor.systemRed, view: self.parent?.view ?? self.view)
                    } else {
                        self.showToast(message: "Cloud Sync OK!", color: UIColor.blue, view: self.parent?.view ?? self.view)
                    }
                }
            }
        }
        catch let ex {
            self.showToast(message: ex.localizedDescription, color: UIColor.systemRed, view: self.parent?.view ?? self.view)
        }
    }
    
    func didTapSaveLogosToCloud() async {
        let notes = noteList?.Notes
        guard let notes = notes else {
            return
        }
        
        let cn = try? AZSCloudStorageAccount(fromConnectionString: MySecret().azureBlob.AzureStorageConnectionString)
        guard let cn = cn else {
            return
        }
        var savedFile = Dictionary<String, Bool>()
        let blobClient = cn.getBlobClient()
        let blobContainer = blobClient.containerReference(fromName: "tsecret-logo")
        guard let _ = try? await blobContainer.createContainerIfNotExists() else {
            debugPrint("Error on creatring azure blob container. \(blobContainer.name)")
            return
        }
        do {
            var uploadCount = 0
            for note in notes {
                guard let logoFileName = note.getValue(field: .logoFilename) else {
                    continue
                }
                if let _ = savedFile[logoFileName] {
                    continue
                }
                savedFile[logoFileName] = true
                guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(logoFileName) else {
                    debugPrint("Skipped to get an url of logo image in storage")
                    continue
                }
                guard let data = try? Data(contentsOf: url) else {
                    debugPrint("Skipped to read data from \(url.description)")
                    continue
                }
                let blob = blobContainer.blockBlobReference(fromName: "\(userObjectId)/\(logoFileName)")
                try await blob.upload(from: data)
                uploadCount += 1
                print("No.\(uploadCount) : Uploaded logo image \(logoFileName)")
            }
            if uploadCount > 0 {
                showToast(message: "\(uploadCount) images have been uploaded.", color: .darkGray, view: self.view)
            } else {
                showToast(message: "No logo image uploaded.", color: .darkGray, view: self.view)
            }
        }
        catch {
            showToast(message: "logo upload error", color: .darkGray, view: self.view)
        }
    }
    
    func didTapLoadAndMergeLogosFromCloud() async {
        
        guard let notes = noteList?.Notes else {
            return
        }
        let cn = try? AZSCloudStorageAccount(fromConnectionString: MySecret().azureBlob.AzureStorageConnectionString)
        guard let cn = cn else {
            return
        }
        var loadedFile = Dictionary<String, Bool>()
        let blobClient = cn.getBlobClient()
        let blobContainer = blobClient.containerReference(fromName: "tsecret-logo")
        guard let _ = try? await blobContainer.createContainerIfNotExists() else {
            debugPrint("Error on creatring azure blob container. \(blobContainer.name)")
            return
        }
        var downloadedCount = 0
        for note in notes {
            guard let logoFileName = note.getValue(field: .logoFilename) else {
                continue
            }
            if let _ = loadedFile[logoFileName] {
                continue
            }
            loadedFile[logoFileName] = true
            let blob = blobContainer.blockBlobReference(fromName: "\(userObjectId)/\(logoFileName)")
            if let data = try? await blob.downloadToData() {
                let message = await saveLogoPicture(imageData: data, filename: logoFileName, note: note)
                if let message = message {
                    print(message)
                } else {
                    downloadedCount += 1
                }
            }
        }
        if downloadedCount > 0 {
            showToast(message: "\(downloadedCount) images have been downloaded.", color: .darkGray, view: self.view)
            resetList()
            tableView.reloadData()
        } else {
            showToast(message: "No logo image downloaded.", color: .darkGray, view: self.view)
        }
    }
}
