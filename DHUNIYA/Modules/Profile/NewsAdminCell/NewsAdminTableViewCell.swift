//
//  NewsAdminTableViewCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 03/12/25.
//

import UIKit

class NewsAdminTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var newsAdminView: UIView!
    @IBOutlet weak var btnApprovedNews: UIButton!
    @IBOutlet weak var btnPendingNews: UIButton!
    @IBOutlet weak var btnAddNews: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
         
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onBtnClickPendingNews(_ sender: UIButton) {
    }
    
    
    @IBAction func onBtnClickApprovedNews(_ sender: UIButton) {
    }
    
    
    @IBAction func onBtnClickAddNews(_ sender: UIButton) {
    }
}
