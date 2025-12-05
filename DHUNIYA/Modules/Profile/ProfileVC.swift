//
//  ProfileVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit
import MessageUI

enum ProfileCellType {
    case signup
    case manageNews
    case newsAdmin
//    case listings
    case referAndEarn
    case listItem(title: String, image: String)
    case bottomHeader
    case logout
}

class ProfileVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var TblVw: UITableView!

    // Dynamic UI sections
    var sections: [[ProfileCellType]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        TblVw.delegate = self as any UITableViewDelegate
        TblVw.dataSource = self as any UITableViewDataSource

        // Register all new cells
        TblVw.register(UINib(nibName: "ProfileSignUpCell", bundle: nil), forCellReuseIdentifier: "ProfileSignUpCell")
        TblVw.register(UINib(nibName: "RefferAndEarnCell", bundle: nil), forCellReuseIdentifier: "RefferAndEarnCell")
        TblVw.register(UINib(nibName: "ProfileListCell", bundle: nil), forCellReuseIdentifier: "ProfileListCell")
        TblVw.register(UINib(nibName: "BottomHeaderListCell", bundle: nil), forCellReuseIdentifier: "BottomHeaderListCell")
        TblVw.register(UINib(nibName: "LogoutCell", bundle: nil), forCellReuseIdentifier: "LogoutCell")
        TblVw.register(UINib(nibName: "ManageNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ManageNewsTableViewCell")
        TblVw.register(UINib(nibName: "NewsAdminTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsAdminTableViewCell")
        TblVw.register(UINib(nibName: "ListingsTableViewCell", bundle: nil), forCellReuseIdentifier: "ListingsTableViewCell")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadProfile),
            name: Notification.Name("profile_reload"),
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildSections() // Role UI
        TblVw.reloadData()
    }

    func buildSections() {
        sections.removeAll()

        if !Session.shared.isUserLoggedIn {
            // Pre-login layout
            sections = [
                [.signup],
                [.referAndEarn],
                [
                    .listItem(title: "Settings & Preferences", image: "settings"),
                    .listItem(title: "My Referrals", image: "myreferrals"),
                    .listItem(title: "Become a News Reporter", image: "newsreporter"),
                    .listItem(title: "Terms of Use", image: "terms")
                ],
                [.bottomHeader]
            ]
            return
        }

        // Post-login: populate based on roles
        if Session.shared.userDetails?.user_role?.contains(UserRole.ENDUSER.rawValue) ?? false {
            sections = [
                [.signup],
                [.referAndEarn],
                [
//                    .listItem(title: "My Dhuniya", image: "my_dhuniya"),
                    .listItem(title: "Settings & Preferences", image: "settings"),
                    .listItem(title: "My Referrals", image: "myreferrals"),
                    .listItem(title: "Become a News Reporter", image: "newsreporter"),
                    .listItem(title: "Terms of Use", image: "terms")
                ],
                [.bottomHeader],
                [.logout]
            ]
        }

        if Session.shared.userDetails?.user_role?.contains(UserRole.REPORTER.rawValue) ?? false {
            sections = [
                [.signup],
                [.manageNews],
                [.referAndEarn],
                [
//                    .listItem(title: "My Dhuniya", image: "my_dhuniya"),
                    .listItem(title: "Settings & Preferences", image: "settings"),
                    .listItem(title: "My Referrals", image: "myreferrals"),
                    .listItem(title: "Terms of Use", image: "terms")
                ],
                [.bottomHeader],
                [.logout]
            ]
        }

        if Session.shared.userDetails?.user_role?.contains(UserRole.NEWSADMIN.rawValue) ?? false {
            sections = [
                [.signup],
                [.manageNews],
                [.newsAdmin],
//                [.listings],
                [.referAndEarn],
                [
//                    .listItem(title: "My Dhuniya", image: "my_dhuniya"),
                    .listItem(title: "Settings & Preferences", image: "settings"),
                    .listItem(title: "My Referrals", image: "myreferrals"),
                    .listItem(title: "Terms of Use", image: "terms")
                ],
                [.bottomHeader],
                [.logout]
            ]
        }
    }

    @objc func reloadProfile() {
        DispatchQueue.main.async {
            self.buildSections()
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

// MARK: UITableView Delegate & DataSource
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section][indexPath.row]

        switch item {
        case .signup:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSignUpCell", for: indexPath) as! ProfileSignUpCell
            cell.configure()
            cell.signUpClicked = { [weak self] in self?.openLoginFromProfile() }
            return cell

        case .manageNews:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageNewsTableViewCell", for: indexPath) as! ManageNewsTableViewCell
            return cell

        case .newsAdmin:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsAdminTableViewCell", for: indexPath) as! NewsAdminTableViewCell
            return cell

//        case .listings:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ListingsTableViewCell", for: indexPath) as! ListingsTableViewCell
//            return cell

        case .referAndEarn:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RefferAndEarnCell", for: indexPath) as! RefferAndEarnCell
            cell.configure()
            return cell

        case .listItem(let title, let image):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListCell", for: indexPath) as! ProfileListCell
            cell.lblText.text = title
            cell.imgVw.image = UIImage(named: image)
            return cell

        case .bottomHeader:
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
                    self.showAlert(message: "Your device cannot send emails.")
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

        case .logout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath) as! LogoutCell
            cell.logoutClicked = { [weak self] in self?.handleLogoutClicked() }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = sections[indexPath.section][indexPath.row]
        switch item {
        case .signup: return 204
        case.referAndEarn: return 200
        case .manageNews, .newsAdmin : return 56
        case .listItem: return 70
        case .bottomHeader: return 100
        case .logout: return Session.shared.isUserLoggedIn ? 64 : 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section][indexPath.row]

        if !Session.shared.isUserLoggedIn {
            showLoginPopup()
            return
        }

        switch item {
        case .listItem(let title, _):
            switch title {
            case "Settings & Preferences": navigateToSettings()
            case "My Referrals": navigateToReferAndEarn()
            case "Become a News Reporter": navigateToBecomeReporter()
            case "Terms of Use": navigateToTerms()
            default: break
            }
        default: break
        }
    }

    func navigateToSettings() {
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func navigateToReferAndEarn() {
        let sb = UIStoryboard(name: "Refer&Earn", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ReferAndEarnVC") as? ReferAndEarnVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func navigateToBecomeReporter() {
        let sb = UIStoryboard(name: "BecomeNewsReporter", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "BecomeNewsReporterVC") as? BecomeNewsReporterVC {
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
            self.buildSections()
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
            return nav.visibleViewController ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController ?? tab
        }
        return self
    }
}
