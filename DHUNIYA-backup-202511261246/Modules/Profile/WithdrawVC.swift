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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        self.navigationItem.hidesBackButton = true

        
    }
        @IBAction func backButtonTapped(_ sender: UIButton) {
              self.navigationController?.popViewController(animated: true)
        
    }
}
