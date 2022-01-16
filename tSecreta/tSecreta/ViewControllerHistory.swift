//
//  HistoryViewController.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2022/01/16.
//  MIT License (c)2022 Manabu Tonosaki all rights reserved.

import UIKit

class ViewControllerHistory : UITableViewController {
    
    var universalData = Dictionary<String, Array<NoteHistRecord>>()
    var targetField: FieldNames = .na
    
    override func viewDidLoad() {
        
        tableView.allowsSelection = true
        guard let title = tabBarItem.title
                , let fieldName = FieldNames(rawValue: title)
        else {
            fatalError("tabItem.title should be set from FieldNames")
        }
        targetField = fieldName
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let hist = universalData[targetField.rawValue] else {
            return 0
        }
        return hist.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        guard let hist = universalData[targetField.rawValue] else {
            return cell
        }
        let record = hist[indexPath.row]

        cell.textLabel?.text = record.Value
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        cell.detailTextLabel?.text = dateFormatter.string(from: record.DT)
        return cell
    }
}
