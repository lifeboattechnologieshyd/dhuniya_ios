//
//  MyReferals.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class MyReferals: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lbldate: UILabel!
    @IBOutlet weak var mobileNumber: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var myReferralsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with referral: ReferralUser?) {
        if let referral = referral {
            lblName.text = referral.fullName
            lbldate.text = referral.joinedDate
            mobileNumber.text = referral.mobileNumber
            if let urlString = referral.profileImageURL, let url = URL(string: urlString) {
                // load async image here
            } else {
                profileImage.image = UIImage(named: "defaultProfile")
            }
        } else {
            lblName.text = "No referrals yet"
            lbldate.text = ""
            mobileNumber.text = ""
            profileImage.image = UIImage(named: "defaultProfile")
        }
    }
}
