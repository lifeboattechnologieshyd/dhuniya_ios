//
//  GridVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 16/02/26.
//

import UIKit
import Kingfisher

class GridVC: UIViewController {
    
    @IBOutlet weak var selectedLbl: UILabel!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    var data: [BannerModel] = []
    var titleText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colVw.collectionViewLayout.invalidateLayout()
    }
    
    func setupUI() {
        selectedLbl.text = titleText
        
        colVw.delegate = self
        colVw.dataSource = self
        colVw.register(UINib(nibName: "BanerscolCell", bundle: nil), forCellWithReuseIdentifier: "BanerscolCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.estimatedItemSize = .zero
        colVw.collectionViewLayout = layout
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    func navigateToFullscreen(selectedIndex: Int) {
        let storyboard = UIStoryboard(name: "DBuzz", bundle: nil)
        if let fullscreenVC = storyboard.instantiateViewController(withIdentifier: "FullscreenVC") as? FullscreenVC {
            fullscreenVC.data = data
            fullscreenVC.selectedIndex = selectedIndex
            fullscreenVC.titleText = titleText
            navigationController?.pushViewController(fullscreenVC, animated: true)
        }
    }
}

extension GridVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BanerscolCell", for: indexPath) as! BanerscolCell
        if let images = data[indexPath.row].images, let firstImage = images.first, let imageUrl = firstImage {
            cell.imgVw.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "placeholder"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToFullscreen(selectedIndex: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leftInset: CGFloat = 10
        let rightInset: CGFloat = 10
        let spacing: CGFloat = 10
        let totalWidth = collectionView.frame.width
        let availableWidth = totalWidth - leftInset - rightInset - spacing
        let cellWidth = availableWidth / 2
        let cellHeight = cellWidth * 1.29
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
