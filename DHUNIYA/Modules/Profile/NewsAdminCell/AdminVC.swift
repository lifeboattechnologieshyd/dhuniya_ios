//
//  AdminVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 05/12/25.
//

import UIKit

class AdminVC: UIViewController {

    @IBOutlet weak var newsreportersBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var colVw: UICollectionView!
    
    let statusButtons = ["Approved", "Trending", "Rejected", "Deleted", "Pending"]
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTableView()
        
        colVw.reloadData()
    }
    
    func setupCollectionView() {
        colVw.delegate = self
        colVw.dataSource = self
        
        if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        colVw.showsHorizontalScrollIndicator = false
        colVw.register(UINib(nibName: "NewsStatusCell", bundle: nil), forCellWithReuseIdentifier: "NewsStatusCell")
    }
    
    func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UITableViewCell.self, forCellReuseIdentifier: "PendingCell")
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension AdminVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsStatusCell", for: indexPath) as! NewsStatusCell
        let title = statusButtons[indexPath.item]
        cell.configure(with: title)
        
        // Highlight selected button
        if indexPath.item == selectedIndex {
            cell.pendingBtn.backgroundColor = UIColor.systemBlue
            cell.pendingBtn.setTitleColor(.white, for: .normal)
        } else {
            cell.pendingBtn.backgroundColor = UIColor.lightGray
            cell.pendingBtn.setTitleColor(.black, for: .normal)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData() // Update highlight
        
        // TODO: Filter table view data based on selected button
        tblVw.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = statusButtons[indexPath.item]
        let width = title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)]).width + 20
        return CGSize(width: width, height: 40)
    }
}

extension AdminVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingCell", for: indexPath)
        cell.textLabel?.text = "\(statusButtons[selectedIndex]) Row \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
