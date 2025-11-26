//
//  BecomeNewsReporterVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class BecomeNewsReporterVC: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        
        self.navigationItem.hidesBackButton = true
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UINib(nibName: "ReportersCell", bundle: nil), forCellReuseIdentifier: "ReportersCell")
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension BecomeNewsReporterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportersCell", for: indexPath) as! ReportersCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1100
    }
}
