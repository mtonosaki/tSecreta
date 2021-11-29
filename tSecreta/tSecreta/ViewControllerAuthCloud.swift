//
//  ViewControllerAuthentication.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import MSAL

// AzureAD authentication functions
extension ViewController {
    
    func initCloudAuthentication() {
        // Azure Active Directory preparation
        do {
            try self.initMSAL()
        } catch let error {
            print("Unable to create Application context \(error)");
        }
        self.loadCurrentAccount()
        self.platformViewDidLoadSetup()

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
        //TODO: Update Logout button enabled here: account != nil
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
    
    func startCloudAuthentication(_ sender: Any) {
        self.loadCurrentAccount {
            (account) in
            guard let currentAccount = account else {
                self.acquireTokenInteractively()
                return
            }
            self.acquireTokenSilently(currentAccount)
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
    
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else {
            return
        }
        guard let webViewParameters = self.webViewParameters else {
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
                print("Could not acquire token: \(error)")
                return
            }
            guard let result = result else {
                print("Could not acquire token: No result returned")
                return
            }
            // #4
            self.accessToken = result.accessToken
            print("Access token is \(self.accessToken)")
            self.updateCurrentAccount(account: result.account)
            self.getContentWithToken()
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        guard let applicationContext = self.applicationContext else {
            return
        }
        let parameters = MSALSilentTokenParameters(scopes: self.aadScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters){
            (result, error) in
            if let error = error {
                let nsError = error as NSError
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                print("Could not acquire token silently: \(error)")
                return
            }
            guard let result = result else {
                print("Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            print("Refreshed Access token is \(self.accessToken)")
            //self.updateSignOutButton(enabled: true)
            self.getContentWithToken()
        }
    }
    
    func getContentWithToken() {
        let graphURI = getGraphEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                print("Couldn't get graph result: \(error)")
                return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                print("Couldn't deserialize result JSON")
                return
            }
            print("Result from Graph: \(result))")
        }.resume()
    }
    
    @objc func signOut(_ sender: AnyObject) {
        guard let applicationContext = self.applicationContext else {
            return
        }
        guard let account = self.currentAccount else {
            return
        }
        
        do {
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParameters!)
            signoutParameters.signoutFromBrowser = false
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {
                (success, error) in
                if let error = error {
                    print("Couldn't sign out account with error: \(error)")
                    return
                }
                print("Sign out completed successfully")
                self.accessToken = ""
                self.updateCurrentAccount(account: nil)
            })
        }
    }
}

