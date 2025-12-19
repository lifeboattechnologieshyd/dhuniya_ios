//
//  Refer&Earn.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class ReferAndEarnVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topVw: UIView!
    
    var selectedTab: String = "rules"
    var referrals: [ReferralUser] = []  // This will hold the API referral data

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "RefferAndEarnCell", bundle: nil), forCellReuseIdentifier: "RefferAndEarnCell")
        tblVw.register(UINib(nibName: "ButtonsCell", bundle: nil), forCellReuseIdentifier: "ButtonsCell")
        tblVw.register(UINib(nibName: "RulesCell", bundle: nil), forCellReuseIdentifier: "RulesCell")
        tblVw.register(UINib(nibName: "MyReferals", bundle: nil), forCellReuseIdentifier: "MyReferals")
    }

    @IBAction func onBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ReferAndEarnVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3   // FIXED: must be 3 sections now
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RefferAndEarnCell", for: indexPath) as! RefferAndEarnCell
            
            // Hide the Know More button in this VC
            cell.configure(showKnowMore: false)
            
            return cell
        }
        // Section 1 → buttons cell
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonsCell", for: indexPath) as! ButtonsCell
            
            cell.onButtonTap = { [weak self] selected in
                self?.selectedTab = selected
                tableView.reloadSections(IndexSet(integer: 2), with: .fade)
            }
            
            return cell   // FIXED: correct type
        }
        
        // Section 2 → content cell
        if selectedTab == "rules" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RulesCell", for: indexPath) as! RulesCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyReferals", for: indexPath) as! MyReferals
            
            // Pass the referral data
            if referrals.isEmpty {
                cell.configure(with: nil)   // No data
            } else {
                let referral = referrals[indexPath.row]  // if showing multiple referrals
                cell.configure(with: referral)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 214
        } else if indexPath.section == 1 {
            return 70
        } else {
            return selectedTab == "rules" ? 460 : 300
        }
    }
}
