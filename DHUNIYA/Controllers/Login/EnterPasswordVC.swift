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
    
    @IBAction func btnForgotPasswordTapped(_ sender: UIButton) {
        goToCreatePasswordVC()
    }
    
    
    // MARK: Proceed → Go to OTP VC
    @IBAction func btnProceedTapped(_ sender: UIButton) {
        
        let password = txtFieldPassword.text ?? ""
        
        if password.isEmpty {
            showAlert(message: "Please enter your password")
            return
        }

        goToOtpVC()
    }
    
    
    func goToOtpVC() {
        
        let storyboard = UIStoryboard(name: "OTP", bundle: nil)
        
        if let otpVC = storyboard.instantiateViewController(withIdentifier: "OtpVC") as? OtpVC {
            
            otpVC.mobileNumber = mobileNumber
            
            otpVC.modalPresentationStyle = .overCurrentContext
            otpVC.modalTransitionStyle = .crossDissolve
            
            self.present(otpVC, animated: true)
        }
    }
    
    
    //Navigate to CreatePasswordVC
    func goToCreatePasswordVC() {
        
        let storyboard = UIStoryboard(name: "CreatePassword", bundle: nil)
        
        if let createVC = storyboard.instantiateViewController(withIdentifier: "CreatePasswordVC") as? CreatePasswordVC {
            
            createVC.mobileNumber = mobileNumber
            
            createVC.modalPresentationStyle = .overCurrentContext
            createVC.modalTransitionStyle = .crossDissolve
            
            self.present(createVC, animated: true)
        }
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
