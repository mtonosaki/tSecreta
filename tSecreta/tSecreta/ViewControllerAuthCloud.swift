//
//  ViewControllerAuthentication.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import MSAL

// AzureAD authentication functions
extension ViewController {
    
    func initCloudAuthentication() -> Bool {
        // Azure Active Directory preparation
        do {
            try self.initMSAL()
        } catch let error {
            print("Unable to create Application context \(error)");
            return false
        }
        self.loadCurrentAccount()
        self.platformViewDidLoadSetup()
        return true
    }
    // Init for AzureAD authentication
    func initMSAL() throws {
        guard let authorityURL = URL(string: "https://login.microsoftonline.com/common") else {
            print("Unable to create authority URL!")
            return
        }
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: MySecret().azureAD.kClientID, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.initWebViewParams()
    }
    
    func initWebViewParams() {
#if os(iOS)
        self.webViewParameters = MSALWebviewParameters(authPresentationViewController: self)
#else
        self.webViewParameters = MSALWebviewParameters()
#endif
    }
    
    func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
    }
    
    func platformViewDidLoadSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(appCameToForeGround(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appCameToForeGround(notification: Notification) {
        self.loadCurrentAccount()
    }
    
    func getGraphEndpoint() -> String {
        let kGraphEndpoint = "https://graph.microsoft.com/"
        return kGraphEndpoint.hasSuffix("/") ? (kGraphEndpoint + "v1.0/me/") : (kGraphEndpoint + "/v1.0/me/");
    }
    
    func startCloudAuthentication(callback: @escaping (Bool, String?) -> Void) {
        self.loadCurrentAccount {
            (account) in
            
            guard let currentAccount = account else {
                self.acquireTokenInteractively(callback: callback)
                return
            }
            self.acquireTokenSilently(currentAccount, callback: callback)
        }
    }
    
    typealias AccountCompletion = (MSALAccount?) -> Void
    
    func loadCurrentAccount(completion: AccountCompletion? = nil) {
        
        guard let applicationContext = self.applicationContext else {
            return
        }
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: {
            (currentAccount, previousAccount, error) in
            if let error = error {
                print("Couldn't query current account with error: \(error)")
                return
            }
            
            if let currentAccount = currentAccount {
                print("Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")
                
                self.updateCurrentAccount(account: currentAccount)
                
                if let completion = completion {
                    completion(self.currentAccount)
                }
                
                return
            }
            
            print("Account signed out. Updating UX")
            self.accessToken = ""
            self.updateCurrentAccount(account: nil)
            
            if let completion = completion {
                completion(nil)
            }
        })
    }
    
    func acquireTokenInteractively(callback: @escaping (Bool, String?) -> Void) {
        
        DispatchQueue.main.async {
            guard let applicationContext = self.applicationContext else {
                callback(false, nil)
                return
            }
            guard let webViewParameters = self.webViewParameters else {
                callback(false, nil)
                return
            }
        
            // #1
            let parameters = MSALInteractiveTokenParameters(scopes: self.aadScopes, webviewParameters: webViewParameters)
            parameters.promptType = .selectAccount
            
            // #2
            applicationContext.acquireToken(with: parameters) {
                (result, error) in
                // #3
                if let error = error {
                    callback(false, "Could not acquire token: \(error)")
                    return
                }
                guard let result = result else {
                    callback(false, "Could not acquire token: No result returned")
                    return
                }
                // #4
                self.accessToken = result.accessToken
                self.updateCurrentAccount(account: result.account)
                self.getContentWithToken(callback: callback)
            }
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!, callback: @escaping (Bool, String?) -> Void) {
        guard let applicationContext = self.applicationContext else {
            callback(false, nil)
            return
        }
        let parameters = MSALSilentTokenParameters(scopes: self.aadScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters){
            (result, error) in
            if let error = error {
                let nsError = error as NSError
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        self.acquireTokenInteractively(callback: callback)
                        return
                    }
                }
                callback(false, "Could not acquire token silently: \(error)")
                return
            }
            guard let result = result else {
                callback(false, "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            print("Refreshed Access token is \(self.accessToken)")
            self.getContentWithToken(callback: callback)
        }
    }
    
    func getContentWithToken(callback: @escaping (Bool, String?) -> Void) {
        let graphURI = getGraphEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                callback(false, "Couldn't get graph result: \(error)")
                return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                callback(false, "Couldn't deserialize result JSON")
                return
            }
            callback(true, "Result from Graph: \(result))")
        }.resume()
    }
    
    @objc func signOut(callback: @escaping (Bool, String?) -> Void) {
        guard let applicationContext = self.applicationContext else {
            callback(false, "Couldn't signout account now [1]")
            return
        }
        guard let account = self.currentAccount else {
            callback(false, "Couldn't signout account now [2]")
            return
        }
        
        do {
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParameters!)
            signoutParameters.signoutFromBrowser = false
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {
                (success, error) in
                if let error = error {
                    callback(false, "Couldn't sign out account with error: \(error)")
                    return
                }
                self.accessToken = ""
                self.updateCurrentAccount(account: nil)
                callback(true, nil)
            })
        }
    }
}

