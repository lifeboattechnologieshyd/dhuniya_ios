//
//  ProfileVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit
import MessageUI

class ProfileVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var TblVw: UITableView!
    
    let titles = ["My Dhuniya", "Settings & Preferences", "My Referrals",
                  "Become a News Reporter", "Terms of Use"]
    
    let images = ["my_dhuniya", "settings", "myreferrals",
                  "newsreporter", "terms"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TblVw.delegate = self
        TblVw.dataSource = self
        
        TblVw.register(UINib(nibName: "ProfileSignUpCell", bundle: nil), forCellReuseIdentifier: "ProfileSignUpCell")
        TblVw.register(UINib(nibName: "RefferAndEarnCell", bundle: nil), forCellReuseIdentifier: "RefferAndEarnCell")
        TblVw.register(UINib(nibName: "ProfileListCell", bundle: nil), forCellReuseIdentifier: "ProfileListCell")
        TblVw.register(UINib(nibName: "BottomHeaderListCell", bundle: nil), forCellReuseIdentifier: "BottomHeaderListCell")
        TblVw.register(UINib(nibName: "LogoutCell", bundle: nil), forCellReuseIdentifier: "LogoutCell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadProfile),
            name: Notification.Name("profile_reload"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TblVw.reloadData()     // FIXES referral code not showing
    }
    
    @objc func reloadProfile() {
        DispatchQueue.main.async { // Ensure reload on main thread
            self.TblVw.reloadData()
        }
    }
    
    @objc func openLoginFromProfile() {
        showLoginPopup()
    }
    
    @objc func handleLogoutClicked() {
        if Session.shared.isUserLoggedIn {
            showLogoutAlert()
        }
    }
    
    func showLoginPopup() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                loginVC.modalPresentationStyle = .overFullScreen
                loginVC.modalTransitionStyle = .crossDissolve
                self.present(loginVC, animated: true)
            }
        }
    }
    
    func navigateToTerms() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 5 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 { return Session.shared.isUserLoggedIn ? 1 : 0 }
        return section == 2 ? titles.count : 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSignUpCell", for: indexPath) as! ProfileSignUpCell
            cell.configure()
            cell.signUpClicked = { [weak self] in
                self?.openLoginFromProfile()
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RefferAndEarnCell", for: indexPath) as! RefferAndEarnCell
            cell.configure()
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListCell", for: indexPath) as! ProfileListCell
            cell.lblText.text = titles[indexPath.row]
            cell.imgVw.image = UIImage(named: images[indexPath.row])
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BottomHeaderListCell", for: indexPath) as! BottomHeaderListCell
            cell.contactUs = { [weak self] in
                guard let self = self else { return }
                if !Session.shared.isUserLoggedIn { self.showLoginPopup(); return }
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["support@dhuniya.in"])
                    mail.setSubject("Dhuniya App Support")
                    mail.setMessageBody("Hello Team,\n\n", isHTML: false)
                    self.present(mail, animated: true)
                } else {
                    self.showAlert(message: "Your device is not configured to send emails.")
                }
            }
            
            cell.shareApp = { [weak self] in
                guard let self = self else { return }
                if !Session.shared.isUserLoggedIn { self.showLoginPopup(); return }
                let text = "Download Dhuniya App now! https://play.google.com/store/apps/details?id=com.dhuniya.app"
                let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                self.present(vc, animated: true)
            }
            
            cell.rateUs = { [weak self] in
                guard let self = self else { return }
                if !Session.shared.isUserLoggedIn { self.showLoginPopup(); return }
                if let url = URL(string: "https://play.google.com/store/apps/details?id=com.dhuniya.app") {
                    UIApplication.shared.open(url)
                }
            }
            
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath) as! LogoutCell
            cell.logoutClicked = { [weak self] in
                self?.handleLogoutClicked()
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0,1: return 214
        case 2: return 70
        case 3: return 100
        case 4: return Session.shared.isUserLoggedIn ? 64 : 0
        default: return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 4 {
            if Session.shared.isUserLoggedIn { showLogoutAlert() }
            return
        }
        
        guard indexPath.section == 2 else { return }
        
        if !Session.shared.isUserLoggedIn {
            tableView.deselectRow(at: indexPath, animated: false)
            DispatchQueue.main.async { self.showLoginPopup() }
            return
        }
        
        let title = titles[indexPath.row]
        
        switch title {
        case "Settings & Preferences": navigateToSettings()
        case "My Referrals": navigateToReferAndEarn()
        case "Become a News Reporter": navigateToBecomeReporter()
        case "Terms of Use": navigateToTerms()
        default: break
        }
    }
    
    func navigateToSettings() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func navigateToReferAndEarn() {
        let storyboard = UIStoryboard(name: "Refer&Earn", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ReferAndEarnVC") as? ReferAndEarnVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func navigateToBecomeReporter() {
        let storyboard = UIStoryboard(name: "BecomeNewsReporter", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "BecomeNewsReporterVC") as? BecomeNewsReporterVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ProfileVC {
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            Session.shared.logout()
            self.TblVw.reloadData()
        }))
        
        present(alert, animated: true)
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
    
    func CustomshowAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topMostViewController().present(alert, animated: true)
    }
}
