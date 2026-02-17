//
//  FullCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 16/02/26.
//

import UIKit

class FullCell: UITableViewCell {

    @IBOutlet weak var whatsappBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var imgVw: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgVw.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

