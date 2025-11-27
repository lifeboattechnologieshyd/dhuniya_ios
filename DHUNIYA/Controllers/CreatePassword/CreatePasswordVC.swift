//
//  CreatePasswordVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

import UIKit

class CreatePasswordVC: UIViewController {
    
    var mobileNumber: String?

    @IBOutlet weak var passwordRulesLbl: UILabel!
    @IBOutlet weak var passwordMismatchLbl: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var alphabetLbl: UILabel!
    @IBOutlet weak var charactercheckImage: UIImageView!
    @IBOutlet weak var charactersLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var passwordRulesView: UIView!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var alphabetcheckImage: UIImageView!
    @IBOutlet weak var numbercheckImage: UIImageView!
    @IBOutlet weak var confirmPasswordViewButton: UIButton!
    @IBOutlet weak var passwordcheckImage: UIImageView!
    @IBOutlet weak var confirmPasswordViewImage: UIImageView!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordVw: UIView!
    @IBOutlet weak var viewenterPasswordImage: UIImageView!
    @IBOutlet weak var viewEnterPAsswordBtn: UIButton!
    @IBOutlet weak var enterPasswordTf: UITextField!
    @IBOutlet weak var enterpasswordVw: UIView!
    @IBOutlet weak var headerLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        goToOtpVC()
    }

    func goToOtpVC() {
        let storyboard = UIStoryboard(name: "OTP", bundle: nil)

        if let otpVC = storyboard.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC {
            
            otpVC.mobileNumber = mobileNumber    // pass mobile
            
            otpVC.modalPresentationStyle = .overCurrentContext
            otpVC.modalTransitionStyle = .crossDissolve
            
            self.present(otpVC, animated: true)
        }
    }
    @IBAction func goBackTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}


