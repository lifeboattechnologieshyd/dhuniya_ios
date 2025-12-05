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
        // FIX POPUP BLINKING
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overCurrentContext
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
        startResendTimer()
        resendOtp()
    }

    func resendOtp() {
        guard let mobile = mobileNumber else { return }
        let params: [String: Any] = ["mobile": mobile]

        NetworkManager.shared.request(urlString: API.SENDOTP, method: .POST, parameters: params) { (result: Result<APIResponse<SendOtpInfo>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print("OTP resent successfully")
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
                validateOTP()
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
            showAlert("Mobile missing")
            return
        }

        let params: [String: String] = ["mobile": mobile, "otp": otp]

        NetworkManager.shared.request(urlString: API.LOGIN, method: .POST, parameters: params) { (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        // Safely unwrap optional LoginResponse
                        guard let info = response.info else {
                            self.showAlert("Login failed: missing profile info")
                            return
                        }

                        // Save session tokens
                        Session.shared.mobileNumber = mobile
                        Session.shared.accesstoken = info.accessToken
                        Session.shared.refreshtoken = info.refreshToken

                        // Save full profile details including referral code
                        Session.shared.userDetails = info.profileDetails

                        // Notify Refer & Earn VC to reload referral code
                        NotificationCenter.default.post(name: Notification.Name("ReferralCodeUpdated"), object: nil)

                        // Go to next screen
                        self.navigateToCreatePassword()
                    } else {
                        self.showAlert(response.description)
                    }

                case .failure(let error):
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    func navigateToCreatePassword() {
        let storyboard = UIStoryboard(name: "CreatePassword", bundle: nil)
        if let createPasswordVC = storyboard.instantiateViewController(withIdentifier: "CreatePasswordVC") as? CreatePasswordVC {
            createPasswordVC.mobileNumber = mobileNumber
            createPasswordVC.modalPresentationStyle = .fullScreen
            self.present(createPasswordVC, animated: true)
        }
    }

    func navigateToProfile() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        if let rootVC = window.rootViewController {
            rootVC.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func closeTapped(_ sender: UIButton) {
        navigateToProfile()
    }

    @IBAction func goBackTapped(_ sender: UIButton) {
        navigateToProfile()
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
