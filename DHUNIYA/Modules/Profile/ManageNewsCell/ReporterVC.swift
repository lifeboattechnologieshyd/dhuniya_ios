//
//  ReporterVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 03/12/25.
//

import UIKit
class ReporterVC: UIViewController {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var lblPhonenumber: UILabel!
    @IBOutlet weak var btnProfilepic: UIButton!
    @IBOutlet weak var profilrimage: UIImageView!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var rankVw: UIView!
    @IBOutlet weak var publishVw: UIView!
    @IBOutlet weak var ranknumberLbl: UILabel!
    @IBOutlet weak var noofpublished: UILabel!
    @IBOutlet weak var viewsVw: UIView!
    @IBOutlet weak var noofViewsLbl: UILabel!
    @IBOutlet weak var interactionsVw: UIView!
    @IBOutlet weak var noofinteractionsLbl: UILabel!
    @IBOutlet weak var earningsLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var withdrawBtn: UIButton!
    @IBOutlet weak var publishnewarticleBtn: UIButton!
    @IBOutlet weak var submittedBtn: UIButton!
    @IBOutlet weak var publishedBtn: UIButton!
    @IBOutlet weak var rejectedBtn: UIButton!
    @IBOutlet weak var draftsBtn: UIButton!
    
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        
        tblVw.register(UINib(nibName: "SubmittedNewsCell", bundle: nil), forCellReuseIdentifier: "SubmittedNewsCell")
        
    }
}
        extension ReporterVC: UITableViewDelegate, UITableViewDataSource {
            
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return 2 
            }
            
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "SubmittedNewsCell",
                    for: indexPath
                ) as! SubmittedNewsCell
                
                cell.selectionStyle = .none
                
                if indexPath.row == 0 {
                    cell.newsTitleLbl.text = "First submitted news"
                } else {
                    cell.newsTitleLbl.text = "Second submitted news"
                }
                
                return cell
            }
            private func tblVw(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return tableView.frame.size.height
            }
        }
    
