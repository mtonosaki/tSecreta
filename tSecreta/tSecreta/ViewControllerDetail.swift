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
    let logoDic = UserDefaults(suiteName: "com.tomarika.tSecreta.logourl")

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

        if let note = note, let logoFileName = logoDic?.string(forKey: note.ID ) {
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

extension ViewControllerDetail: PHPickerViewControllerDelegate  {

    func removeIcon() {
        if let logoDic = logoDic, let note = note {
            logoDic.removeObject(forKey: note.ID)
            imageLogo.image = UIImage(named: "cellNoImg")
        }
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
        guard let assetIdentifier = result.assetIdentifier else {
            return
        }
        let itemProvider = result.itemProvider
        guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return;
        }
        itemProvider.loadObject(ofClass: UIImage.self) {
            [weak self] image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self?.imageLogo.image = image
                    self?.saveLogoPicture(image: image, assetIdentifier: assetIdentifier)
                }
            }
        }
    }
    
    func saveLogoPicture(image: UIImage, assetIdentifier: String) {
        let filename = "\(assetIdentifier.replacingOccurrences(of: "/", with: "-")).png"
        guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(filename) else {
            return
        }
        
        if let data = image.pngData(),
           let logoDic = logoDic,
           let note = note {
            do {
                try data.write(to: url)
                logoDic.set(filename, forKey: note.ID)
            }
            catch let error {
                print(error);
                showToast(message: "Error: Could not save logo image.", color: UIColor.red, view: self.view)
            }
        } else {
            showToast(message: "Error: Skipped to save logo image", color: UIColor.red, view: self.view)
        }
    }
}
