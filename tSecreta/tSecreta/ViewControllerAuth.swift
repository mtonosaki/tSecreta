//
//  ViewController.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/24.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit
import MSAL
import CryptoSwift

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

//        do {
//            let cn = try AZSCloudStorageAccount(fromConnectionString: MySecret().azureBlob.AzureStorageConnectionString)
//            let blobClient = cn.getBlobClient()
//            let blobContainer = blobClient.containerReference(fromName: "tsecret")
//            let blob = blobContainer.blockBlobReference(fromName: "MainData.\(id).dat")
//            blob.downloadToText(){
//                (error, text) in
//                if let error = error {
//                    self.addError(error.localizedDescription)
//                    callback(false, error.localizedDescription)
//                    return
//                }
//                if let base64sec = text {
//                    self.addInfo("Downloaded \(base64sec.count) characters")
//                    
//                    let secParam = MySecret().key
//                    let f1 = Character(String(base64sec.prefix(1)))
//                    let ivN = base64sec.distance(from:base64sec.startIndex, to:secParam.TEXTSET64.firstIndex(of: f1)!)
//                    let iv = base64sec.Mid(start:1, len:ivN + secParam.IVNPP).data(using:.ascii)
//                    let base64secData = base64sec.Mid(start:ivN + iv!.count + 1).data(using:.ascii)!
//                    let keyScrambled = fusionString(base64str: secParam.KEY, filter: id, textset64: secParam.TEXTSET64)
//                    
//                    
////                    let r = Rijndael(key: keyScrambled.data(using: .ascii)!, mode: .cbc)!
////                    let plainData = r.decrypt(data: sec, blockSize: 16, iv: iv)
//                    
//                    callback(true, nil)
//                }
//            }
//        }
//        catch let ex {
//            addFatal("Azue Error \(ex.localizedDescription)")
//        }
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

