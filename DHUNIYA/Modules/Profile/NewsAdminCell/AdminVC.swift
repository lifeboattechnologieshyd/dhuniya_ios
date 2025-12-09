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
    
    let statusButtons = ["Pending","Approved", "Trending", "Rejected", "Deleted"]
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        setupCollectionView()
        setupTableView()
        
        colVw.reloadData()
    }
    
    func setupCollectionView() {
        colVw.delegate = self
        colVw.dataSource = self
        colVw.showsHorizontalScrollIndicator = false
        colVw.register(UINib(nibName: "NewsStatusCell", bundle: nil), forCellWithReuseIdentifier: "NewsStatusCell")
        
        if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
        }
    }
    
    func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.register(UINib(nibName: "PendingCell", bundle: nil), forCellReuseIdentifier: "PendingCell")
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
        
        cell.backgroundColor = (indexPath.item == selectedIndex) ? UIColor.systemBlue : UIColor.systemGray5
        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
        
        tblVw.reloadSections(IndexSet(0..<tblVw.numberOfSections), with: .none)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = statusButtons[indexPath.item]
        let width = title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)]).width + 30
        return CGSize(width: width, height: 40)
    }
}

extension AdminVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 122 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "PendingCell", for: indexPath)
    }
    
    // Bottom spacing between cells
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 10 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let submitVC = storyboard?.instantiateViewController(withIdentifier: "SubmitNewsVC") as? SubmitNewsVC {
            navigationController?.pushViewController(submitVC, animated: true)
        }
    }

    @IBAction func newsreportersBtnTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ManageNewsReporterVC") as? ManageNewsReporterVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
