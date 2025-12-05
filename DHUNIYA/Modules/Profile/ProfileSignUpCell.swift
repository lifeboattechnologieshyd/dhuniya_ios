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
    @IBAction func btnProfilePicTapped(_ sender: UIButton) {
        openImagePicker()
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
            let loggedIn = Session.shared.isUserLoggedIn
            
            btnSignUp.isHidden = loggedIn
            userVw.isHidden = !loggedIn
            lblMyEarnings.isHidden = !loggedIn
            withdrawBtn.isHidden = !loggedIn
            withdrawVw.isHidden = !loggedIn
            
            lblUserName.text = Session.shared.userName
            lblPhoneNumber.text = Session.shared.mobileNumber
            
            if loggedIn {
                lblMyEarnings.removeBlur()
                withdrawBtn.removeBlur()
                withdrawVw.removeBlur()
            } else {
                lblMyEarnings.applyBlur(intensity: 0.98)
                withdrawBtn.applyBlur(intensity: 0.98)
                withdrawVw.applyBlur(intensity: 0.98)
            }
            
            // Load profile image from Session
            if let savedImage = Session.shared.profileImage {
                imgViewProfie.image = savedImage
            }
        }
        
        
        @objc func updateProfileImage() {
            imgViewProfie.image = Session.shared.profileImage
        }
    }

    extension ProfileSignUpCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        func openImagePicker() {
            guard let parentVC = self.parentViewController() else { return }

            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            parentVC.present(picker, animated: true)
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let selectedImage = info[.originalImage] as? UIImage {

                // Set inside cell
                self.imgViewProfie.image = selectedImage

                // Save globally in Session
                Session.shared.profileImage = selectedImage

                // Notify all other screens
                NotificationCenter.default.post(name: Notification.Name("ProfileImageUpdated"), object: nil)
            }

            picker.dismiss(animated: true)
        }
    }
