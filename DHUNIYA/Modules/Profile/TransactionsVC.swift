//
//  TransactionsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 14/02/26.
//

import UIKit

class TransactionsVC: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    var transactions: [Transaction] = []
    var profileInfo: ProfileInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        topVw.addBottomShadow()
        getProfileDetails()
    }
    
    func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UINib(nibName: "transactionCell", bundle: nil), forCellReuseIdentifier: "transactionCell")
    }
    
    func getProfileDetails() {
        showLoader()
        
        let params: [String: Any] = [
            "mobile": Session.shared.mobileNumber,
            "password": "Password@123"
        ]
        
        NetworkManager.shared.request(
            urlString: API.PROFILE,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<[ProfileInfo]>, NetworkError>) in
            
            guard let self = self else { return }
            self.hideLoader()
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let data = response.info?.first {
                        self.profileInfo = data
                        self.loadMockTransactions()
                        self.tblVw.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func loadMockTransactions() {
        transactions = [
            Transaction(type: "Withdrawal", amountId: "TXN001", amount: "₹500", closingBalance: "₹1500", time: "10:30 AM", date: "14 Feb 2026", status: "success"),
            Transaction(type: "Referral Bonus", amountId: "TXN002", amount: "₹100", closingBalance: "₹2000", time: "2:15 PM", date: "13 Feb 2026", status: "success"),
            Transaction(type: "Withdrawal", amountId: "TXN003", amount: "₹1000", closingBalance: "₹1000", time: "5:45 PM", date: "12 Feb 2026", status: "pending"),
            Transaction(type: "News Reward", amountId: "TXN004", amount: "₹250", closingBalance: "₹2000", time: "9:00 AM", date: "11 Feb 2026", status: "success")
        ]
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TransactionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! transactionCell
        let transaction = transactions[indexPath.row]
        
        cell.typeLbl.text = transaction.type
        cell.amountidLbl.text = transaction.amountId
        cell.amountLbl.text = transaction.amount
        cell.closingbalanceLbl.text = transaction.closingBalance
        cell.timeLbl.text = transaction.time
        cell.dateLbl.text = transaction.date
        
        if transaction.type == "Withdrawal" {
            cell.statusimg.image = UIImage(named: "payout")
            if cell.statusimg.image == nil {
                cell.statusimg.image = UIImage(systemName: "arrow.up.circle.fill")
                cell.statusimg.tintColor = .systemRed
            }
        } else {
            cell.statusimg.image = UIImage(named: "credit")
            if cell.statusimg.image == nil {
                cell.statusimg.image = UIImage(systemName: "arrow.down.circle.fill")
                cell.statusimg.tintColor = .systemGreen
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
