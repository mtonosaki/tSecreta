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
    
    @IBOutlet weak var reAuthButton: UIButton!
    @IBOutlet weak var logoffButton: UIButton!
    
    let aadScopes = ["user.read"];  // Graph API Scope
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParameters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticate()
    }
    
    // Need main thread
    private func authenticate() {
        
        logoffButton.isEnabled = false
        reAuthButton.isEnabled = false
        
        // AzureAD Authentication support
        if self.initCloudAuthentication() {
            self.startCloudAuthentication() {
                (success, errorMessage) in
                
                if success {

                    self.startDeviceAuthentication() {
                        (success, errorMessage) in

                        if success  {
                            print( "Device authenticated successfully!" )

                            // Move to List View
                            DispatchQueue.main.async {
                                self.logoffButton.isEnabled = true
                                self.performSegue(withIdentifier: "ToList", sender: self)
                                return;
                            }
                        } else {
                            print( "Device authentication \(errorMessage ?? "error")")
                        }
                        DispatchQueue.main.async {
                            self.reAuthButton.isEnabled = true
                        }
                    }
                } else {
                    print("Authentication Error")
                }
            }
        }
    }
    
    @IBAction func reAuthenticationButtonTouchUpInside(_ sender: Any) {
        authenticate()
    }
    
    @IBAction func logoffButtonTouchUpInside(_ sender: Any) {
        self.signOut(){
            (success, errMessage) in
            
            if success {
                DispatchQueue.main.async {
                    self.logoffButton.isEnabled = false
                    self.reAuthButton.isEnabled = true
                }
            }
        }
    }
}

