//
//  CartoonCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 16/02/26.
//

import UIKit
import Kingfisher

class CartoonCell: UITableViewCell {
    @IBOutlet weak var viewallBtn: UIButton!
    @IBOutlet weak var colVw: UICollectionView!
    
    var data: [BannerModel] = []
    var onItemSelected: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        colVw.delegate = self
        colVw.dataSource = self
        colVw.register(UINib(nibName: "BanerscolCell", bundle: nil), forCellWithReuseIdentifier: "BanerscolCell")
        if let layout = colVw.collectionViewLayout as? UICollectionViewFlowLayout {
    
        }
    }
    
    func configureCell(with data: [BannerModel]) {
        self.data = data
        colVw.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension CartoonCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        print("Cartoon cell tapped at index: \(indexPath.row)")
        onItemSelected?(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 96, height: 124)
    }
}
