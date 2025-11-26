//
//  ProfileVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var TblVw: UITableView!
    
    let titles = ["My Dhuniya", "Settings & Preferences", "My Referrals",
                  "Become a News Reporter", "Terms of Use"]
    
    let images = ["my_dhuniya", "settings", "myreferrals",
                  "newsreporter", "terms"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TblVw.delegate = self
        TblVw.dataSource = self
        
        TblVw.register(UINib(nibName: "ProfileSignUpCell", bundle: nil),forCellReuseIdentifier: "ProfileSignUpCell")
        TblVw.register(UINib(nibName: "RefferAndEarnCell", bundle: nil),forCellReuseIdentifier: "RefferAndEarnCell")
        TblVw.register(UINib(nibName: "ProfileListCell", bundle: nil),forCellReuseIdentifier: "ProfileListCell")
        TblVw.register(UINib(nibName: "BottomHeaderListCell", bundle: nil),forCellReuseIdentifier: "BottomHeaderListCell")
        TblVw.register(UINib(nibName: "LogoutCell", bundle: nil),forCellReuseIdentifier: "LogoutCell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadProfile),
            name: Notification.Name("profile_reload"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openLoginFromProfile),
            name: Notification.Name("open_login_from_profile"),
            object: nil
        )
    }
    
    @objc func reloadProfile() {
        TblVw.reloadData()
    }
    
    @objc func openLoginFromProfile() {
        showLoginPopup()
    }
    
    func showLoginPopup() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            loginVC.modalPresentationStyle = .overFullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            present(loginVC, animated: true)
        }
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? titles.count : 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileSignUpCell",
                for: indexPath
            ) as! ProfileSignUpCell
            
            cell.configure(
                isLoggedIn: Session.shared.isUserLoggedIn,
                userName: Session.shared.userName,
                phone: Session.shared.mobileNumber
            )
            
            return cell
            
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "RefferAndEarnCell", for: indexPath)
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListCell", for: indexPath) as! ProfileListCell
            cell.lblText.text = titles[indexPath.row]
            cell.imgVw.image = UIImage(named: images[indexPath.row])
            return cell
            
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "BottomHeaderListCell", for: indexPath)
            
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0: return 214
        case 1: return 214
        case 2: return 70
        case 3: return 100
        case 4: return 64
        default: return UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        //  LOGOUT HANDLING
        if indexPath.section == 4 {
            showLogoutAlert()
            return
        }
        
        guard indexPath.section == 2 else { return }
        
        // BEFORE LOGIN
        if !Session.shared.isUserLoggedIn {
            showLoginPopup()
            return
        }
        
        let title = titles[indexPath.row]
        
        // Settings
        if title == "Settings & Preferences" {
            navigateToSettings()
            return
        }
        
        // Referrals
        if title == "My Referrals" {
            navigateToReferAndEarn()
            return
        }
        
        // News Reporter
        if title == "Become a News Reporter" {
            navigateToBecomeReporter()
            return
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
            
            // RESET SESSION
            Session.shared.isUserLoggedIn = false
            Session.shared.mobileNumber = ""
            Session.shared.userName = ""
            
            // Reload UI
            self.TblVw.reloadData()
        }))
        
        present(alert, animated: true)
    }
}
