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
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var feelsLbl: UILabel!
    @IBOutlet weak var colVw: UICollectionView!
    @IBOutlet weak var topVw: UIView!
    var items = [FeelItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        colVw.delegate = self
        colVw.dataSource = self
        
        colVw.register(UINib(nibName: "FeelsCollectionViewCell", bundle: nil),
                       forCellWithReuseIdentifier: "FeelsCollectionViewCell")
        
     //   getEdutainment()
    }
    @IBAction func onClickBack(_ sender: UIButton) {
        print("Back pressed macha!!!")

        // 1. If pushed → pop
        if let nav = self.navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
            return
        }

        // 2. If presented → dismiss
        if self.presentingViewController != nil {
            self.dismiss(animated: true)
            return
        }

        // 3. If inside a nav controller that was presented as root → dismiss nav
        if let nav = self.navigationController, nav.presentingViewController != nil {
            nav.dismiss(animated: true)
            return
        }

        print("⚠️ No navigation or presentation context found macha!")
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = colVw.dequeueReusableCell(withReuseIdentifier: "FeelsCollectionViewCell",
                                             for: indexPath) as! FeelsCollectionViewCell
        
        cell.imgVw.layer.cornerRadius = 8
        cell.btnPlay.tag = indexPath.row
        
        if let url = self.items[indexPath.row].thumbnailImage {
            cell.imgVw.loadImage(url: url)
        } else {
            if let urlstring = "\(self.items[indexPath.row].youtubeVideo!)".extractYoutubeId() {
                cell.imgVw.loadImage(url: urlstring.youtubeThumbnailURL())
            }
        }
        
        cell.playClicked = { index in
            self.navigateToPlayer(index: index)
        }
        
        cell.lblName.text = self.items[indexPath.row].title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 8) / 2
        return CGSize(width: width, height: 284)
    }
    
    func navigateToPlayer(index: Int) {
        let stbd = UIStoryboard(name: "Feels", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "FeelPlayerController") as! FeelPlayerController
        vc.selected_feel_item = items[index]
        navigationController?.pushViewController(vc, animated: true)
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
          //      getEdutainment()
            }
        }
    }
    
    //    func getEdutainment() {
    //
    //        guard !isLoading else { return }
    //        isLoading = true
    //
    //        let url = API.EDUTAIN_FEEL + "?page_size=\(pageSize)&page=\(page)"
    //
    //        NetworkManager.shared.request(urlString: url, method: .GET)
    //        { [weak self] (result: Result<APIResponse<[FeelItem]>, NetworkError>) in
    //
    //            guard let self = self else { return }
    //            self.isLoading = false
    //
    //            switch result {
    //            case .success(let info):
    //
    //                if info.success {
    //                    if let data = info.data {
    //
    //                         if data.count < self.pageSize {
    //                            self.canLoadMore = false
    //                        }
    //
    //                        if self.page == 1 {
    //                            self.items = data
    //                        } else {
    //                            self.items.append(contentsOf: data)
    //                        }
    //                    }
    //
    //                    DispatchQueue.main.async {
    //                        self.colVw.reloadData()
    //                    }
    //                } else {
    //                    self.showAlert(msg: info.description)
    //                }
    //
    //            case .failure(let error):
    //                self.showAlert(msg: error.localizedDescription)
    //            }
    //        }
    //    }
    //}
    //
}
