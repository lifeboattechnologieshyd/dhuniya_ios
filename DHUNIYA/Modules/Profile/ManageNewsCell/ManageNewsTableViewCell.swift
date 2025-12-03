//
//  ManageNewsTableViewCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 03/12/25.
//


import UIKit

class ManageNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnNewsProfile: UIButton!
    @IBOutlet weak var btnDrafts: UIButton!
    @IBOutlet weak var btnAddNews: UIButton!
    @IBOutlet weak var manageNewsview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onBtnClickAddNews(_ sender: UIButton) {
    }
    
    @IBAction func onBtnClickDraftNews(_ sender: UIButton) {
    }
    
    @IBAction func onBtnClickNewsProfile(_ sender: UIButton) {
    }
    
}
