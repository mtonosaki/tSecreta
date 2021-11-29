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
    @IBOutlet weak var reAuthButton: UIButton!
    
    let aadScopes = ["user.read"];  // Graph API Scope
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParameters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Attached logo image from AppIcon
        let img = UIImage(named: "Logo")
        imageLogo.image = img;
        
        // Device Authenticaiton support
        self.initDeviceAuthentication()
        
        // AzureAD Authentication support
        self.initCloudAuthentication()
        // TODO: startCloudAuthentication(sender) after device authentication
    }
    
    @IBAction func testButtonTouchUpInside(_ sender: Any) {
        startDeviceAuthentication(sender) {
            (success, errorMessage) in
            if success  {
                print( "Device authenticated successfully!" )
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ToList", sender: self)
                }
                
            } else {
                print( "Device authentication \(errorMessage ?? "error")")
                return
            }
        }
//        startCloudAuthentication(sender)
        
    }
}

