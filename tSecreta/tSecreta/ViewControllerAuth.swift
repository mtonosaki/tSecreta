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
    var logView: LogView!
    
    // for AzureAD
    let aadScopes = ["user.read"];  // Graph API Scope
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParameters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLogView()        
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
                    DispatchQueue.main.async {
                        self.logoffButton.isEnabled = true
                        self.reAuthButton.isEnabled = true
                    }
                    self.startDeviceAuthentication() {
                        (success, errorMessage) in
                        
                        if success  {
                            self.addInfo("Device authenticated successfully!" )
                            
                            self.downloadCloudSecretData() {
                                (success, errMessage) in
                                
                                
                                
                                if success {
                                    DispatchQueue.main.async {
                                        self.logoffButton.isEnabled = true
                                        self.moveToListView()
                                    }
                                }
                                return;
                            }
                        } else {
                            self.addWarning("Device authentication \(errorMessage ?? "error")")
                        }
                    }
                } else {
                    self.addWarning("Authentication Error")
                }
            }
        }
    }
    
    private func downloadCloudSecretData(callback: @escaping (Bool, String?) ->  Void) {

        guard let idraw = currentAccount?.identifier else {
            callback(false, "To download, authenticate first.")
            return
        }
        let id = idraw.components(separatedBy: ".")[0]
        self.addInfo("Downloading...")

        DownloadText(userObjectId: id){
            (success, text) in

            guard let safeText = text else {
                self.addError("Cloud data downloading error")
                return
            }
            if success {
                self.addInfo("Downloaded \(safeText.count) base64 length")
                let maybeJsonStr = EncryptUtils.decode2(base64sec: safeText, filter: id)
                guard let jsonStr = maybeJsonStr else {
                    self.addError("Downloaded json is broken.")
                    return
                }
                let jsonData = jsonStr.data(using: .utf8)
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(.iso8601PlusMilliSeconds)
                    let notes = try decoder.decode(NoteList.self, from: jsonData!)
                    print( notes.Notes.count )
                }
                catch let ex {
                    self.addError(ex.localizedDescription)
                }
                

            } else {
                self.addError(safeText)
            }
            callback(success, safeText)
        }
    }
    
    private func moveToListView() {
        self.performSegue(withIdentifier: "ToList", sender: self)
    }

    // Set data to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToList" {
            let listView = segue.destination as! ViewControllerList
            listView.binaryData = currentAccount?.username
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

