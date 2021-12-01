//
//  ViewControllerLog.swift
//  tSecreta
//
//  Created by Manabu Tonosaki on 2021/11/29.
//

import UIKit

extension ViewController {
    
    internal func initLogView() {
        logView = LogView()
        
        logView.alpha = 0.8
        logView.backgroundColor = UIColor(red:0, green: 0, blue: 0, alpha: 0.3)
        logView.frame = CGRect(x:8, y:logoffButton.frame.maxY + 24, width: self.view.frame.width - 16, height: self.view.frame.maxY - logoffButton.frame.maxY)
        view.addSubview(logView)
    }
    
    public func addInfo(_ message: String){
        logView.addLog(message, level: .info)
        logView.setNeedsDisplay()
        logView.setNeedsLayout()
    }

    public func addWarning(_ message: String){
        logView.addLog(message, level: .warning)
        logView.setNeedsDisplay()
        logView.setNeedsLayout()
    }

    public func addError(_ message: String){
        logView.addLog(message, level: .error)
        logView.setNeedsDisplay()
        logView.setNeedsLayout()
    }

    public func addFatal(_ message: String){
        logView.addLog(message, level: .fatal)
        logView.layoutIfNeeded()
        logView.setNeedsLayout()
    }

}

class LogView : UIView {
    
    public struct LogItem {
        var message: String = ""
        var datetime: Date = Date()
        
        enum LogLevels {
            case debug
            case info
            case warning
            case error
            case fatal
        }
        var logLevel: LogLevels = .info
    }
    
    private var logItems: [LogItem] = [LogItem]()
    
    // add a new log message
    public func addLog(_ message: String, level: LogItem.LogLevels){
        let dt = Date()
        logItems.append(LogView.LogItem(message: message, datetime: dt, logLevel: level))
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "HH:mm:ss"
        print("[\(level)] \(dateFormat.string(from: dt)) \(message)")
    }
    
    private let fontSitePt = 11.0

    override func draw(_ rect: CGRect) {
        // NSAttributedString(
        
        var y0 = 4.0
        let x0 = 4.0
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "HH:mm:ss"
        for logitem in logItems.reversed() {
            var attr: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSitePt)
                //NSAttributedString.Key.font: UIFont(name: "Hiragino Sans", size: fontSitePt)!
                //NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSitePt, weight: UIFont.Weight(rawValue: 1.0)),
            ]
            switch logitem.logLevel {
            case .info: attr[NSAttributedString.Key.foregroundColor] = UIColor.cyan
            case .debug: attr[NSAttributedString.Key.foregroundColor] = UIColor.darkGray
            case .warning: attr[NSAttributedString.Key.foregroundColor] = UIColor.white
            case .error: attr[NSAttributedString.Key.foregroundColor] = UIColor.yellow
            case .fatal: attr[NSAttributedString.Key.foregroundColor] = UIColor.red
            }
            let str = NSString(string:"\(dateFormat.string(from: logitem.datetime))  \(logitem.message)")
            str.draw(at: CGPoint(x:x0, y:y0), withAttributes: attr)
            y0 += fontSitePt * 1.1
            if( y0 > self.frame.maxY ){
                break;
            }
        }
    }
}

