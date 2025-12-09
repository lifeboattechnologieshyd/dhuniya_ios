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
    }
    
    @IBAction func onBtnClickAddNews(_ sender: UIButton) {
        if let parentVC = self.parentViewController() {
            let storyboard = UIStoryboard(name: "Reporter", bundle: nil)
            if let AddNewsVC = storyboard.instantiateViewController(withIdentifier: "AddNewsVC") as? AddNewsVC {
                // Push the instance, not the type
                parentVC.navigationController?.pushViewController(AddNewsVC, animated: true)
            }
        }
    }
    
}
