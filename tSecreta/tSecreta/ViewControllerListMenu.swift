//
//  ViewControllerList.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//  MIT License (c)2022 Manabu Tonosaki all rights reserved.

import UIKit
import Tono

protocol HambergerMenuDelegate: AnyObject {
    func didTapBackToAuthentication()
    func didTapUploadToCloud()
    func didTapSaveLogosToCloud() async
    func didTapLoadAndMergeLogosFromCloud() async
}

final class ViewControllerListMenu : UIViewController {
    @IBOutlet weak var menuView: UIView!

    weak var delegate: HambergerMenuDelegate?
    
    override func viewDidLoad() {
        menuView.layer.cornerRadius = 12
        menuView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOpacity = 0.4
        menuView.layer.shadowRadius = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let menuPos = self.menuView.layer.position
        menuView.layer.position.x = -self.menuView.frame.width
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.menuView.layer.position.x = menuPos.x
        }, completion: {
            bool in
            // nothing
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.menuView.layer.position.x = -self.menuView.frame.width
                }, completion: {
                    bool in
                    self.dismiss(animated: true)
                })
            }
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        if let delegate = delegate {
            self.dismiss(animated: false) {
                delegate.didTapBackToAuthentication()
            }
        }
    }
    @IBAction func didTapUploadToCloudButton(_ sender: Any) {
        if let delegate = delegate {
            delegate.didTapUploadToCloud()
            self.dismiss(animated: true)
        }
    }
    @IBAction func didTapSaveLogosToCloud(_ sender: Any) {
        if let delegate = delegate {
            Task.init {
                await delegate.didTapSaveLogosToCloud()
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func didTapLoadAndMergeLogosFromCloud(_ sender: Any) {
        if let delegate = delegate {
            Task.init {
                await delegate.didTapLoadAndMergeLogosFromCloud()
                self.dismiss(animated: true)
            }
        }
    }
}
