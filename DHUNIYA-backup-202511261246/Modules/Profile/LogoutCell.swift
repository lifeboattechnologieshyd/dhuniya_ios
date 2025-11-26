//
//  LogoutCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class LogoutCell: UITableViewCell {
    
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var viewLogout: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("logout_clicked"), object: nil)
    }
}
