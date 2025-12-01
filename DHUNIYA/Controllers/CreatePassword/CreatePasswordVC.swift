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
        passwordMismatchLbl.isHidden = true
        updateValidationUI()
    }

    // Show/Hide Password
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        enterPasswordTf.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "EyeOpen" : "EyeClosed"
        showPasswordBtn.setImage(UIImage(named: imageName), for: .normal)
    }

    @IBAction func toggleConfirmPasswordVisibility(_ sender: UIButton) {
        isConfirmPasswordVisible.toggle()
        confirmPasswordTF.isSecureTextEntry = !isConfirmPasswordVisible
        let imageName = isConfirmPasswordVisible ? "EyeOpen" : "EyeClosed"
        showConfirmPasswordBtn.setImage(UIImage(named: imageName), for: .normal)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string

        if textField == enterPasswordTf {
            validatePassword(updatedText)
        } else if textField == confirmPasswordTF {
            checkPasswordMatch(updatedText)
        }
        return true
    }

    func validatePassword(_ password: String) {
        hasMinLength = password.count >= 6
        hasAlphabet = password.rangeOfCharacter(from: .letters) != nil
        hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil

        numberCheckImage.isHidden = !hasNumber
        alphabetCheckImage.isHidden = !hasAlphabet
        characterCheckImage.isHidden = !hasMinLength

        numberLbl.textColor = hasNumber ? .systemGreen : .red
        alphabetLbl.textColor = hasAlphabet ? .systemGreen : .red
        characterLbl.textColor = hasMinLength ? .systemGreen : .red

        checkPasswordMatch(confirmPasswordTF.text ?? "")
        updateProceedButton()
    }

    func checkPasswordMatch(_ confirmText: String) {
        if confirmText.isEmpty {
            passwordMismatchLbl.isHidden = true
            return
        }
        if confirmText == enterPasswordTf.text {
            passwordMismatchLbl.text = "Passwords matched"
            passwordMismatchLbl.textColor = .systemGreen
        } else {
            passwordMismatchLbl.text = "Passwords mismatched"
            passwordMismatchLbl.textColor = .red
        }
        passwordMismatchLbl.isHidden = false
        updateProceedButton()
    }

    func updateProceedButton() {
        let canProceed = hasNumber && hasAlphabet && hasMinLength && (enterPasswordTf.text == confirmPasswordTF.text)
        proceedButton.isEnabled = canProceed
        proceedButton.alpha = canProceed ? 1 : 0.5
    }

    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        guard let password = enterPasswordTf.text else { return }

        let params: [String: Any] = ["password": password]
        let url = Session.shared.isForgotPasswordFlow ? API.RESET_PASSWORD : API.CREATE_PASSWORD

        NetworkManager.shared.request(urlString: url, method: .POST, parameters: params) { (result: Result<APIResponse<CreatePasswordResponse>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let createPasswordInfo = response.info, let profile = createPasswordInfo.info {
                        // Save profile details
                        Session.shared.userDetails = profile
                        Session.shared.isUserLoggedIn = true

                        // Navigate
                        self.navigateAfterPasswordSet()
                    } else {
                        self.showAlert(response.description ?? "Something went wrong")
                    }
                case .failure(let error):
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }

    func navigateAfterPasswordSet() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.dismiss(animated: false, completion: {
                NotificationCenter.default.post(name: NSNotification.Name("login"), object: nil)
            })
        }
    }

    @IBAction func goBackTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func updateValidationUI() {
        numberCheckImage.isHidden = true
        alphabetCheckImage.isHidden = true
        characterCheckImage.isHidden = true
        passwordMismatchLbl.isHidden = true
        proceedButton.isEnabled = false
        proceedButton.alpha = 0.5
    }
}
