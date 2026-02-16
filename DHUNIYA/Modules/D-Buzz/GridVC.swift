//
//  GridVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 16/02/26.
//

import UIKit
import Kingfisher

class GridVC: UIViewController {
    
    @IBOutlet weak var colVw: UICollectionView!
    
    var data: [BannerModel] = []
    var titleText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colVw.collectionViewLayout.invalidateLayout()
    }
    
    func setupUI() {
        title = titleText
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
