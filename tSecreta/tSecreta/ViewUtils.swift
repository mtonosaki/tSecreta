//
//  ViewUtils.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/12/02.
//

import UIKit

public class ToastMessageShadow: UIView {
    override public func layoutSubviews() {
        super.layoutSubviews()
        dropShadow()
    }
    
    private func dropShadow(scale: Bool = true){
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

func showToast(message: String, color: UIColor, view: UIView){
    DispatchQueue.main.async {
        let toastView = ToastMessageShadow(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 35))
        toastView.backgroundColor = color
        toastView.alpha = 0.8
        let toastLabel = UILabel(frame: CGRect(x: 10, y: 9, width: toastView.bounds.width - 10, height: 17))
        toastLabel.font = UIFont(name: "Tahoma", size: 12.0)
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.lineBreakMode = .byTruncatingTail
        toastLabel.textAlignment = .left
        toastLabel.sizeToFit()
        let xPosition = view.frame.width / 2 - toastLabel.frame.width / 2
        let yPosition: CGFloat = 70
        toastView.frame = CGRect(x: ceil(xPosition), y: yPosition, width: toastLabel.frame.width + 20, height: 35)
        toastView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        toastView.addSubview(toastLabel)
        view.addSubview(toastView)
        UIView.animate(
            withDuration: 0.5,
            delay: 0.75,
            options: .curveEaseOut,
            animations: {
                toastView.alpha = 0.0
                toastView.center.y -= 16
            },
            completion: {
                isCompleted in
                toastView.removeFromSuperview()
            }
        )
    }
}
