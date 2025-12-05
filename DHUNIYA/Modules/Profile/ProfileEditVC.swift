//
//  ProfileEditVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

import UIKit

class ProfileEditVC: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backbtn: UIButton!
    
    var profileData: ProfileDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        topVw.addBottomShadow()
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "ProfileEditCell", bundle: nil),
                       forCellReuseIdentifier: "ProfileEditCell")
        
        // Load profile data from session
        loadProfileData()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        // Update profile automatically before going back
        if let cell = tblVw.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileEditCell {
            let username = cell.usernameTf.text
            let mobile = cell.mobilenumberTf.text
            let dob = cell.dateLbl.text
            let gender = cell.maleButton.isSelected ? "MALE" : (cell.femaleButton.isSelected ? "FEMALE" : "OTHERS")
            updateProfile(username: username, mobile: mobile, dob: dob, gender: gender)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadProfileData() {
        if let user = Session.shared.userDetails {
            profileData = user
            tblVw.reloadData()
        }
    }
    
    func updateProfile(username: String?, mobile: String?, dob: String?, gender: String?) {
        let request = EditProfileRequest(username: username, mobile: mobile, dob: dob, gender: gender)
        

    }
}

extension ProfileEditVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 550
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditCell", for: indexPath) as? ProfileEditCell else {
            return UITableViewCell()
        }
        
        if let profile = profileData {
            cell.usernameTf.text = profile.username
            cell.mobilenumberTf.text = "\(profile.mobile)"
            cell.dateLbl.text = profile.dob
            cell.genderLbl.text = profile.gender
            cell.maleButton.isSelected = profile.gender?.uppercased() == "MALE"
            cell.femaleButton.isSelected = profile.gender?.uppercased() == "FEMALE"
        }
        
        // Handle DOB picker inside the cell
        cell.dateButtonAction = { [weak self] selectedDate in
            let username = cell.usernameTf.text
            let mobile = cell.mobilenumberTf.text
            let gender = cell.maleButton.isSelected ? "MALE" : (cell.femaleButton.isSelected ? "FEMALE" : "OTHERS")
            self?.updateProfile(username: username, mobile: mobile, dob: selectedDate, gender: gender)
        }
        
        // Handle gender button changes
        cell.genderChangedAction = { [weak self] in
            let username = cell.usernameTf.text
            let mobile = cell.mobilenumberTf.text
            let dob = cell.dateLbl.text
            let gender = cell.maleButton.isSelected ? "MALE" : (cell.femaleButton.isSelected ? "FEMALE" : "OTHERS")
            self?.updateProfile(username: username, mobile: mobile, dob: dob, gender: gender)
        }
        
        return cell
    }
}
