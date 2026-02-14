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
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var earningsLbl: UILabel!
    @IBOutlet weak var addbankdescLbl: UILabel!
    @IBOutlet weak var addbankaccountVw: UIView!
    @IBOutlet weak var addbankButton: UIButton!
    @IBOutlet weak var bankaccountVw: UIView!
    @IBOutlet weak var moneyVw: UIView!
    @IBOutlet weak var bankaccountnumber: UILabel!
    
    @IBOutlet weak var addbankaccountVwHeightConstraint: NSLayoutConstraint!
    
    var bankDetails: BankDetails?
    var originalAddBankHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        self.navigationItem.hidesBackButton = true
        originalAddBankHeight = addbankaccountVwHeightConstraint.constant
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBankDetails()
    }
    
    func setupUI() {
        addbankaccountVw.isHidden = true
        bankaccountVw.isHidden = true
        addbankaccountVwHeightConstraint.constant = 0
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
        addbankaccountVwHeightConstraint.constant = 0
        bankaccountVw.isHidden = false
        
        let accountNumber = details.account_number ?? ""
        let bankName = details.bank_name ?? ""
        bankaccountnumber.text = "\(accountNumber) - \(bankName)"
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showAddBankView() {
        addbankaccountVw.isHidden = false
        addbankaccountVwHeightConstraint.constant = originalAddBankHeight
        bankaccountVw.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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
}
