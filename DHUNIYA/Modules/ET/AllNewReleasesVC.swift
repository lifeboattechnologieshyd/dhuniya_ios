//
//  AllNewReleasesVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 18/12/25.
//

import UIKit
import Kingfisher

class AllNewReleasesVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var newReleases: [MediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "All New Releases"
        
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            UINib(nibName: "NewReleasesCell", bundle: nil),
            forCellWithReuseIdentifier: "NewReleasesCell"
        )
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
    }
}

extension AllNewReleasesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newReleases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NewReleasesCell",
            for: indexPath
        ) as! NewReleasesCell
        
        let item = newReleases[indexPath.row]
        let urlString = item.thumbnail_image ?? ""
        
        if !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let encoded = urlString.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            
            cell.imgVw.contentMode = .scaleAspectFill
            cell.imgVw.clipsToBounds = true
            cell.imgVw.layer.cornerRadius = 8
            
            cell.imgVw.kf.setImage(
                with: url,
                placeholder: UIImage(named: "news_placeholder"),
                options: [.transition(.fade(0.25))]
            )
        } else {
            cell.imgVw.image = UIImage(named: "news_placeholder")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 12
        let width = (collectionView.frame.width - spacing * 3) / 2
        return CGSize(width: width, height: 284)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let playerVC = storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as? PlayerVC else { return }
        
        playerVC.selectedItem = newReleases[indexPath.row]
        
        navigationController?.pushViewController(playerVC, animated: true)
    }
}
