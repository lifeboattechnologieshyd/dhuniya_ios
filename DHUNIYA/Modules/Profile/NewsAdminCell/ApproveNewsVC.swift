//
//  ApproveNewsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 06/12/25.
//

import UIKit

class ApproveNewsVC: UIViewController {
    
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    
    var newsList: [(title: String, desc: String)] = [
        ("Make this Headlines", "This news will stay as headlines until you remove it"),
        ("Notify Interested Users", "A Push notification will be sent to all Interested Users"),
        ("Notify All Users", "A Push notification will be sent to all All Users")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
    }
    
    func setupTable() {
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "ApproveCell", bundle: nil),
                       forCellReuseIdentifier: "ApproveCell")
        
        tblVw.separatorStyle = .none
    }
}

extension ApproveNewsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApproveCell", for: indexPath) as! ApproveCell
        
        let item = newsList[indexPath.row]
        cell.titleLbl.text = item.title
        cell.descriptionLbl.text = item.desc
        
        return cell
    }
    
}
