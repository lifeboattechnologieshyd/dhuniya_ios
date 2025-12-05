//
//  NewsStatusCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 05/12/25.
//

import UIKit

class NewsStatusCell: UICollectionViewCell {
    
    @IBOutlet weak var pendingBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with title: String) {
        pendingBtn.setTitle(title, for: .normal)
    }
}
