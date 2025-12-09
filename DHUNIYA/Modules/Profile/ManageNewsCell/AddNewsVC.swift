//
//  AddNewsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 08/12/25.
//
import UIKit

class AddNewsVC: UIViewController {

       @IBOutlet weak var backBtn: UIButton!
       @IBOutlet weak var topVw: UIView!
      
    @IBOutlet weak var tblVw: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true

        setupTableView()
    }

    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        
        tblVw.register(UINib(nibName: "NewsAddCell", bundle: nil),
                       forCellReuseIdentifier: "NewsAddCell")
        
    }
    
       @IBAction func backButtonTapped(_ sender: UIButton) {
           self.navigationController?.popViewController(animated: true)
       }
}

extension AddNewsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsAddCell",
                                                 for: indexPath) as! NewsAddCell
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1350
    }
}
