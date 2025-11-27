//
//  EditReferalCode.swift
//  DHUNIYA
//
//  Created by Lifeboat on 27/11/25.
//
import UIKit

class EditReferalCodeVC: UIViewController {
    
    @IBOutlet weak var referalcodeVW: UIView!
    @IBOutlet weak var CodeTf: UITextField!
    @IBOutlet weak var comfirmButton: UIButton!
    @IBOutlet weak var referalRules: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)


    }
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
