//
//  ManageNewsReporterVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 06/12/25.
//

import UIKit

class ManageNewsReporterVC: UIViewController {
    
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var BlockedBtn: UIButton!
    @IBOutlet weak var activeBtn: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "ManageReportersCell", bundle: nil), forCellReuseIdentifier: "ManageReportersCell")
        
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension ManageNewsReporterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageReportersCell", for: indexPath) as! ManageReportersCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138
    }
}
