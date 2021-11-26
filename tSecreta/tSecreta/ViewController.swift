//
//  ViewController.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/24.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit
import MSAL

class ViewController: UIViewController {

    @IBOutlet weak var imageLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to open azuread authentication
        let adconfig = MySecret()
        let config = MSALPublicClientApplicationConfig(clientId: adconfig.clientId)
        if let application = try? MSALPublicClientApplication(configuration: config){
            #if os(iOS)
                let webviewParameters = MSALWebviewParameters(authPresentationViewController: self)
            #else
                let webviewParameters = MSALWebviewParameters()
            #endif
            
            let interactiveParameters = MSALInteractiveTokenParameters(scopes: adconfig.scopes, webviewParameters: webviewParameters)
            application.acquireToken(with: interactiveParameters, completionBlock: {
                (result, error) in
                guard let authResult = result, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                // Get access token from result
                let accessToken = authResult.accessToken
                
                // You will want to get the account identifier to retreeve and reuse the account for later acquireToken calls
                let accountIdentifier = authResult.account.identifier
            })
        } else {
            print("Unable to create applicaiton")
        }
                
        // Attached logo image from AppIcon
        // TODO: precision version image
        let img = UIImage(named: "AppIcon")
        imageLogo.image = img;
    }
}

