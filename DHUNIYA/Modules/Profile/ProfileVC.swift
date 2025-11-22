//
//  ProfileVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var TblVw: UITableView!
    
    let titles = ["My Dhuniya", "Settings & Preferences", "My Referrals", "Become a News Reporter", "Submit Videos", "Terms of Use"]
    let images = ["my_dhuniya", "settings", "myreferrals", "newsreporter", "submitVideos", "terms"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TblVw.delegate = self
        TblVw.dataSource = self
        
        TblVw.register(UINib(nibName: "ProfileSignUpCell", bundle: nil), forCellReuseIdentifier: "ProfileSignUpCell")
        TblVw.register(UINib(nibName: "RefferAndEarnCell", bundle: nil), forCellReuseIdentifier: "RefferAndEarnCell")
        TblVw.register(UINib(nibName: "ProfileListCell", bundle: nil), forCellReuseIdentifier: "ProfileListCell")
        TblVw.register(UINib(nibName: "BottomHeaderListCell", bundle: nil), forCellReuseIdentifier: "BottomHeaderListCell")
        TblVw.register(UINib(nibName: "LogoutCell", bundle: nil), forCellReuseIdentifier: "LogoutCell")
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       if section == 2 {
            return titles.count
       }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSignUpCell", for: indexPath)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RefferAndEarnCell", for: indexPath)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileListCell", for: indexPath) as! ProfileListCell
            
            cell.lblText.text = titles[indexPath.row]
            cell.imgVw.image = UIImage(named: images[indexPath.row])
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BottomHeaderListCell", for: indexPath)
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCell", for: indexPath)
            return cell
            
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 214
        case 1: return 214
        case 2: return 70
        case 3: return 100
        case 4: return 64
        default: return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 2 else { return }
        
        let title = titles[indexPath.row]
        
        if title == "My Referrals" {
            navigateToReferAndEarn()
        }
        else if title == "Become a News Reporter" {
            navigateToBecomeReporter()
        }
    }
    
    
    func navigateToReferAndEarn() {
        let storyboard = UIStoryboard(name: "Refer&Earn", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ReferAndEarnVC") as? ReferAndEarnVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func navigateToBecomeReporter() {
        let storyboard = UIStoryboard(name: "BecomeNewsReporter", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "BecomeNewsReporterVC") as? BecomeNewsReporterVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
