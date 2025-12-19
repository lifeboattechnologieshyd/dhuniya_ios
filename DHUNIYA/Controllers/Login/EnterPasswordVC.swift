//
//  EnterPasswordVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//
import UIKit

class EnterPasswordVC: UIViewController {
    
    var mobileNumber: String?
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var btnGoBack: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var lblWelcomeback: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent auto-dismiss on background tap
        self.modalPresentationStyle = .overFullScreen
        self.isModalInPresentation = true   // Important: prevents swipe-down & tap-out dismissal

        // Semi-transparent background
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
         
        if let num = mobileNumber {
            lblUsername.text = num
        }
        
        // Optional: tap outside to dismiss keyboard, not VC
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }



    // Central dismiss function
    func dismissToProfile() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // Dismiss all modals
        window.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        dismissToProfile()
    }
    
    @IBAction func btnGoBackTapped(_ sender: UIButton) {
        dismissToProfile()
    }
    
    // Forgot Password Button
    @IBAction func btnForgotPasswordTapped(_ sender: UIButton) {
        // Mark this as forgot password flow
        Session.shared.isForgotPasswordFlow = true
        requestForgotPassword() // Call API to send OTP
    }
    
    // MARK: Proceed → Go to OTP VC
    @IBAction func btnProceedTapped(_ sender: UIButton) {
        let password = txtFieldPassword.text ?? ""
        if password.isEmpty {
            showCustomAlert(message: "Please enter your password")
            return
        }
        checkLogin()
    }
    
    // Navigate to OTP screen
    func goToOtpVC() {
        let storyboard = UIStoryboard(name: "OTP", bundle: nil)
        if let otpVC = storyboard.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC {
            otpVC.mobileNumber = mobileNumber
            otpVC.modalPresentationStyle = .overCurrentContext
            otpVC.modalTransitionStyle = .crossDissolve
            self.present(otpVC, animated: true)
        }
    }
    
    // Forgot Password API Request
    func requestForgotPassword() {
        let params = [
            "mobile": mobileNumber ?? ""
        ]
        
        NetworkManager.shared.request(urlString: API.FORGOT_PASSWORD,
                                      method: .POST,
                                      parameters: params) { (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success {
                    DispatchQueue.main.async {
                        self.goToOtpVC() // Navigate to OTP VC after OTP sent
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showCustomAlert(message: response.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showCustomAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func checkLogin() {
        let payload: [String:Any] = [
            "mobile" : self.mobileNumber ?? "",
            "password" : self.txtFieldPassword.text ?? ""
        ]
        
        NetworkManager.shared.request(
            urlString: API.LOGIN,
            method: .POST,
            parameters: payload
        ) { [weak self] (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success, let data = response.info {
                    
                    Session.shared.isUserLoggedIn = true
                    Session.shared.mobileNumber = self.mobileNumber ?? ""
                    Session.shared.userName = data.profileDetails?.username ?? ""
                    Session.shared.accesstoken = data.accessToken
                    Session.shared.refreshtoken = data.refreshToken
                    Session.shared.userDetails = data.profileDetails
                    
                    // 🚀 SAVE REPORTER ID + NAME
                    if let profile = data.profileDetails {
                        UserSession.shared.reporterId = profile.id
                        UserSession.shared.reporterName = profile.username ?? ""

                        print("🆔 Reporter ID Saved: \(profile.id)")
                        print("👤 Reporter Name Saved: \(profile.username ?? "")")
                    }
                    
                    // Navigate
                    DispatchQueue.main.async {
                        self.navigateToProfileVC()
                    }

                } else {
                    DispatchQueue.main.async {
                        self.showCustomAlert(message: response.description)
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showCustomAlert(message: error.localizedDescription)
                }
            }
        }
    }

    func navigateToProfileVC() {
        NotificationCenter.default.post(name: Notification.Name("profile_reload"), object: nil)
        self.view.window?.rootViewController?.dismiss(animated: false, completion: {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let nav = window.rootViewController as? UINavigationController {
                nav.popToRootViewController(animated: false)
            }
        })
    }
    
    func showCustomAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
