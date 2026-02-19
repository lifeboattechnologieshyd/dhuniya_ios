//
//  NewsVC.swift
//  DHUNIYA
//

import UIKit
import GoogleMobileAds

class NewsVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    var newsList = [NewsModel]()
    var currentPage = 1
    var totalPages = 10
    var isLoading = false
    var tableItems: [Any] = []
    
    var nativeAdsCache: [Int: NativeAd] = [:]
    var loadingAdIndexes: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = [.top]
        self.extendedLayoutIncludesOpaqueBars = false
        setupTableView()
        getNews()
        
        fetchUserLocation { result in
            switch result {
            case .success(let location):
                print("User Location:", location)
            case .failure(let error):
                print("Failed to fetch location:", error)
            }
        }
    }
    
    func getNews(limit: Int = 10) {
        guard !isLoading else { return }
        isLoading = true
        
        if currentPage == 1 {
            showLoader()
        }
        let urlString = "\(API.GET_NEWS)?offset=\(currentPage)&limit=\(limit)"
        
        NetworkManager.shared.request(urlString: urlString) { (result: Result<APIResponse<[NewsModel]>, NetworkError>) in
            DispatchQueue.main.async {
                self.isLoading = false
                self.hideLoader()
                
                switch result {
                case .success(let response):
                    if let data = response.info {
                        if self.currentPage == 1 {
                            self.newsList = data
                        } else {
                            self.newsList.append(contentsOf: data)
                        }
                        
                        self.prepareTableItems()
                        self.preloadNativeAds()
                        self.tblVw.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func prepareTableItems() {
        tableItems.removeAll()
        
        for (index, news) in newsList.enumerated() {
            tableItems.append(news)
            
            if (index + 1) % 4 == 0 {
                let adIdentifier = "NATIVE_AD_\(tableItems.count)"
                tableItems.append(adIdentifier)
            }
        }
        
        print("📋 Total tableItems: \(tableItems.count), News: \(newsList.count)")
    }
    
    func preloadNativeAds() {
        for (index, item) in tableItems.enumerated() {
            if let adIdentifier = item as? String, adIdentifier.hasPrefix("NATIVE_AD") {
                if nativeAdsCache[index] == nil && !loadingAdIndexes.contains(index) {
                    loadNativeAd(for: index)
                }
            }
        }
    }
    
    func loadNativeAd(for index: Int) {
        guard nativeAdsCache[index] == nil else { return }
        guard !loadingAdIndexes.contains(index) else { return }
        
        loadingAdIndexes.insert(index)
        print("🔄 Loading native ad for index: \(index)")
        
        NativeAdManager.shared.loadNativeAd(from: self) { [weak self] nativeAd in
            guard let self = self else { return }
            
            self.loadingAdIndexes.remove(index)
            
            guard let ad = nativeAd else {
                print("❌ Failed to load native ad for index: \(index)")
                return
            }
            
            print("✅ Native ad loaded and cached for index: \(index)")
            self.nativeAdsCache[index] = ad
            
            DispatchQueue.main.async {
                if index < self.tableItems.count {
                    let indexPath = IndexPath(row: index, section: 0)
                    if self.tblVw.indexPathsForVisibleRows?.contains(indexPath) == true {
                        self.tblVw.reloadRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.separatorStyle = .none
        tblVw.isPagingEnabled = true
        tblVw.showsVerticalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            tblVw.contentInsetAdjustmentBehavior = .never
        }
        
        tblVw.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tblVw.register(FullScreenNativeAdCell.self, forCellReuseIdentifier: FullScreenNativeAdCell.identifier)
    }
    
    // Get 3 recommended news after ad position
    func getRecommendedNews(afterAdAt tableIndex: Int) -> [NewsModel] {
        var recommended: [NewsModel] = []
        
        // Get news after ad
        for i in (tableIndex + 1)..<tableItems.count {
            if let news = tableItems[i] as? NewsModel {
                recommended.append(news)
                if recommended.count >= 3 { break }
            }
        }
        
        // If not enough, get from beginning
        if recommended.count < 3 {
            for i in 0..<min(tableIndex, tableItems.count) {
                if recommended.count >= 3 { break }
                if let news = tableItems[i] as? NewsModel,
                   !recommended.contains(where: { $0.id == news.id }) {
                    recommended.append(news)
                }
            }
        }
        
        return recommended
    }
    
    func formatDateTime(_ date: Date) -> String {
        let now = Date()
        let secondsIn24Hours: TimeInterval = 24 * 60 * 60
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if now.timeIntervalSince(date) < secondsIn24Hours {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "dd MMM yyyy"
        }
        
        return formatter.string(from: date)
    }
    
    func convertToDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }
    
    func getNewsIndex(for tableIndex: Int) -> Int {
        var newsCount = 0
        for i in 0..<tableIndex {
            if tableItems[i] is NewsModel {
                newsCount += 1
            }
        }
        return newsCount
    }
    
    func fetchUserLocation(completion: @escaping (Result<LocationResponse, NetworkError>) -> Void) {
        print("📍 Starting fetchUserLocation request...")
        
        NetworkManager.shared.requestRaw(
            urlString: API.USER_LOCATION
        ) { (result: Result<LocationResponse, NetworkError>) in
            switch result {
            case .success(let location):
                print("✅ Location:", location)
                Session.shared.userLocation = location
                completion(.success(location))
                
            case .failure(let error):
                print("❌ Error:", error)
                completion(.failure(error))
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension NewsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = tableItems[indexPath.row]
        
        // Native Ad Cell
        if let adIdentifier = item as? String, adIdentifier.hasPrefix("NATIVE_AD") {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FullScreenNativeAdCell.identifier,
                for: indexPath
            ) as! FullScreenNativeAdCell
            
            // Get recommended news for this ad
            let recommendedNews = getRecommendedNews(afterAdAt: indexPath.row)
            
            // Configure with cached ad if available
            if let nativeAd = nativeAdsCache[indexPath.row] {
                print("📢 Displaying native ad at index: \(indexPath.row)")
                cell.configure(nativeAd: nativeAd, relatedNews: recommendedNews)
            } else {
                print("⏳ Native ad not yet loaded for index: \(indexPath.row)")
                cell.showLoading()
                loadNativeAd(for: indexPath.row)
            }
            
            // Handle news click - scroll to that news
            cell.onNewsClick = { [weak self] index, news in
                guard let self = self else { return }
                print("📰 Tapped news: \(news.title)")
                
                // Find news index in tableItems and scroll
                if let newsIndex = self.tableItems.firstIndex(where: { ($0 as? NewsModel)?.id == news.id }) {
                    let targetIndexPath = IndexPath(row: newsIndex, section: 0)
                    self.tblVw.scrollToRow(at: targetIndexPath, at: .top, animated: true)
                }
            }
            
            return cell
        }
        
        // News Cell
        guard let news = item as? NewsModel else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        let newsIndex = getNewsIndex(for: indexPath.row)
        
        cell.newsTitle.text = news.title
        cell.newsTextView.text = news.description
        cell.likeLbl.text = "\(news.likes_count)"
        cell.commentLbl.text = "\(news.comments_count)"
        
        cell.updateLikeUI(isLiked: news.is_liked == true)
        
        if news.language.uppercased() == "TELUGU" {
            cell.newsTextView.setupLineSpacing(lineSpace: 8, font: CustomFonts.LR16.font)
            cell.newsTitle.setupLineSpacing(lineSpace: 10, font: CustomFonts.LSB18.font)
        } else {
            cell.newsTitle.font = FontManager.englishTitle(16)
            cell.newsTextView.font = FontManager.englishBody(14)
        }
        
        if let date = convertToDate(news.created_date) {
            cell.uploadedTime.text = formatDateTime(date)
        } else {
            cell.uploadedTime.text = news.created_date
        }
        
        cell.NewsImg.setKFImage(news.image?.first)
        
        cell.likeButton.tag = newsIndex
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        cell.onCommentButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "News", bundle: nil)
            if let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC {
                
                commentsVC.newsId = news.id
                
                commentsVC.onCommentAdded = {
                    self.newsList[newsIndex].comments_count += 1
                    self.prepareTableItems()
                    
                    DispatchQueue.main.async {
                        self.tblVw.reloadRows(
                            at: [IndexPath(row: indexPath.row, section: 0)],
                            with: .none
                        )
                    }
                }
                
                commentsVC.modalPresentationStyle = .overFullScreen
                commentsVC.modalTransitionStyle = .crossDissolve
                self.present(commentsVC, animated: true)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = tableItems[indexPath.row]
        if let adIdentifier = item as? String,
           adIdentifier.hasPrefix("NATIVE_AD"),
           nativeAdsCache[indexPath.row] == nil {
            loadNativeAd(for: indexPath.row)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 200 {
            loadNextPage()
        }
    }
    
    func loadNextPage() {
        guard !isLoading else { return }
        currentPage += 1
        getNews()
    }
}

// MARK: - Like/Dislike Actions

extension NewsVC {
    
    @objc private func likeButtonTapped(_ sender: UIButton) {
        let newsIndex = sender.tag
        
        guard newsIndex < newsList.count else { return }
        
        let news = newsList[newsIndex]
        
        if news.is_liked == true {
            sendDislikeRequest(newsId: news.id) { success in
                DispatchQueue.main.async {
                    if success {
                        self.newsList[newsIndex].likes_count -= 1
                        self.newsList[newsIndex].is_liked = false
                        self.prepareTableItems()
                        self.tblVw.reloadData()
                    }
                }
            }
        } else {
            sendLikeRequest(newsId: news.id) { success in
                DispatchQueue.main.async {
                    if success {
                        self.newsList[newsIndex].likes_count += 1
                        self.newsList[newsIndex].is_liked = true
                        self.prepareTableItems()
                        self.tblVw.reloadData()
                    }
                }
            }
        }
    }
    
    private func sendLikeRequest(newsId: Int, completion: @escaping (Bool) -> Void) {
        let payload: [String: Any] = ["news_id": newsId]
        
        NetworkManager.shared.request(
            urlString: API.NEWS_LIKE,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<LikeInfo>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(response.success)
            case .failure(let error):
                print("Like API failed:", error)
                completion(false)
            }
        }
    }
    
    private func sendDislikeRequest(newsId: Int, completion: @escaping (Bool) -> Void) {
        let payload: [String: Any] = ["news_id": newsId]
        
        NetworkManager.shared.request(
            urlString: API.NEWS_DISLIKE,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<DislikeInfo>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(response.success)
            case .failure(let error):
                print("Dislike API failed:", error)
                completion(false)
            }
        }
    }
}

// MARK: - Comment Actions

extension NewsVC {
    
    func sendCommentRequest(newsId: Int, comment: String, completion: @escaping (Bool) -> Void) {
        let payload: [String: Any] = [
            "news_id": newsId,
            "comment": comment
        ]
        
        NetworkManager.shared.request(
            urlString: API.NEWS_COMMENTS,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<CommentResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(response.success)
            case .failure(let error):
                print("Comment API failed:", error)
                completion(false)
            }
        }
    }
}
