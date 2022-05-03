//
//  ViewControllerDetail.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/02.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit
import PhotosUI

final class ViewControllerDetail : UIViewController, UITextFieldDelegate, UITextViewDelegate, UIContextMenuInteractionDelegate {

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
    @IBOutlet weak var imageLogo: UIImageView!
    
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

        if let note = note, let logoFileName = note.getValue(field: .logoFilename) {
            if let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(logoFileName) {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    imageLogo.image = image
                }
            }
        }
        
        // Context menu on ImageLogo
        imageLogo.isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        imageLogo.addInteraction(interaction)
    }
    
    func makeContextMenu() -> UIMenu {
        let actionSet = UIAction(title: "Set", image: UIImage(systemName: "photo")) {
            action in
            self.setIconUI()
        }
        let actionRemove = UIAction(title: "Remove", image: UIImage(systemName: "pip.remove")) {
            action in
            self.removeIcon()
        }
        return UIMenu(title: "Logo Actions", children: [actionSet, actionRemove])
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: {
            suggestedActions in
            return self.makeContextMenu()
        })
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
                note?.setValueToHistory(field: .email, text: text)
                return
            }
        }
        if textField == textPassword {
            if let text = textPassword.text {
                note?.setValueToHistory(field: .password, text: text)
                return
            }
        }
        if textField == textAccountId {
            if let text = textAccountId.text {
                note?.setValueToHistory(field: .accountID, text: text)
                return
            }
        }
        if textField == textCaption {
            if let text = textCaption.text {
                note?.setValueToHistory(field: .caption, text: text)
                return
            }
        }
        if textField == textRubi {
            if let text = textRubi.text {
                note?.setValueToHistory(field: .captionRubi, text: text)
                return
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textMemo == textView {
            if let text = textMemo.text {
                note?.setValueToHistory(field: .memo, text: text)
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

extension ViewControllerDetail: PHPickerViewControllerDelegate  {

    func removeIcon() {
        note?.removeValueNoHistory(field: .logoFilename)
        imageLogo.image = UIImage(named: "cellNoImg")
    }

    func setIconUI() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.images
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selection = .ordered
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let result = results.first else {
            return
        }
        let itemProvider = result.itemProvider
        guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        guard let note = note else {
            return
        }
        itemProvider.loadObject(ofClass: UIImage.self) {
            [weak self] image, error in
            
            guard let self = self else {
                return
            }
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.imageLogo.image = image
                }
                
                Task.init {
                    let message = await saveLogoPicture(image: image, defaultName: result.assetIdentifier, note: note)
                    if let message = message {
                        DispatchQueue.main.async {
                            self.showToast(message: message, color: .darkGray, view: self.view)
                        }
                    }
                }
            }
        }
    }
}
