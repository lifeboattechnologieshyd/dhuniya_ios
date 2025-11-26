//
//  ButtonsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 26/11/25.
//

import UIKit

class ButtonsCell: UITableViewCell {

    @IBOutlet weak var rulesBtn: UIButton!
    @IBOutlet weak var myReferralBtn: UIButton!
    
    var onButtonTap: ((String) -> Void)?    // closure callback
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func rulesTapped(_ sender: UIButton) {
        onButtonTap?("rules")
    }

    @IBAction func referralTapped(_ sender: UIButton) {
        onButtonTap?("referral")
    }
}

