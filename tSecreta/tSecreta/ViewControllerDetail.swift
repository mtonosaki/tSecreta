//
//  ViewControllerDetail.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/02.
//

import UIKit

final class ViewControllerDetail : UIViewController, UITextFieldDelegate {
    public var note: Note? = nil

    @IBOutlet weak var textRubi: UITextField!
    @IBOutlet weak var textCaption: UITextField!
    @IBOutlet weak var textAccountId: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textMemo: UITextView!
    
    // Tap on white space to hide keyboard
    @IBAction func didTapViewSpace(_ sender: UITapGestureRecognizer) {
        textRubi.resignFirstResponder()
        textCaption.resignFirstResponder()
        textAccountId.resignFirstResponder()
        textPassword.resignFirstResponder()
        textEmail.resignFirstResponder()
        textMemo.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        // for auto "Next" at Return key
        textRubi.delegate = self
        textCaption.delegate = self
        textAccountId.delegate = self
        textPassword.delegate = self
        textEmail.delegate = self
        
        textRubi.text = note?.GetLatest(key: "CaptionRubi")
        textCaption.text = note?.GetLatest(key: "Caption")
        textAccountId.text = note?.GetLatest(key: "AccountID")
        textPassword.text = note?.GetLatest(key: "Password")
        textEmail.text = note?.GetLatest(key: "Email")
        textMemo.text = note?.GetLatest(key: "Memo")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let nextTag = textField.tag + 1
        if let nextTextField = self.view.viewWithTag(nextTag) {
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // TODO: Persist edited text
    }
    
    @IBAction func didTappedShowPassword(_ sender: Any) {
        textPassword.isSecureTextEntry = !textPassword.isSecureTextEntry
    }
    
    @IBAction func didTapCopyAccount(_ sender: Any) {
        if let text = textAccountId.text {
            UIPasteboard.general.string = text
            showToast(message: "Copy Account ID", color: UIColor.systemGreen, view: self.parent?.view ?? self.view)

        }
    }
    
    @IBAction func didTapCopyPassword(_ sender: Any) {
        if let text = textPassword.text {
            UIPasteboard.general.string = text
            showToast(message: "! Copy Password !", color: UIColor.systemOrange, view: self.parent?.view ?? self.view)

        }
    }
    
    @IBAction func didTapCopyEmail(_ sender: Any) {
        if let text = textEmail.text {
            UIPasteboard.general.string = text
            showToast(message: "Copy e-mail", color: UIColor.systemBlue, view: self.parent?.view ?? self.view)
        }
    }
    
    @IBAction func didTapClearClipboard(_ sender: Any) {
        UIPasteboard.general.string = nil
        showToast(message: "Clear clipboard", color: UIColor.darkGray, view: self.parent?.view ?? self.view)
    }
}
