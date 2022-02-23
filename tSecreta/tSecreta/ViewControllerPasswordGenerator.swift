//
//  ViewControllerPasswordGenerator.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2022/02/02.
//  MIT License (c)2021 Manabu Tonosaki all rights reserved.

import UIKit

final class ViewControllerPasswordGenerator : UIViewController {
    
    @IBOutlet weak var resultTextField: UITextField!
    @IBOutlet weak var pattern1TextField: UITextField!
    @IBOutlet weak var pattern2TextField: UITextField!
    
    override func viewDidLoad() {

        if let pattern = UserDefaults.standard.object(forKey: "PasswordPatternNo01") as? String  {
            pattern1TextField.text = pattern
        }
        if let pattern = UserDefaults.standard.object(forKey: "PasswordPatternNo02") as? String  {
            pattern2TextField.text = pattern
        }
    }
    
    @IBAction func editingDidEndPattern1(_ sender: Any) {
        UserDefaults.standard.set(pattern1TextField.text, forKey: "PasswordPatternNo01")
    }
    
    @IBAction func editingDidEndPattern2(_ sender: Any) {
        UserDefaults.standard.set(pattern2TextField.text, forKey: "PasswordPatternNo02")
    }

    @IBAction func didTapGeneratePattern1(_ sender: Any) {
        resultTextField.text = generate(pattern: pattern1TextField.text)
    }
    
    @IBAction func didTapCopyPassword(_ sender: Any) {
        if let text = resultTextField.text {
            UIPasteboard.general.string = text
            showToast(message: "! Copy Password ! Need to Paste manually", color: UIColor.systemOrange, view: self.parent?.view ?? self.view)
        }
    }
    
    @IBAction func didTapGeneratePattern2(_ sender: Any) {
        resultTextField.text = generate(pattern: pattern2TextField.text)
    }
    
    func generate(pattern: String?) -> String {
        guard let pattern = pattern else {
            showToast(message: "Input pattern first", color: UIColor.red, view: self.view)
            return ""
        }
        let res = generate(pattern: pattern)
        return res
    }
    
    func generate(pattern: String) -> String {
        var res = ""
        for c in pattern {
            res += String(getOne(patternCharacter: c))
        }
        return res
    }
    
    func getOne(patternCharacter: String.Element) -> String.Element {
        switch patternCharacter {
            case "0"..."9":
                return "2345678".randomElement()!
            case "A"..."Z":
                return "ABCDEFGHJKLMNPQRTWXYZ".randomElement()!
            case "a"..."z":
                return "abcdefghjkmnpqrstuvwxyz".randomElement()!
            default:
                return patternCharacter
        }
    }
}
