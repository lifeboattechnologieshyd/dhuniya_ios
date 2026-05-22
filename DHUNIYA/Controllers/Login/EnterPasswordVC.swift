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
        
        self.modalPresentationStyle = .overFullScreen
        self.isModalInPresentation = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        if let num = mobileNumber {
            lblUsername.text = "+91 \(num)"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    func dismissToHome() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        dismissToHome()
    }
    
    @IBAction func btnGoBackTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Forgot Password → Send OTP & Navigate
    @IBAction func btnForgotPasswordTapped(_ sender: UIButton) {
        Session.shared.isForgotPasswordFlow = true
        sendOtpForForgotPassword()
    }
    
    // MARK: - Proceed → Login with Password
    @IBAction func btnProceedTapped(_ sender: UIButton) {
        let password = txtFieldPassword.text ?? ""
        if password.isEmpty {
            showCustomAlert(message: "Please enter your password")
            return
        }
        loginWithPassword()
    }
    
    // MARK: - Send OTP for Forgot Password
    func sendOtpForForgotPassword() {
        let params: [String: Any] = [
            "mobile": mobileNumber ?? ""
        ]
        
        print("📤 Sending OTP for forgot password to: \(mobileNumber ?? "")")
        
        // ✅ USE SENDOTP API (same as login flow)
        NetworkManager.shared.requestWithoutAuth(urlString: API.SENDOTP, method: .POST, parameters: params) { (result: Result<APIResponse<SendOtpInfo>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print("✅ OTP sent successfully for forgot password")
                        self.navigateToOtpVC()
                    } else {
                        print("❌ OTP send failed: \(response.description)")
                        self.showCustomAlert(message: response.description)
                    }
                case .failure(let error):
                    print("❌ Network error: \(error.localizedDescription)")
                    self.showCustomAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Navigate to OTP VC
    func navigateToOtpVC() {
        let storyboard = UIStoryboard(name: "OTP", bundle: nil)
        if let otpVC = storyboard.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC {
            otpVC.mobileNumber = mobileNumber
            otpVC.modalPresentationStyle = .overFullScreen
            otpVC.modalTransitionStyle = .crossDissolve
            self.present(otpVC, animated: true)
        }
    }
    
    // MARK: - Login with Password API
    func loginWithPassword() {
        let payload: [String: Any] = [
            "mobile": self.mobileNumber ?? "",
            "password": self.txtFieldPassword.text ?? ""
        ]
        
        NetworkManager.shared.requestWithoutAuth(urlString: API.LOGIN, method: .POST, parameters: payload) { [weak self] (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.info {
                        self.saveSessionData(data: data)
                        self.navigateToHomeVC()
                    } else {
                        self.showCustomAlert(message: response.description)
                    }
                    
                case .failure(let error):
                    self.showCustomAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Save Session Data
    func saveSessionData(data: LoginResponse) {
        Session.shared.isUserLoggedIn = true
        Session.shared.mobileNumber = self.mobileNumber ?? ""
        Session.shared.userName = data.profileDetails?.username ?? ""
        Session.shared.accesstoken = data.accessToken
        Session.shared.refreshtoken = data.refreshToken
        Session.shared.userDetails = data.profileDetails
        Session.shared.totalEarnings = data.profileDetails?.total_earnings ?? 0.0
        
        if let roles = data.profileDetails?.user_role {
            Session.shared.userroles = roles
        }
        
        if let profile = data.profileDetails {
            UserSession.shared.reporterId = profile.id
            UserSession.shared.reporterName = profile.username ?? ""
        }
    }

    // MARK: - Navigate to Home
    func navigateToHomeVC() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            window.rootViewController?.dismiss(animated: false) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                    tabBarVC.selectedIndex = 0
                    window.rootViewController = tabBarVC
                    window.makeKeyAndVisible()
                    
                    NotificationCenter.default.post(name: Notification.Name("profile_reload"), object: nil)
                }
            }
        }
    }
    
    func showCustomAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
