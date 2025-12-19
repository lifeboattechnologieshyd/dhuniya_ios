//
//  PublishedCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 17/12/25.
//

import UIKit

class PublishedCell: UITableViewCell {
    
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitleLbl: UILabel!
    @IBOutlet weak var updatedtimeLbl: UILabel!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var whatsappLbl: UILabel!
    @IBOutlet weak var btnWhatsapp: UIButton!
    @IBOutlet weak var shareLbl: UILabel!
    @IBOutlet weak var viewsLbl: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
