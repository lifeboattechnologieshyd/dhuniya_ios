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
    @IBOutlet weak var profileImage: UIImageView!
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
        
        self.navigationItem.hidesBackButton = true
        
        tblVw.delegate = self
                tblVw.dataSource = self
                tblVw.register(UINib(nibName: "SubmittedNewsCell", bundle: nil), forCellReuseIdentifier: "SubmittedNewsCell")
                
                setupProfileImageObserver(imageView: profileImage)
            }
            
            @IBAction func backButtonTapped(_ sender: UIButton) {
                self.navigationController?.popViewController(animated: true)
            }
        }
extension ReporterVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // each cell is its own section
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // 1 row per section
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmittedNewsCell", for: indexPath) as! SubmittedNewsCell
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
            cell.newsTitleLbl.text = "First submitted news"
        } else {
            cell.newsTitleLbl.text = "Second submitted news"
        }
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4// this will now be the gap between rows
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
}
