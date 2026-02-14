//
//  AddBankVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 14/02/26.
//

import UIKit

class AddBankVC: UIViewController {

    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var accountNumberTf: UITextField!
    @IBOutlet weak var bankNameTf: UITextField!
    @IBOutlet weak var ifscCodeTf: UITextField!
    @IBOutlet weak var topVw: UIButton!
    @IBOutlet weak var addbankaccountBtn: UIButton!
    @IBOutlet weak var checkboxBtn: UIButton!
    
    var isChecked = false
    var branchName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        checkboxBtn.setImage(UIImage(systemName: "square"), for: .normal)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkboxBtnTapped(_ sender: UIButton) {
        isChecked.toggle()
        let imageName = isChecked ? "checkmark.square.fill" : "square"
        checkboxBtn.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func addbankaccountBtnTapped(_ sender: UIButton) {
        if validateFields() {
            addBankAccount()
        }
    }
    
    func validateFields() -> Bool {
        guard let accountNumber = accountNumberTf.text, !accountNumber.isEmpty else {
            showAlert(message: "Please enter account number")
            return false
        }
        
        guard let bankName = bankNameTf.text, !bankName.isEmpty else {
            showAlert(message: "Please enter bank name")
            return false
        }
        
        guard let ifsc = ifscCodeTf.text, !ifsc.isEmpty else {
            showAlert(message: "Please enter IFSC code")
            return false
        }
        
        guard let holderName = nameTf.text, !holderName.isEmpty else {
            showAlert(message: "Please enter account holder name")
            return false
        }
        
        guard isChecked else {
            showAlert(message: "Please confirm the details are correct")
            return false
        }
        
        return true
    }
    
    func addBankAccount() {
        let params: [String: Any] = [
            "account_number": accountNumberTf.text ?? "",
            "bank_name": bankNameTf.text ?? "",
            "ifsc": ifscCodeTf.text ?? "",
            "account_holder_name": nameTf.text ?? "",
            "branch": "Default"
        ]
        
        showLoader()
        
        NetworkManager.shared.request(
            urlString: API.BANK_DETAILS,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<BankDetails>, NetworkError>) in
            
            guard let self = self else { return }
            self.hideLoader()
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self.showSuccessAndPop()
                    } else {
                        self.showAlert(message: response.description)
                    }
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func showSuccessAndPop() {
        let alert = UIAlertController(
            title: "Success",
            message: "Bank account added successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
