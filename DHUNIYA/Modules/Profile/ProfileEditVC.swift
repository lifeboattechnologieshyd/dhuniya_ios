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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        topVw.addBottomShadow()
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "ProfileEditCell", bundle: nil),
                       forCellReuseIdentifier: "ProfileEditCell")
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ProfileEditVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 550
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileEditCell",
                                                 for: indexPath)
        return cell
    }
}
