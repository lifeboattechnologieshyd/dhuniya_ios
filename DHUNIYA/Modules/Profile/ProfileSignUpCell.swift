//
//  ProfileSignUpCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class ProfileSignUpCell: UITableViewCell {
    
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var earningsVw: UIView!
    @IBOutlet weak var signUpContentView: UIView!
    @IBOutlet weak var lblMyEarnings: UILabel!
    @IBOutlet weak var withdrawVw: UIView!
    @IBOutlet weak var lblMyEarningsText: UILabel!
    @IBOutlet weak var withdrawBtn: UIButton!
    @IBOutlet weak var earningImgVw: UIView!
    @IBOutlet weak var imgViewProfie: UIImageView!
    @IBOutlet weak var userVw: UIView!
    var signUpClicked: (() -> Void)?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    
    @IBAction func withdrawBtnTapped(_ sender: UIButton) {
        if let parentVC = self.parentViewController() {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            if let withdrawVC = storyboard.instantiateViewController(withIdentifier: "WithdrawVC") as? WithdrawVC {
                parentVC.navigationController?.pushViewController(withdrawVC, animated: true)
            }
        }
    }
    
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        signUpClicked!()
    }
    
    
    @IBAction func editProfileTapped(_ sender: UIButton) {
        if let parentVC = self.parentViewController() {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            if let editVC = storyboard.instantiateViewController(withIdentifier: "ProfileEditVC") as? ProfileEditVC {
                parentVC.navigationController?.pushViewController(editVC, animated: true)
            }
        }
    }
    
    
    func configure() {
        btnSignUp.isHidden = Session.shared.isUserLoggedIn
        userVw.isHidden = !Session.shared.isUserLoggedIn
        lblMyEarnings.isHidden = !Session.shared.isUserLoggedIn
        withdrawBtn.isHidden = !Session.shared.isUserLoggedIn
        withdrawVw.isHidden = !Session.shared.isUserLoggedIn
        
        lblUserName.text = Session.shared.userName
        lblPhoneNumber.text = Session.shared.mobileNumber
        
        if Session.shared.isUserLoggedIn {
            lblMyEarnings.removeBlur()
            withdrawBtn.removeBlur()
            withdrawVw.removeBlur()
        } else {
            lblMyEarnings.applyBlur(intensity: 0.98)
            withdrawBtn.applyBlur(intensity: 0.98)
            withdrawVw.applyBlur(intensity: 0.98)
        }
    }
}
