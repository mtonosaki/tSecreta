//
//  ViewControllerDetail.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/02.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit

final class ViewControllerDetail : UIViewController, UITextFieldDelegate, UITextViewDelegate {

    var note: Note? = nil

    @IBOutlet weak var textRubi: UITextField!
    @IBOutlet weak var textCaption: UITextField!
    @IBOutlet weak var textAccountId: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textMemo: UITextView!
    @IBOutlet weak var filterHome: UISwitch!
    @IBOutlet weak var filterWork: UISwitch!
    @IBOutlet weak var filterDeleted: UISwitch!
    
    // Tap on white space to hide keyboard
    @IBAction func didTapViewSpace(_ sender: UITapGestureRecognizer) {
        textRubi.resignFirstResponder()
        textCaption.resignFirstResponder()
        textAccountId.resignFirstResponder()
        textPassword.resignFirstResponder()
        textEmail.resignFirstResponder()
        textMemo.resignFirstResponder()
        filterHome.resignFirstResponder()
        filterWork.resignFirstResponder()
        filterDeleted.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        // for auto "Next" at Return key
        textRubi.delegate = self
        textCaption.delegate = self
        textAccountId.delegate = self
        textPassword.delegate = self
        textEmail.delegate = self
        textMemo.delegate = self
        
        textRubi.text = note?.getValue(field: .captionRubi)
        textCaption.text = note?.getValue(field: .caption)
        textAccountId.text = note?.getValue(field: .accountID)
        textPassword.text = note?.getValue(field: .password)
        textEmail.text = note?.getValue(field: .email)
        textMemo.text = note?.getValue(field: .memo)
        filterDeleted.isOn = note?.getFlag(.isDeleted) ?? false
        filterHome.isOn = note?.getFlag(.isFilterHome) ?? false
        filterWork.isOn = note?.getFlag(.isFilterWork) ?? false
    }
    
    @IBAction func didHomeFilterValueChanged(_ sender: Any) {
        note?.setFlag(.isFilterHome, filterHome.isOn)
    }
    @IBAction func didWorkFilterValueChanged(_ sender: Any) {
        note?.setFlag(.isFilterWork, filterWork.isOn)
    }
    @IBAction func didDeletedFilterValueChanged(_ sender: Any) {
        note?.setFlag(.isDeleted, filterDeleted.isOn)
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == textEmail {
            if let text = textEmail.text {
                note?.setValue(field: .email, text: text)
                return
            }
        }
        if textField == textPassword {
            if let text = textPassword.text {
                note?.setValue(field: .password, text: text)
                return
            }
        }
        if textField == textAccountId {
            if let text = textAccountId.text {
                note?.setValue(field: .accountID, text: text)
                return
            }
        }
        if textField == textCaption {
            if let text = textCaption.text {
                note?.setValue(field: .caption, text: text)
                return
            }
        }
        if textField == textRubi {
            if let text = textRubi.text {
                note?.setValue(field: .captionRubi, text: text)
                return
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textMemo == textView {
            if let text = textMemo.text {
                note?.setValue(field: .memo, text: text)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier != "ToHistory" {
            return
        }
        guard let vc = segue.destination as? ViewControllerHistoryTabControl
            , let note = note
        else {
            return
        }
        vc.universalData = note.UniversalData
    }
}
