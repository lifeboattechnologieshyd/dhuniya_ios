//
//  LoginVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var textFieldPhoneNumber: UITextField!
    
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    var isChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.isOpaque = false
        self.modalPresentationStyle = .overCurrentContext
        
        loginView.backgroundColor = .white
        loginView.layer.cornerRadius = 20
        loginView.clipsToBounds = true
        
        self.view.layoutIfNeeded()
        
        isChecked = false
        btnCheckBox.setImage(UIImage(named: "Unchecked_box"), for: .normal)
        updateProceedButtonState()
    }
    
    func sendOtp() {
        let payload: [String: Any] = [
            "mobile": self.textFieldPhoneNumber.text ?? ""
        ]
        
        NetworkManager.shared.requestWithoutAuth(urlString: API.SENDOTP, method: .POST, parameters: payload) { (result: Result<APIResponse<SendOtpInfo>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        Session.shared.mobileNumber = self.textFieldPhoneNumber.text ?? ""
                        self.navigateToOtpVC()
                    } else {
                        self.showAlert(message: response.description)
                    }
                    
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    func navigateToOtpVC() {
        let storyboard = UIStoryboard(name: "OTP", bundle: nil)
        if let otpVC = storyboard.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC {
            otpVC.mobileNumber = self.textFieldPhoneNumber.text ?? ""
            otpVC.modalPresentationStyle = .overCurrentContext
            otpVC.modalTransitionStyle = .crossDissolve
            self.present(otpVC, animated: true)
        }
    }
    
    @IBAction func onTapBtnCheckBox(_ sender: UIButton) {
        isChecked.toggle()
        btnCheckBox.setImage(UIImage(named: isChecked ? "checked_box" : "Unchecked_box"), for: .normal)
        updateProceedButtonState()
    }
    
    func updateProceedButtonState() {
        btnProceed.isEnabled = isChecked
        btnProceed.alpha = isChecked ? 1.0 : 0.5
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnProceedTapped(_ sender: UIButton) {
        
        guard let number = textFieldPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !number.isEmpty else {
            showAlert(message: "Please enter your phone number")
            return
        }
        
        if number.count != 10 || !number.allSatisfy({ $0.isNumber }) {
            showAlert(message: "Please provide a valid 10-digit number")
            return
        }
        
        if !isChecked {
            showAlert(message: "Please accept terms & conditions")
            return
        }
        
        self.sendOtp()
    }
    
   
}
