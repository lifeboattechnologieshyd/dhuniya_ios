//
//  ProfileEditCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

import UIKit

class ProfileEditCell: UITableViewCell {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var mobilrnumberLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var changepasswordButton: UIButton!
    @IBOutlet weak var mobilenumberTf: UITextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var usernamechangeButton: UIButton!
    @IBOutlet weak var usernameTf: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction func dateButtonTapped(_ sender: UIButton) {

        // 1. Create a date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels

        // 2. Create alert
        let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)

        // 3. Add picker to alert
        alert.view.addSubview(datePicker)
        datePicker.frame = CGRect(x: 10, y: 40, width: 250, height: 180)

        // 4. Add buttons
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            
            // Update label
            self.dateLbl.text = formatter.string(from: datePicker.date)
        }))

        // 5. Present alert using parentViewController
        self.parentViewController()?.present(alert, animated: true)
    }

}
