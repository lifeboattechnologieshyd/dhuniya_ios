//
//  transactionCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 14/02/26.
//

import UIKit

class transactionCell: UITableViewCell {

    @IBOutlet weak var statusimg: UIImageView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var amountidLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var closingbalanceLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
