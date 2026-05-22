import UIKit

class CreatePasswordVC: UIViewController, UITextFieldDelegate {

    var mobileNumber: String?

    @IBOutlet weak var enterPasswordTf: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var passwordMismatchLbl: UILabel!
    @IBOutlet weak var numberCheckImage: UIImageView!
    @IBOutlet weak var confirmpasswordCheckimage: UIImageView!
    @IBOutlet weak var alphabetCheckImage: UIImageView!
    @IBOutlet weak var characterCheckImage: UIImageView!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var alphabetLbl: UILabel!
    @IBOutlet weak var characterLbl: UILabel!
    @IBOutlet weak var showPasswordBtn: UIButton!
    @IBOutlet weak var showConfirmPasswordBtn: UIButton!
    @IBOutlet weak var headerLbl: UILabel!  // Optional: for title

    var hasNumber = false
    var hasAlphabet = false
    var hasMinLength = false
    var isPasswordVisible = false
    var isConfirmPasswordVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .overFullScreen
        self.isModalInPresentation = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        proceedButton.layer.cornerRadius = 8
        enterPasswordTf.delegate = self
        confirmPasswordTF.delegate = self
        updateValidationUI()
        
        // ✅ Update header based on flow
        if Session.shared.isForgotPasswordFlow {
            headerLbl?.text = "Reset Password"
        } else {
            headerLbl?.text = "Create Password"
        }
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    // MARK: - Toggle Password Visibility
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        enterPasswordTf.isSecureTextEntry = !isPasswordVisible
        fixCursor(for: enterPasswordTf)
        showPasswordBtn.setImage(UIImage(named: isPasswordVisible ? "EyeOpen" : "EyeClose"), for: .normal)
    }

    @IBAction func toggleConfirmPasswordVisibility(_ sender: UIButton) {
        isConfirmPasswordVisible.toggle()
        confirmPasswordTF.isSecureTextEntry = !isConfirmPasswordVisible
        fixCursor(for: confirmPasswordTF)
        showConfirmPasswordBtn.setImage(UIImage(named: isConfirmPasswordVisible ? "EyeOpen" : "EyeClose"), for: .normal)
    }

    private func fixCursor(for textField: UITextField) {
        if let text = textField.text, textField.isFirstResponder {
            textField.resignFirstResponder()
            textField.text = text
            textField.becomeFirstResponder()
        }
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if textField == enterPasswordTf {
            validatePassword(updatedText)
        } else if textField == confirmPasswordTF {
            checkPasswordMatch(updatedText)
        }

        return true
    }

    // MARK: - Password Validation
    func validatePassword(_ password: String) {
        hasMinLength = password.count >= 6
        hasAlphabet = password.rangeOfCharacter(from: .letters) != nil
        hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil

        numberCheckImage.isHidden = !hasNumber
        alphabetCheckImage.isHidden = !hasAlphabet
        characterCheckImage.isHidden = !hasMinLength

        numberLbl.textColor = hasNumber ? .systemGreen : .label
        alphabetLbl.textColor = hasAlphabet ? .systemGreen : .label
        characterLbl.textColor = hasMinLength ? .systemGreen : .label

        if let confirmText = confirmPasswordTF.text, !confirmText.isEmpty {
            checkPasswordMatch(confirmText)
        }

        updateProceedButton(confirmPassword: confirmPasswordTF.text ?? "")
    }

    func checkPasswordMatch(_ confirmText: String) {
        let password = enterPasswordTf.text ?? ""

        if confirmText.isEmpty {
            passwordMismatchLbl.isHidden = true
            confirmpasswordCheckimage.isHidden = true
        } else if confirmText == password {
            passwordMismatchLbl.text = "Passwords matched"
            passwordMismatchLbl.textColor = .systemGreen
            passwordMismatchLbl.isHidden = false
            confirmpasswordCheckimage.isHidden = false
        } else {
            passwordMismatchLbl.text = "Passwords mismatched"
            passwordMismatchLbl.textColor = .red
            passwordMismatchLbl.isHidden = false
            confirmpasswordCheckimage.isHidden = true
        }

        updateProceedButton(confirmPassword: confirmText)
    }

    func updateProceedButton(confirmPassword: String = "") {
        let password = enterPasswordTf.text ?? ""
        let canProceed = hasNumber && hasAlphabet && hasMinLength && password == confirmPassword && !password.isEmpty
        proceedButton.isEnabled = canProceed
        proceedButton.alpha = canProceed ? 1 : 0.5
    }

    // MARK: - Proceed Button Action
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        guard let password = enterPasswordTf.text, !password.isEmpty else {
            showCustomAlert(message: "Please enter password")
            return
        }
        
        createOrResetPassword(password: password)
    }
    
    // MARK: - Create/Reset Password API
    func createOrResetPassword(password: String) {
        var params: [String: Any] = ["password": password]
        if let mobile = mobileNumber {
            params["mobile"] = mobile
        }

        // ✅ Use correct API based on flow
        let apiURL = Session.shared.isForgotPasswordFlow ? API.RESET_PASSWORD : API.CREATE_PASSWORD

        NetworkManager.shared.request(urlString: apiURL, method: .POST, parameters: params) { (result: Result<APIResponse<LoginResponse>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        
                        // ✅ Save session if login data returned
                        if let data = response.info {
                            self.saveSessionData(data: data)
                        }
                        
                        // ✅ Reset flags
                        Session.shared.isForgotPasswordFlow = false
                        Session.shared.isNewUser = false
                        
                        // ✅ Navigate to Profile
                        self.navigateToProfileVC()
                        
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
        Session.shared.mobileNumber = mobileNumber ?? ""
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

        NotificationCenter.default.post(name: Notification.Name("ReferralCodeUpdated"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UserDidLogin"), object: nil)
    }

    // MARK: - Navigate to Profile
    func navigateToProfileVC() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            window.rootViewController?.dismiss(animated: false) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                    tabBarVC.selectedIndex = 4
                    window.rootViewController = tabBarVC
                    window.makeKeyAndVisible()
                    
                    NotificationCenter.default.post(name: Notification.Name("profile_reload"), object: nil)
                }
            }
        }
    }

    // MARK: - Go Back
    @IBAction func goBackTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - Alert
    private func showCustomAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    // MARK: - Initial UI Setup
    private func updateValidationUI() {
        numberCheckImage.isHidden = true
        alphabetCheckImage.isHidden = true
        characterCheckImage.isHidden = true
        confirmpasswordCheckimage.isHidden = true
        passwordMismatchLbl.isHidden = true
        proceedButton.isEnabled = false
        proceedButton.alpha = 0.5
    }
}
