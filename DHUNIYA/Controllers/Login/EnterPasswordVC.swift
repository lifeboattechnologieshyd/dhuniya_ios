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
        
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overCurrentContext
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.isOpaque = false
        
        bgView.layer.cornerRadius = 20
        bgView.clipsToBounds = true
        bgView.backgroundColor = .white

        if let num = mobileNumber {
            lblUsername.text = num
        }
        
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func btnGoBackTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // ✅ Forgot Password Button
    @IBAction func btnForgotPasswordTapped(_ sender: UIButton) {
        // Mark this as forgot password flow
        Session.shared.isForgotPasswordFlow = true
        requestForgotPassword() // Call API to send OTP
    }
    
    // MARK: Proceed → Go to OTP VC
    @IBAction func btnProceedTapped(_ sender: UIButton) {
        let password = txtFieldPassword.text ?? ""
        if password.isEmpty {
            showAlert(message: "Please enter your password")
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
    
    // ✅ Forgot Password API Request
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
                        self.showAlert(message: response.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    // ✅ Check Login API
    func checkLogin() {
        let payload: [String:Any] = [
            "mobile" : self.mobileNumber ?? "",
            "password" : self.txtFieldPassword.text ?? ""
        ]
        NetworkManager.shared.request(urlString: API.LOGIN,
                                      method: .POST,
                                      parameters: payload) { (result: Result<APIResponse<LoginResponse>, NetworkError>)  in
            switch result {
            case .success(let response):
                if response.success {
                    if let data = response.info {
                        Session.shared.isUserLoggedIn = true
                        Session.shared.mobileNumber = self.mobileNumber ?? ""
                        Session.shared.userName = data.profileDetails.username
                        Session.shared.accesstoken = data.accessToken
                        Session.shared.refreshtoken = data.refreshToken
                        Session.shared.userroles = data.profileDetails.userRole
                        DispatchQueue.main.async {
                            self.navigateToProfileVC()
                            NotificationCenter.default.post(name: Notification.Name("profile_reload"), object: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(message: response.description)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Navigate to Profile VC
    func navigateToProfileVC() {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let nav = window.rootViewController as? UINavigationController {
                nav.popToRootViewController(animated: false)
            }
        })
    }
}
