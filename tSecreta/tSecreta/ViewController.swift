//
//  ViewController.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/24.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit
import MSAL

// Authentication Screen
class ViewController: UIViewController {
    
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var testButton: UIButton!
    
    let aadScopes = ["user.read"];  // Graph API Scope
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParameters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Attached logo image from AppIcon
        // TODO: precision version image
        let img = UIImage(named: "AppIcon")
        imageLogo.image = img;
        
        // AzureAD Authentication support
        self.initInstance()
    }
    
    @IBAction func testButtonTouchUpInside(_ sender: Any) {
        callGraphAPI(sender)
    }
}

