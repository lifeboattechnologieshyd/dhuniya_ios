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
    
    var dateButtonAction: ((String) -> Void)?
    var genderChangedAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.view.addSubview(datePicker)
        datePicker.frame = CGRect(x: 10, y: 40, width: 250, height: 180)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let selectedDate = formatter.string(from: datePicker.date)
            self.dateLbl.text = selectedDate
            self.dateButtonAction?(selectedDate) // Notify VC
        }))
        
        self.parentViewController()?.present(alert, animated: true)
    }
    
    @IBAction func maleButtonTapped(_ sender: UIButton) {
        maleButton.isSelected = true
        femaleButton.isSelected = false
        genderChangedAction?() // Notify VC
    }
    
    @IBAction func femaleButtonTapped(_ sender: UIButton) {
        femaleButton.isSelected = true
        maleButton.isSelected = false
        genderChangedAction?() // Notify VC
    }
}
