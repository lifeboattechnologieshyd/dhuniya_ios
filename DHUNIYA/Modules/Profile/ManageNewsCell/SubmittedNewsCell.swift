//
//  SubmittedNewsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 03/12/25.
//

import UIKit

class SubmittedNewsCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitleLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var updatedtimeLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
