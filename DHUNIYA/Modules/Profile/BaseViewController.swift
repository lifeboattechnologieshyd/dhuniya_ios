//
//  BaseViewController.swift
//  DHUNIYA
//
//  Created by Lifeboat on 27/11/25.
//

import UIKit
import MessageUI
import StoreKit

class BaseViewController: UIViewController,MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.view.alpha = 1
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().screenBgColor
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.view.alpha = 0.5
    }
}

extension BaseViewController {
    func timeAgoString(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let providedDate = dateFormatter.date(from: dateString) else {
            return nil // Return nil if there's an error parsing the date
        }
        
        let currentDate = Date()
        let timeDifference = Int(currentDate.timeIntervalSince(providedDate))
        
        let secondsInMinute = 60
        let secondsInHour = 3600
        let secondsInDay = 86400
        
        if timeDifference < secondsInMinute {
            return "\(timeDifference) seconds ago"
        } else if timeDifference < secondsInHour {
            let minutes = timeDifference / secondsInMinute
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeDifference < secondsInDay {
            let hours = timeDifference / secondsInHour
            return "\(hours) hr\(hours == 1 ? "" : "s") ago"
        } else {
            let days = timeDifference / secondsInDay
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
    
    
    //extension UIApplication {
    //        /// this is being used to set the status bar background color to otherthan default. here in this app calling this function as UIApplication.shared.statusBarUIView?.backgroundColor = .black. so it will set black as its bg color.
    //        var statusBarUIView: UIView? {
    //            if #available(iOS 13.0, *) {
    //                let tag = 38482
    //                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    //
    //                if let statusBar = keyWindow?.viewWithTag(tag) {
    //                    return statusBar
    //                } else {
    //                    guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
    //                    let statusBarView = UIView(frame: statusBarFrame)
    //                    statusBarView.tag = tag
    //                    keyWindow?.addSubview(statusBarView)
    //                    return statusBarView
    //                }
    //            } else if responds(to: Selector(("statusBar"))) {
    //                return value(forKey: "statusBar") as? UIView
    //            } else {
    //                return nil
    //            }
    //        }
    //    }
    //
    //}
}
