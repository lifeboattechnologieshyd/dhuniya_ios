//
//  ButtonsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 26/11/25.
//


import UIKit

class ButtonsCell: UITableViewCell {

    @IBOutlet weak var rulesBtn: UIButton!
    @IBOutlet weak var rulesVw: UIView!
    @IBOutlet weak var referalVw: UIView!
    @IBOutlet weak var myReferralBtn: UIButton!
    
    var onButtonTap: ((String) -> Void)?    // closure callback
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set default selection
        showSelectedView("rules")
    }

    @IBAction func rulesTapped(_ sender: UIButton) {
        showSelectedView("rules")
        onButtonTap?("rules")
    }

    @IBAction func referralTapped(_ sender: UIButton) {
        showSelectedView("referral")
        onButtonTap?("referral")
    }
    
    // Helper to update view visibility and button colors
    private func showSelectedView(_ selected: String) {
        if selected == "rules" {
            rulesVw.isHidden = false
            referalVw.isHidden = true
            
            // Highlight selected button
            rulesBtn.setTitleColor(.systemBlue, for: .normal)
            myReferralBtn.setTitleColor(.black, for: .normal)
        } else if selected == "referral" {
            rulesVw.isHidden = true
            referalVw.isHidden = false
            
            // Highlight selected button
            rulesBtn.setTitleColor(.black, for: .normal)
            myReferralBtn.setTitleColor(.systemBlue, for: .normal)
        }
    }
}
