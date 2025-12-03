//
//  CreatePasswordVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

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

    var hasNumber = false
    var hasAlphabet = false
    var hasMinLength = false
    var isPasswordVisible = false
    var isConfirmPasswordVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        

        proceedButton.layer.cornerRadius = 8
        enterPasswordTf.delegate = self
        confirmPasswordTF.delegate = self
        updateValidationUI()
    }

    //Toggle Password Visibility
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

    // UITextFieldDelegate
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

    //  Password Validation
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

    //   Proceed Button Action
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        guard let password = enterPasswordTf.text else { return }
        var params: [String: Any] = ["password": password]
        if let mobile = mobileNumber { params["mobile"] = mobile }

        let url = Session.shared.isForgotPasswordFlow ? API.RESET_PASSWORD : API.CREATE_PASSWORD

        NetworkManager.shared.request(urlString: url, method: .POST, parameters: params) { (result: Result<APIResponse<ProfileDetails>, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.success,
                       let profile = response.info {
                        // Save session
                        Session.shared.userDetails = profile
                        Session.shared.isUserLoggedIn = true
                        Session.shared.mobileNumber = self.mobileNumber ?? ""
                        Session.shared.userName = profile.username ?? ""

                        DispatchQueue.main.async {
                            self.setProfileAsRoot()
                        }
                    } else {
                        self.showCustomAlert(message: response.description)
                    }
                case .failure(let error):
                    self.showCustomAlert(message: error.localizedDescription)
                }
        }
    }

    private func setProfileAsRoot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            // Wrap in navigation controller if needed
            let nav = UINavigationController(rootViewController: profileVC)
            nav.modalPresentationStyle = .fullScreen
            window.rootViewController = nav
            window.makeKeyAndVisible()

            // Notify ProfileVC to reload data
            NotificationCenter.default.post(name: Notification.Name("profile_reload"), object: nil)
        }
    }

    //  Go Back
    @IBAction func goBackTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    //   Alert
    private func showCustomAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
        alert.dismiss(animated: false) {
            self.setProfileAsRoot()
        }

    }

    // Initial UI Setup
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
