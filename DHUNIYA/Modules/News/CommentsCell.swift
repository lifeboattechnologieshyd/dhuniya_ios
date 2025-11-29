//
//  CommentsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 29/11/25.
//

import UIKit

class CommentsCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var createddateLbl: UILabel!
    @IBOutlet weak var userpicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentLabel.numberOfLines = 0
    }
}

