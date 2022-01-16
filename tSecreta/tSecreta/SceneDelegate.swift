//
//  SceneDelegate.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/24.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit
import MSAL

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    // for AzureAD
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

        guard let urlContext = URLContexts.first else {
            return
        }
        let url = urlContext.url
        let sourceApp = urlContext.options.sourceApplication
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApp)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {

    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {

    }
    
    func sceneWillResignActive(_ scene: UIScene) {

    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {

    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}

