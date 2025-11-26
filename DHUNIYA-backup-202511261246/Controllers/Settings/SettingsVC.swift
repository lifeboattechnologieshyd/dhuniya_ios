//
//  SettingsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tblVw: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        self.navigationController?.setNavigationBarHidden(true, animated: false)


        tblVw.delegate = self
        tblVw.dataSource = self

        tblVw.register(UINib(nibName: "SettingsCell", bundle: nil),forCellReuseIdentifier: "SettingsCell")
    }
    @IBAction func onBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingsCell",
            for: indexPath
        ) as! SettingsCell

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 650
    }
}
