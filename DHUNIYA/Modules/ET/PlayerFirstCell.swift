//
//  PlayerFirstCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 17/12/25.
//

import UIKit

class PlayerFirstCell: UITableViewCell {
    
    @IBOutlet weak var hStackView: UIStackView!
    @IBOutlet weak var lblWatchList: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var lblShare: UILabel!
    
    // Closures
    var onShareTapped: (() -> Void)?
    var onWatchListTapped: (() -> Void)?
    var onReviewTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnWatchListTapped(_ sender: UIButton) {
        onWatchListTapped?()
    }
    
    @IBAction func btnReviewTapped(_ sender: UIButton) {
        onReviewTapped?()
    }
    
    @IBAction func btnShareTapped(_ sender: UIButton) {
        onShareTapped?()
    }
}
