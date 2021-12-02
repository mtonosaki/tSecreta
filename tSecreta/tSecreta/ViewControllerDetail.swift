//
//  ViewControllerDetail.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/02.
//

import UIKit

final class ViewControllerDetail : UIViewController, UITextFieldDelegate, UITextViewDelegate {
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
        textMemo.delegate = self
        
        textRubi.text = note?.GetLatest(key: "CaptionRubi")
        textCaption.text = note?.GetLatest(key: "Caption")
        textAccountId.text = note?.GetLatest(key: "AccountID")
        textPassword.text = note?.GetLatest(key: "Password")
        textEmail.text = note?.GetLatest(key: "Email")
        textMemo.text = note?.GetLatest(key: "Memo")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textEmail {
            if let text = textEmail.text {
                note?.SetToLatest(key: "Email", text: text)
                return
            }
        }
        if textField == textPassword {
            if let text = textPassword.text {
                note?.SetToLatest(key: "Password", text: text)
                return
            }
        }
        if textField == textAccountId {
            if let text = textAccountId.text {
                note?.SetToLatest(key: "AccountID", text: text)
                return
            }
        }
        if textField == textCaption {
            if let text = textCaption.text {
                note?.SetToLatest(key: "Caption", text: text)
                return
            }
        }
        if textField == textRubi {
            if let text = textRubi.text {
                note?.SetToLatest(key: "CaptionRubi", text: text)
                return
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textMemo == textView {
            if let text = textMemo.text {
                note?.SetToLatest(key: "Memo", text: text)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let nextTag = textField.tag + 1
        if let nextTextField = self.view.viewWithTag(nextTag) {
            nextTextField.becomeFirstResponder()
        }
        return true
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
