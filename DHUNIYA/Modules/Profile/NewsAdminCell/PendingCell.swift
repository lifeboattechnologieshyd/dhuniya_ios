//
//  PendingCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 05/12/25.
//

import UIKit

class PendingCell: UITableViewCell {
    
    @IBOutlet weak var reportername: UILabel!
    @IBOutlet weak var mediahouseLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var newsTitleLbl: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var languageandcategoryLbl: UILabel!
    @IBOutlet weak var deletebtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
