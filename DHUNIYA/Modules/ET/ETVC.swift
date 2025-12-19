//
//  ETVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit
import Kingfisher

class ETVC: UIViewController {
    
    @IBOutlet weak var btnWishlist: UIButton!
    @IBOutlet weak var btnMydownloads: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var viewallNewreleases: UIButton!
    @IBOutlet weak var bannerColVw: UICollectionView!
    @IBOutlet weak var newreleaseColVw: UICollectionView!
    
    var bannerData: [MediaItem] = []
    var newReleaseData: [MediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViews()
        callHomeAPI()
    }

override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    // Add bottom shadow to topVw
    topVw.addBottomShadow()
}
}


extension ETVC {
    
    func setupCollectionViews() {
        
        bannerColVw.delegate = self
        bannerColVw.dataSource = self
        newreleaseColVw.delegate = self
        newreleaseColVw.dataSource = self
        
        bannerColVw.register(
            UINib(nibName: "BannerCell", bundle: nil),
            forCellWithReuseIdentifier: "BannerCell"
        )
        
        newreleaseColVw.register(
            UINib(nibName: "NewReleasesCell", bundle: nil),
            forCellWithReuseIdentifier: "NewReleasesCell"
        )
        
        if let layout = bannerColVw.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        bannerColVw.isPagingEnabled = true
        bannerColVw.showsHorizontalScrollIndicator = false
        
        if let layout2 = newreleaseColVw.collectionViewLayout as? UICollectionViewFlowLayout {
            layout2.scrollDirection = .vertical
            layout2.minimumLineSpacing = 8
            layout2.minimumInteritemSpacing = 8
            layout2.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        }
    }
    
    @IBAction func viewAllNewReleasesButtonTapped(_ sender: UIButton) {
        guard let allNewReleasesVC = storyboard?.instantiateViewController(withIdentifier: "AllNewReleasesVC") as? AllNewReleasesVC else { return }
        
        allNewReleasesVC.newReleases = self.newReleaseData
        
        navigationController?.pushViewController(allNewReleasesVC, animated: true)
    }
}

extension ETVC {
    
    func callHomeAPI() {
        
        NetworkManager.shared.request(urlString: API.HOME) {
            (result: Result<APIResponse<HomeInfo>, NetworkError>) in
            
            switch result {
                
            case .success(let response):
                print("✅ API Success")
                print("Total items: \(response.total)")
                
                if let info = response.info {
                    
                    print("Banners Count: \(info.banners?.count ?? 0)")
                    print("New Releases Count: \(info.new_releases?.count ?? 0)")
                    
                    info.banners?.forEach {
                        print("Banner: \($0.title ?? "No Title")")
                        print("  - Thumbnail: \($0.thumbnail_image ?? "none")")
                        print("  - Cover: \($0.cover_image ?? "none")")
                    }
                    
                    info.new_releases?.forEach {
                        print("New Release: \($0.title ?? "No Title")")
                    }
                    
                    self.bannerData = info.banners ?? []
                    self.newReleaseData = info.new_releases ?? []
                    
                    DispatchQueue.main.async {
                        self.bannerColVw.reloadData()
                        self.newreleaseColVw.reloadData()
                    }
                }
                
            case .failure(let error):
                print("❌ API Error:", error)
            }
        }
    }
}

extension ETVC: UICollectionViewDelegate,
                UICollectionViewDataSource,
                UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return collectionView == bannerColVw
        ? bannerData.count
        : newReleaseData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        
        if collectionView == bannerColVw {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "BannerCell",
                for: indexPath
            ) as! BannerCell
            
            let item = bannerData[indexPath.row]
            
            //Use COVER_IMAGE for banners (full image)
            let urlString = item.cover_image ?? item.thumbnail_image ?? ""
            
            
            if !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let encoded = urlString.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encoded) {
                
                cell.imageVw.contentMode = .scaleAspectFit
                cell.imageVw.clipsToBounds = true
                cell.imageVw.backgroundColor = .black
                
                cell.imageVw.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "news_placeholder"),
                    options: [
                        .transition(.fade(0.25)),
                        .cacheOriginalImage
                    ]
                )
            } else {
                cell.imageVw.image = UIImage(named: "news_placeholder")
            }
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "NewReleasesCell",
                for: indexPath
            ) as! NewReleasesCell
            
            let item = newReleaseData[indexPath.row]
            
            // Use THUMBNAIL_IMAGE for grid view
            let urlString = item.thumbnail_image ?? ""
            
            if !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let encoded = urlString.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encoded) {
                
                   
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
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        guard let playerVC = storyboard?
            .instantiateViewController(withIdentifier: "PlayerVC")
                as? PlayerVC else { return }
        
        playerVC.videoURL = collectionView == bannerColVw
        ? bannerData[indexPath.row].cover_image ?? ""
        : newReleaseData[indexPath.row].cover_image ?? ""
        
        playerVC.selectedItem = collectionView == bannerColVw
        ? bannerData[indexPath.row]
        : newReleaseData[indexPath.row]
        
        navigationController?.pushViewController(playerVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == bannerColVw {
            
            // Full width banner
            let width = collectionView.frame.width
            let height: CGFloat = 192
            
            return CGSize(width: width, height: height)
            
        } else {
            
            let spacing: CGFloat = 8
            let width = (collectionView.frame.width - spacing) / 2
            return CGSize(width: width, height: 284)
        }
    }
}
