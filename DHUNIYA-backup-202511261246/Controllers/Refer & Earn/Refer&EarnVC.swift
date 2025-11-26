//
//  Refer&Earn.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class ReferAndEarnVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topVw: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "RefferAndEarnCell", bundle: nil), forCellReuseIdentifier: "RefferAndEarnCell")
        tblVw.register(UINib(nibName: "RulesCell", bundle: nil), forCellReuseIdentifier: "RulesCell")
    }
    @IBAction func onBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension ReferAndEarnVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RefferAndEarnCell", for: indexPath) as! RefferAndEarnCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RulesCell", for: indexPath) as! RulesCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            return 214
        } else {
            return 460
        }
    }
}
