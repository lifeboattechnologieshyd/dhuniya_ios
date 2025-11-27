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
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        NotificationCenter.default.post(name: Notification.Name("open_login_from_profile"), object: nil)
    }
    
    
    @IBAction func editProfileTapped(_ sender: UIButton) {
        if let parentVC = self.parentViewController() {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            if let editVC = storyboard.instantiateViewController(withIdentifier: "ProfileEditVC") as? ProfileEditVC {
                parentVC.navigationController?.pushViewController(editVC, animated: true)
            }
        }
    }
    
    
    func configure(isLoggedIn: Bool, userName: String?, phone: String?) {
        
        if isLoggedIn {
            btnSignUp.isHidden = true
            userVw.isHidden = false
            
            lblMyEarnings.isHidden = false
            withdrawBtn.isHidden = false
            withdrawVw.isHidden = false
            
            // remove blur when logged in
            lblMyEarnings.removeBlur()
            withdrawBtn.removeBlur()
            withdrawVw.removeBlur()
            
            lblUserName.text = userName ?? "User"
            lblPhoneNumber.text = phone ?? ""
            
        } else {
            btnSignUp.isHidden = false
            userVw.isHidden = true
            
            lblMyEarnings.isHidden = false
            withdrawBtn.isHidden = false
            withdrawVw.isHidden = false
            
            // apply blur when NOT logged in
            lblMyEarnings.applyBlur(intensity: 0.98)
            withdrawBtn.applyBlur(intensity: 0.98)
            withdrawVw.applyBlur(intensity: 0.98)

        }
        
    }
}
