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
    
    //  Send OTP
    func sendOtp() {
        let payload: [String:Any] = [
            "mobile" : self.textFieldPhoneNumber.text ?? ""
        ]
        
        NetworkManager.shared.request(urlString: API.SENDOTP, method: .POST, parameters: payload) { (result: Result<APIResponse<SendOtpInfo>, NetworkError>) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let info = response.info {
                        Session.shared.mobileNumber = self.textFieldPhoneNumber.text ?? ""
                        
                        if info.isLoginWithPassword ?? false {
                            // Existing user → Enter Password
                            self.navigateToEnterPasswordVC()
                        } else {
                            // New user → OTP
                            self.navigateToOtpVC()
                        }
                    } else {
                        self.showAlert(message: response.description)
                    }
                    
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    //  Navigation
    func navigateToEnterPasswordVC() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "EnterPasswordVC") as? EnterPasswordVC {
            vc.mobileNumber = self.textFieldPhoneNumber.text ?? ""
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
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
    
    // UI Actions
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if !loginView.frame.contains(touch.location(in: self.view)) {
            self.dismiss(animated: true)
        }
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
    
    // Alerts
    func showLoginAlert(message: String?) {
        let alert = UIAlertController(title: "Alert", message: message ?? "Something went wrong", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //dismiss all modally presented VCs and go to ProfileVC
    func goToProfileVC() {
        DispatchQueue.main.async {
            // Dismiss all presented view controllers
            self.view.window?.rootViewController?.dismiss(animated: false, completion: {
                
                // Set ProfileVC as root
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                        window.rootViewController = profileVC
                        window.makeKeyAndVisible()
                        
                        // Notify profile to reload data
                        NotificationCenter.default.post(name: Notification.Name("profile_reload"), object: nil)
                    }
                }
            })
        }
    }
}
