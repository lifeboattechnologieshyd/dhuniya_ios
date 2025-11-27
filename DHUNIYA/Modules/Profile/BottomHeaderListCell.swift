//
//  BottomHeaderListCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class BottomHeaderListCell: UITableViewCell {
    
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblRateUs: UILabel!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var rateUsView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var rateusBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var MainView: UIView!

    var contactUs: (() -> Void)?
    var rateUs: (() -> Void)?
    var shareApp: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func contactTapped(_ sender: UIButton) {
        contactUs?()
    }

    @IBAction func rateTapped(_ sender: UIButton) {
        rateUs?()
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        shareApp?()
    }
}
