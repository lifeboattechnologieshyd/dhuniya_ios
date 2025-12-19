//
//  FeelsFirst.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class FeelsCollectionViewCell: UICollectionViewCell {
    
    var shareClicked: ((Int) -> Void)?
    var likeClicked: ((Int) -> Void)?

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var imgVw: UIImageView!
    
    var playClicked: ((Int) -> Void)?

    @IBAction func onClickPlay(_ sender: UIButton) {
        self.playClicked?(sender.tag)
    }
    
    @IBAction func onClickShare(_ sender: UIButton) {
        shareClicked?(sender.tag)
    }
    
    @IBAction func onClickLike(_ sender: UIButton) {
        likeClicked?(sender.tag)
    }
}
