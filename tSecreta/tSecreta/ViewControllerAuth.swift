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
    
    @IBOutlet weak var kurukuru: UIActivityIndicatorView!
    @IBOutlet weak var reAuthButton: UIButton!
    @IBOutlet weak var logoffButton: UIButton!
    var logView: LogView!
    var noteList: NoteList? = nil
    
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
                (successCA, errorMessageCA) in
                
                if successCA {
                    DispatchQueue.main.async {
                        self.logoffButton.isEnabled = true
                        self.reAuthButton.isEnabled = true
                    }
                    self.startDeviceAuthentication() {
                        (successDA, errorMessageDA) in
                        
                        if successDA  {
                            self.addInfo("Device authenticated successfully!" )
                            
                            self.downloadCloudSecretData() {
                                (successDL, errMessageDL, newNoteList) in
                                
                                if successDL {
                                    self.addInfo("OK.")
                                    self.noteList = newNoteList
                                    DispatchQueue.main.async {
                                        self.logoffButton.isEnabled = true
                                        self.moveToListView()
                                    }
                                } else {
                                    self.addError("Cloud download error")
                                }
                                return;
                            }
                        } else {
                            self.addWarning("Device authentication Error")
                        }
                    }
                } else {
                    self.addWarning("Authentication \(errorMessageCA ?? "no message")")
                }
            }
        }
    }
    
    private func downloadCloudSecretData(callback: @escaping (Bool, String?, NoteList?) ->  Void) {

        guard let idraw = currentAccount?.identifier else {
            callback(false, "To download, authenticate first.", nil)
            return
        }
        DispatchQueue.main.async {
            self.kurukuru.isHidden = false
            self.kurukuru.startAnimating()
        }
        let id = idraw.components(separatedBy: ".")[0]
        self.addInfo("Downloading...")

        DownloadText(userObjectId: id){
            (success, text) in

            guard let safeText = text else {
                self.addError("Cloud data downloading error")
                DispatchQueue.main.async {
                    self.kurukuru.stopAnimating()
                }
                return
            }
            if success {
                self.addInfo("Downloaded \(safeText.count) base64 length")
                self.addInfo("Decoding encrypted data...")
                let maybeJsonStr = EncryptUtils.rijndaelDecode(base64sec: safeText, filter: id)
                guard let jsonStr = maybeJsonStr else {
                    self.addError("Downloaded json is broken.")
                    DispatchQueue.main.async {
                        self.kurukuru.stopAnimating()
                    }
                    return
                }
                guard let jsonData = jsonStr.data(using: .utf8) else {
                    showToast(message: "Json Decoding error", color: UIColor.red, view: self.view)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(.iso8601PlusMilliSeconds)
                    let notes = try decoder.decode(NoteList.self, from: jsonData)
                    
                    callback(true, nil, notes)
                    DispatchQueue.main.async {
                        self.kurukuru.stopAnimating()
                    }
                    return
                }
                catch let ex {
                    self.addError(ex.localizedDescription)
                }
            } else {
                self.addError(safeText)
            }
            DispatchQueue.main.async {
                self.kurukuru.stopAnimating()
            }
            callback(success, safeText, nil)
        }
    }
    
    private func moveToListView() {
        self.performSegue(withIdentifier: "ToList", sender: self)
    }

    // Set data to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToList" {
            let listView = segue.destination as! ViewControllerList
            listView.noteList = self.noteList
            if let idraw = currentAccount?.identifier {
                let id = idraw.components(separatedBy: ".")[0]
                listView.userObjectId = id
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

