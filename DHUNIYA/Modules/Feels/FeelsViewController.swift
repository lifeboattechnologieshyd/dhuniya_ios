//
//  FeelsViewController.swift
//  SchoolFirst
//
//  Created by Lifeboat on 16/10/25.
//

import UIKit

class FeelsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var page = 1
    var pageSize = 20
    var isLoading = false
    var canLoadMore = true
    
    var items = [FeelItem]()
    let keyword = "Why Do We Yawn"
    
    @IBOutlet weak var feelsLbl: UILabel!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var topVw: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        topVw.addBottomShadow()
        colVw.delegate = self
        colVw.dataSource = self
        
        colVw.register(UINib(nibName: "FeelsCollectionViewCell", bundle: nil),
                       forCellWithReuseIdentifier: "FeelsCollectionViewCell")
        
        getFeels()
    }
    
//    @IBAction func onClickBack(_ sender: UIButton) {
//        if let tab = self.tabBarController {
//            tab.selectedIndex = 0
//        }
//    }

    // MARK: CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colVw.dequeueReusableCell(withReuseIdentifier: "FeelsCollectionViewCell", for: indexPath) as! FeelsCollectionViewCell
        let item = items[indexPath.row]
        
        cell.imgVw.layer.cornerRadius = 8
        cell.btnPlay.tag = indexPath.row
        cell.btnShare?.tag = indexPath.row
        cell.btnLike?.tag = indexPath.row
        
        // Set initial values
        cell.lblName.text = item.title
        cell.likesLbl.text = "\(item.totalLikes ?? 0)"
        
        if let url = item.thumbnailImage {
            cell.imgVw.loadImage(url: url)
        } else if let videoURLString = item.youtubeVideo,
                  let youtubeId = videoURLString.extractYoutubeId() {
            cell.imgVw.loadImage(url: youtubeId.youtubeThumbnailURL())
        }
        
        // MARK: Button actions
        cell.playClicked = { index in
            self.navigateToPlayer(index: index)
        }
        
        cell.shareClicked = { index in
            let feel = self.items[index]
            self.openShareSheet(for: feel, cell: cell)
        }
        
        cell.likeClicked = { [weak self] index in
            guard let self = self else { return }
            let feel = self.items[index]
            let currentlyLiked = feel.isLiked ?? false
            
            // Optimistic UI update
            if let currentLikes = Int(cell.likesLbl.text ?? "0") {
                cell.likesLbl.text = currentlyLiked ? "\(currentLikes - 1)" : "\(currentLikes + 1)"
            }
            
            // Toggle like/unlike API
            self.toggleLikeFeel(feel: feel, isCurrentlyLiked: currentlyLiked) { success in
                if success {
                    self.items[index].isLiked = !currentlyLiked
                    if currentlyLiked {
                        self.items[index].totalLikes = max((self.items[index].totalLikes ?? 1) - 1, 0)
                    } else {
                        self.items[index].totalLikes = (self.items[index].totalLikes ?? 0) + 1
                    }
                } else {
                    // Revert UI if API fails
                    if let currentLikes = Int(cell.likesLbl.text ?? "0") {
                        cell.likesLbl.text = currentlyLiked ? "\(currentLikes + 1)" : "\(currentLikes - 1)"
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 8) / 2
        return CGSize(width: width, height: 284)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToPlayer(index: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight - 200 {
            if !isLoading && canLoadMore {
                page += 1
                getFeels()
            }
        }
    }
    
    // MARK: Navigation
    
    func navigateToPlayer(index: Int) {
        let stbd = UIStoryboard(name: "Feels", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "FeelPlayerController") as! FeelPlayerController
        vc.selected_feel_item = items[index]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: API Call
    
    func getFeels() {
        guard !isLoading else { return }
        isLoading = true
        
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(API.BASE_URL)ott_service/get/feels?keyword=\(encodedKeyword)&page=\(page)&page_size=\(pageSize)"
        
        NetworkManager.shared.request(urlString: urlString, method: .GET) { [weak self] (result: Result<APIResponse<[FeelItem]>, NetworkError>) in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success, let data = response.info {
                    if data.count < self.pageSize { self.canLoadMore = false }
                    if self.page == 1 { self.items = data }
                    else { self.items.append(contentsOf: data) }
                    DispatchQueue.main.async { self.colVw.reloadData() }
                } else {
                    DispatchQueue.main.async {
                        self.showFeelsAlert(response.description.isEmpty ? "Operation failed" : response.description)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showFeelsAlert(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: SHARE SHEET LOGIC
    
    func openShareSheet(for feel: FeelItem, cell: FeelsCollectionViewCell? = nil) {
        var shareItems: [Any] = [feel.title]
        if let youtube = feel.youtubeVideo {
            shareItems.append(youtube)
        }
        
        let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityVC.completionWithItemsHandler = { [weak self] _, completed, _, _ in
            guard let self = self else { return }
            if completed {
                self.shareFeel(feelId: feel.id)
            }
        }
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        self.present(activityVC, animated: true)
    }
    
    func shareFeel(feelId: String, completion: ((Bool) -> Void)? = nil) {
        let urlString = API.SHARE_FEEL
        let params = ["feel_id": feelId]
        
        NetworkManager.shared.request(urlString: urlString, method: .POST, parameters: params) { (result: Result<APIResponse<EmptyInfo>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion?(response.success)
                case .failure(_):
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: TOGGLE LIKE / UNLIKE FEEL
    
    func toggleLikeFeel(feel: FeelItem, isCurrentlyLiked: Bool, completion: ((Bool) -> Void)? = nil) {
        let urlString = isCurrentlyLiked ? "\(API.BASE_URL)ott_service/unlike/feel" : "\(API.BASE_URL)ott_service/like/feel"
        let params = ["feel_id": feel.id]
        
        NetworkManager.shared.request(urlString: urlString, method: .POST, parameters: params) { (result: Result<APIResponse<EmptyInfo>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion?(response.success)
                case .failure(_):
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: Alert
    
    func showFeelsAlert(_ message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
