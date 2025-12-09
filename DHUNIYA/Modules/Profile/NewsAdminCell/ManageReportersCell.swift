//
//  ManageReportersCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 06/12/25.
//

import UIKit

class ManageReportersCell: UITableViewCell {
    
    @IBOutlet weak var reporterName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var submittedNumber: UILabel!
    @IBOutlet weak var rankLbl: UILabel!
    @IBOutlet weak var rejectedNumberLbl: UILabel!
    @IBOutlet weak var approvedNumberLbl: UILabel!
    @IBOutlet weak var submittedLbl: UILabel!
    @IBOutlet weak var earningsLbl: UILabel!
    @IBOutlet weak var rejectedLbl: UILabel!
    @IBOutlet weak var approvedLbl: UILabel!
    @IBOutlet weak var rankNumber: UILabel!
    @IBOutlet weak var mediaHouseLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
