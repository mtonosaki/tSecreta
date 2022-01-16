//
//  ViewControllerDeviceAuthentication.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//

import UIKit
import LocalAuthentication

extension ViewControllerAuth {
    
    func startDeviceAuthentication(callback: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        let reason = "This app uses Touch ID / Facd ID to secure your data."
        var authError: NSError?
        
        // deviceOwnerAuthentication = Face(Touch) ID + PIN
        // deviceOwnerAuthenticationWithBiometrics = Face(Touch) ID only
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                (success, error) in
                if success {
                    callback(true, nil)
                } else {
                    let message = error?.localizedDescription ?? "Failed to authenticate"
                    callback(false, message)
                }
            }
        } else {
            let message = authError?.localizedDescription ?? "canEvaluatePolicy returned false"
            callback(false, message)
        }
    }
}
