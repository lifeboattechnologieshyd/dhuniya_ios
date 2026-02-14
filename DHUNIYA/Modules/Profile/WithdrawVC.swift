//
//  WithdrawVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

import UIKit

class WithdrawVC: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var earningsImage: UIImageView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var changeLbl: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var amountTf: UITextField!
    @IBOutlet weak var amountVw: UIView!
    @IBOutlet weak var earningsLbl: UILabel!
    @IBOutlet weak var addbankdescLbl: UILabel!
    @IBOutlet weak var addbankaccountVw: UIView!
    @IBOutlet weak var addbankButton: UIButton!
    @IBOutlet weak var tapBtn: UIButton!
    @IBOutlet weak var bankaccountVw: UIView!
    @IBOutlet weak var moneyVw: UIView!
    @IBOutlet weak var bankaccountnumber: UILabel!
    
    var bankDetails: BankDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        amountTf.setLeftPadding(35)
        self.navigationItem.hidesBackButton = true
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBankDetails()
    }
    
    func setupUI() {
        addbankaccountVw.isHidden = true
        bankaccountVw.isHidden = true
        amountVw.isHidden = true
        tapBtn.isHidden = true
        amountLbl.text = String(format: "₹%.2f", Session.shared.totalEarnings)
    }
    
    func getBankDetails() {
        showLoader()
        
        NetworkManager.shared.request(
            urlString: API.BANK_DETAILS,
            method: .GET
        ) { [weak self] (result: Result<APIResponse<BankDetails>, NetworkError>) in
            
            guard let self = self else { return }
            self.hideLoader()
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.info {
                        self.bankDetails = data
                        self.showBankDetails(data)
                    } else {
                        self.showAddBankView()
                    }
                case .failure(_):
                    self.showAddBankView()
                }
            }
        }
    }
    
    func showBankDetails(_ details: BankDetails) {
        addbankaccountVw.isHidden = true
        bankaccountVw.isHidden = false
        amountVw.isHidden = false
        tapBtn.isHidden = false
        
        let accountNumber = details.account_number ?? ""
        let bankName = details.bank_name ?? ""
        bankaccountnumber.text = "\(accountNumber) - \(bankName)"
        
        updateTapButtonState()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showAddBankView() {
        addbankaccountVw.isHidden = false
        bankaccountVw.isHidden = true
        amountVw.isHidden = true
        tapBtn.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateTapButtonState() {
        if Session.shared.totalEarnings < 200 {
            tapBtn.setTitle("Balance Insufficient", for: .normal)
            tapBtn.isEnabled = false
            tapBtn.alpha = 0.5
        } else {
            tapBtn.setTitle("PLACE WITHDRAW REQUEST", for: .normal)
            tapBtn.isEnabled = true
            tapBtn.alpha = 1.0
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addbankButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddBankVC") as? AddBankVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func historyButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TransactionsVC") as? TransactionsVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func tapBtnTapped(_ sender: UIButton) {
        guard let amountText = amountTf.text, !amountText.isEmpty else {
            showAlert(message: "Please enter amount")
            return
        }
        
        guard let amount = Double(amountText) else {
            showAlert(message: "Please enter valid amount")
            return
        }
        
        if amount < 200 {
            showAlert(message: "Minimum withdrawal amount is ₹200")
            return
        }
        
        if amount > Session.shared.totalEarnings {
            showAlert(message: "Insufficient balance")
            return
        }
        
        placeWithdrawRequest(amount: Int(amount))
    }
    
    func placeWithdrawRequest(amount: Int) {
        showLoader()
        
        let params: [String: Any] = [
            "amount": amount
        ]
        
        NetworkManager.shared.request(
            urlString: API.INITIATE_TRANSFER,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<EmptyResponse>, NetworkError>) in
            
            guard let self = self else { return }
            self.hideLoader()
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self.showSuccessAlert()
                    } else {
                        self.showAlert(message: response.description)
                    }
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Withdraw request placed successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.amountTf.text = ""
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
