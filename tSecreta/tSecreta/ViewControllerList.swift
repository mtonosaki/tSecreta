//
//  ViewControllerList.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit

final class ViewControllerList : UITableViewController {
    
    public var binaryData: String?   // encrypted data chnk
    
    private var reminders: [String] = [
        "ラジオ体操する",
        "牛乳搾り",
        "珈琲焙煎",
        "珈琲淹れる"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        reminders.append(binaryData!)
        tableView.allowsSelection = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        cell.textLabel?.text = reminders[indexPath.row]
        return cell
    }

    // Support swipe and [DEL]
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        reminders.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic )
    }
}
