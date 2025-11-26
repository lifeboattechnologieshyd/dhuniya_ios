//
//  LoginVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var clearView: UIView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var textFieldPhoneNumber: UITextField!
    
    @IBOutlet weak var btnCheckBox: UIButton!     // UNCHECKED button
    @IBOutlet weak var checkedbox: UIButton!      // CHECKED button
    
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    var isChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        loginView.layer.masksToBounds = true
        
        // Initially UNCHECKED
        isChecked = false
        btnCheckBox.isHidden = false
        checkedbox.isHidden = true
        
        updateProceedButtonState()
    }
    
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    // Tap UNCHECKED → CHECK it
    @IBAction func uncheckedTapped(_ sender: UIButton) {
        isChecked = true
        btnCheckBox.isHidden = true
        checkedbox.isHidden = false
        updateProceedButtonState()
    }
    
    // Tap CHECKED → UNCHECK it
    @IBAction func checkedTapped(_ sender: UIButton) {
        isChecked = false
        checkedbox.isHidden = true
        btnCheckBox.isHidden = false
        updateProceedButtonState()
    }
    
    
    // Enable / Disable Proceed button
    func updateProceedButtonState() {
        btnProceed.isEnabled = isChecked
        btnProceed.alpha = isChecked ? 1.0 : 0.5
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == clearView {
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
        
        navigateToEnterPasswordVC(with: number)
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    
    func navigateToEnterPasswordVC(with number: String) {
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "EnterPasswordVC") as? EnterPasswordVC {
            vc.mobileNumber = number
            self.present(vc, animated: true)
        }
    }
}
