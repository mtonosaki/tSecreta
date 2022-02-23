//
//  ViewControllerHistoryTabControl.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2022/01/16.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit

class ViewControllerHistoryTabControl : UITabBarController, UITabBarControllerDelegate {
    
    var universalData = Dictionary<String, Array<NoteHistRecord>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        if let vc = viewControllers![tabBarController?.selectedIndex ?? 0] as? ViewControllerHistory {
            vc.universalData = universalData
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        if let vc = viewController as? ViewControllerHistory {
            vc.universalData = universalData
        }
    }
}
