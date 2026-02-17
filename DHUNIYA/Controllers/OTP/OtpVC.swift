
//
//  OtpVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

import UIKit
import Lottie

class OtpVC: UIViewController, UITextFieldDelegate {

    var mobileNumber: String?

    var timer: Timer?
    var remainingSeconds = 29

    @IBOutlet weak var animationVw: UIView!
    @IBOutlet weak var otpTf3: UITextField!
    @IBOutlet weak var otpTf2: UITextField!
    @IBOutlet weak var otpTf4: UITextField!
    @IBOutlet weak var mobilenumberLbl: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var resendotpLbl: UILabel!
    @IBOutlet weak var notreceiveotpLbl: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var gobackButton: UIButton!
    @IBOutlet weak var otfTf1: UITextField!
    @IBOutlet weak var otpVw: UIView!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var otpsentDesc: UILabel!
    @IBOutlet weak var otpheaderLbl: UILabel!

    var lottieView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent auto-dismiss on background tap
        self.modalPresentationStyle = .overFullScreen
        self.isModalInPresentation = true
        
        self.definesPresentationContext = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        self.view.isOpaque = false

        otpVw.backgroundColor = .white
        otpVw.layer.cornerRadius = 22
        otpVw.clipsToBounds = true

        mobilenumberLbl.text = "+91 \(mobileNumber ?? "")"

        resendButton.isHidden = true
        resendotpLbl.isHidden = false

        startResendTimer()
        setupOTPFields()
        playAnimation()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    func playAnimation() {
        lottieView?.removeFromSuperview()
        let animation = LottieAnimation.named("Dhunia OTP Verification")
        let animView = LottieAnimationView(animation: animation)
        animView.frame = animationVw.bounds
        animView.contentMode = .scaleAspectFit
        animView.loopMode = .loop
        animationVw.addSubview(animView)
        animView.play()
        lottieView = animView
    }

    func startResendTimer() {
        remainingSeconds = 29
        resendButton.isHidden = true
        resendotpLbl.isHidden = false
        updateNotReceiveText()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.updateNotReceiveText()
            if self.remainingSeconds <= 0 {
                self.timer?.invalidate()
                self.resendButton.isHidden = false
                self.resendotpLbl.isHidden = true
            }
        }
    }

    func updateNotReceiveText() {
        resendotpLbl.text = "Resend OTP ? 00:\(String(format: "%02d", remainingSeconds))"
    }

    @IBAction func resendButtonTapped(_ sender: UIButton) {
        clearOTPFields()
        startResendTimer()
        resendOtp()
    }
    
    func clearOTPFields() {
        otfTf1.text = ""
        otpTf2.text = ""
        otpTf3.text = ""
        otpTf4.text = ""
        otfTf1.becomeFirstResponder()
        proceedButton.isEnabled = false
        proceedButton.alpha = 0.5
    }

    func resendOtp() {
        guard let mobile = mobileNumber else { return }
        let params: [String: Any] = ["mobile": mobile]

        NetworkManager.shared.requestWithoutAuth(urlString: API.SENDOTP, method: .POST, parameters: params) { (result: Result<APIResponse<SendOtpInfo>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print("✅ OTP resent successfully")
                        self.showAlert("OTP sent successfully!")
                    } else {
                        self.showAlert(response.description)
                    }
                case .failure(let error):
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    func setupOTPFields() {
        let fields = [otfTf1, otpTf2, otpTf3, otpTf4]
        for tf in fields {
            tf?.delegate = self
            tf?.keyboardType = .numberPad
            tf?.textAlignment = .center
            tf?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        proceedButton.isEnabled = false
        proceedButton.alpha = 0.5
        otfTf1.becomeFirstResponder()
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        if text.count > 1 {
            textField.text = String(text.prefix(1))
        }

        if text.count == 1 {
            switch textField {
            case otfTf1: otpTf2.becomeFirstResponder()
            case otpTf2: otpTf3.becomeFirstResponder()
            case otpTf3: otpTf4.becomeFirstResponder()
            case otpTf4:
                otpTf4.resignFirstResponder()
            default: break
            }
        }

        if text.count == 0 {
            switch textField {
            case otpTf4: otpTf3.becomeFirstResponder()
            case otpTf3: otpTf2.becomeFirstResponder()
            case otpTf2: otfTf1.becomeFirstResponder()
            default: break
            }
        }
        
        validateOTP()
    }

    func validateOTP() {
        let otp = "\(otfTf1.text ?? "")\(otpTf2.text ?? "")\(otpTf3.text ?? "")\(otpTf4.text ?? "")"
        let valid = otp.count == 4
        proceedButton.isEnabled = valid
        proceedButton.alpha = valid ? 1 : 0.5
    }

    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        let otp = "\(otfTf1.text ?? "")\(otpTf2.text ?? "")\(otpTf3.text ?? "")\(otpTf4.text ?? "")"
        
        if otp.count != 4 {
            showAlert("Enter 4 digit OTP")
            return
        }
        
        guard let mobile = mobileNumber else {
            showAlert("Mobile number missing")
            return
        }

        verifyOTP(mobile: mobile, otp: otp)
    }
    
    func verifyOTP(mobile: String, otp: String) {
        let params: [String: Any] = [
            "mobile": mobile,
            "otp": Int(otp) ?? 0  // API expects integer OTP
        ]

        NetworkManager.shared.requestWithoutAuth(urlString: API.LOGIN, method: .POST, parameters: params) { (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        guard let data = response.info else {
                            self.showAlert("Login failed: missing info")
                            return
                        }

                        // ✅ Save all session data (same as EnterPasswordVC)
                        Session.shared.isUserLoggedIn = true
                        Session.shared.mobileNumber = mobile
                        Session.shared.userName = data.profileDetails?.username ?? ""
                        Session.shared.accesstoken = data.accessToken
                        Session.shared.refreshtoken = data.refreshToken
                        Session.shared.userDetails = data.profileDetails
                        Session.shared.totalEarnings = data.profileDetails?.total_earnings ?? 0.0
                        
                        // ✅ Save user roles
                        if let roles = data.profileDetails?.user_role {
                            Session.shared.userroles = roles
                        }

                        // ✅ Save Reporter ID + Name
                        if let profile = data.profileDetails {
                            UserSession.shared.reporterId = profile.id
                            UserSession.shared.reporterName = profile.username ?? ""

                            print("🆔 Reporter ID Saved: \(String(describing: profile.id))")
                            print("👤 Reporter Name Saved: \(profile.username ?? "")")
                        }

                        // ✅ Post notifications
                        NotificationCenter.default.post(name: Notification.Name("ReferralCodeUpdated"), object: nil)
                        NotificationCenter.default.post(name: Notification.Name("UserDidLogin"), object: nil)

                        // ✅ Navigate to Profile Tab
                        self.navigateToProfileVC()
                        
                    } else {
                        self.showAlert(response.description)
                    }

                case .failure(let error):
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }
    
    func navigateToProfileVC() {
        DispatchQueue.main.async {
            // Dismiss any modals first
            self.view.window?.rootViewController?.dismiss(animated: false, completion: {
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                        
                        // ✅ Select Profile Tab (index 4)
                        tabBarVC.selectedIndex = 4
                        
                        window.rootViewController = tabBarVC
                        window.makeKeyAndVisible()
                        
                        // ✅ Notify profile to reload data
                        NotificationCenter.default.post(name: Notification.Name("profile_reload"), object: nil)
                    }
                }
            })
        }
    }

    func dismissToProfile() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // Dismiss all modals
        window.rootViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func closeTapped(_ sender: UIButton) {
        dismissToProfile()
    }

    @IBAction func goBackTapped(_ sender: UIButton) {
        // Go back to LoginVC (dismiss only this VC)
        self.dismiss(animated: true)
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        timer?.invalidate()
    }
}
