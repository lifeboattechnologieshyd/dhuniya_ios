//
//  NewsVC.swift
//  DHUNIYA
//

import UIKit
import GoogleMobileAds
import Kingfisher

class NewsVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    var newsList = [NewsModel]()
    var bannersData = [BannerModel]()
    var currentPage = 1
    var totalPages = 10
    var isLoading = false
    var isBannersLoaded = false
    var tableItems: [Any] = []
    
    var nativeAdsCache: [Int: NativeAd] = [:]
    var loadingAdIndexes: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = [.top]
        self.extendedLayoutIncludesOpaqueBars = false
        setupTableView()
        fetchBanners()
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
    
    func fetchBanners() {
        NetworkManager.shared.request(urlString: API.BANNERS_API) { [weak self] (result: Result<APIResponse<[BannerModel]>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.info {
                    DispatchQueue.main.async {
                        self?.bannersData = data
                        self?.isBannersLoaded = true
                        self?.prepareTableItems()
                        self?.preloadNativeAds()
                        self?.tblVw.reloadData()
                    }
                }
            case .failure(let error):
                print("Error fetching banners: \(error)")
                DispatchQueue.main.async {
                    self?.isBannersLoaded = true
                    self?.prepareTableItems()
                    self?.preloadNativeAds()
                    self?.tblVw.reloadData()
                }
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
        
        var newsIndex = 0
        var bannerIndex = 0
        let totalBanners = bannersData.count
        
        while newsIndex < newsList.count {
            if bannerIndex < totalBanners {
                var newsAddedInCycle = 0
                while newsAddedInCycle < 3 && newsIndex < newsList.count {
                    tableItems.append(newsList[newsIndex])
                    newsIndex += 1
                    newsAddedInCycle += 1
                }
                
                if newsAddedInCycle > 0 && bannerIndex < totalBanners {
                    tableItems.append(bannersData[bannerIndex])
                    bannerIndex += 1
                    
                    let adIdentifier = "NATIVE_AD_\(tableItems.count)"
                    tableItems.append(adIdentifier)
                }
            } else {
                var newsAddedInCycle = 0
                while newsAddedInCycle < 4 && newsIndex < newsList.count {
                    tableItems.append(newsList[newsIndex])
                    newsIndex += 1
                    newsAddedInCycle += 1
                }
                
                if newsAddedInCycle == 4 {
                    let adIdentifier = "NATIVE_AD_\(tableItems.count)"
                    tableItems.append(adIdentifier)
                }
            }
        }
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
        
        NativeAdManager.shared.loadNativeAd(from: self) { [weak self] nativeAd in
            guard let self = self else { return }
            
            self.loadingAdIndexes.remove(index)
            
            guard let ad = nativeAd else {
                return
            }
            
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
        tblVw.register(FullScreenBannerCell.self, forCellReuseIdentifier: FullScreenBannerCell.identifier)
    }
    
    func getRecommendedNews(afterAdAt tableIndex: Int) -> [NewsModel] {
        var recommended: [NewsModel] = []
        
        for i in (tableIndex + 1)..<tableItems.count {
            if let news = tableItems[i] as? NewsModel {
                recommended.append(news)
                if recommended.count >= 3 { break }
            }
        }
        
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
        NetworkManager.shared.requestRaw(
            urlString: API.USER_LOCATION
        ) { (result: Result<LocationResponse, NetworkError>) in
            switch result {
            case .success(let location):
                Session.shared.userLocation = location
                completion(.success(location))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension NewsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = tableItems[indexPath.row]
        
        if let adIdentifier = item as? String, adIdentifier.hasPrefix("NATIVE_AD") {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FullScreenNativeAdCell.identifier,
                for: indexPath
            ) as! FullScreenNativeAdCell
            
            let recommendedNews = getRecommendedNews(afterAdAt: indexPath.row)
            
            if let nativeAd = nativeAdsCache[indexPath.row] {
                cell.configure(nativeAd: nativeAd, relatedNews: recommendedNews)
            } else {
                cell.showLoading()
                loadNativeAd(for: indexPath.row)
            }
            
            cell.onNewsClick = { [weak self] index, news in
                guard let self = self else { return }
                if let newsIndex = self.tableItems.firstIndex(where: { ($0 as? NewsModel)?.id == news.id }) {
                    let targetIndexPath = IndexPath(row: newsIndex, section: 0)
                    self.tblVw.scrollToRow(at: targetIndexPath, at: .top, animated: true)
                }
            }
            
            return cell
        }
        
        if let banner = item as? BannerModel {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FullScreenBannerCell.identifier,
                for: indexPath
            ) as! FullScreenBannerCell
            cell.configure(with: banner)
            return cell
        }
        
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

class FullScreenBannerCell: UITableViewCell {
    
    static let identifier = "FullScreenBannerCell"
    
    private let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Dhuniya")
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "share_banner"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let whatsappButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "whatsappshare"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var currentImageUrl: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .black
        contentView.backgroundColor = .black
        
        contentView.addSubview(bannerImageView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(whatsappButton)
        contentView.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            logoImageView.widthAnchor.constraint(equalToConstant: 70),
            
            whatsappButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            whatsappButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            whatsappButton.heightAnchor.constraint(equalToConstant: 24),
            whatsappButton.widthAnchor.constraint(equalToConstant: 24),
            
            shareButton.centerYAnchor.constraint(equalTo: whatsappButton.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: whatsappButton.leadingAnchor, constant: -12),
            shareButton.heightAnchor.constraint(equalToConstant: 24),
            shareButton.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        whatsappButton.addTarget(self, action: #selector(whatsappButtonTapped), for: .touchUpInside)
    }
    
    func configure(with banner: BannerModel) {
        guard let images = banner.images else { return }
        for image in images {
            if let imageUrl = image {
                currentImageUrl = imageUrl
                bannerImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "placeholder"))
                break
            }
        }
    }
    
    @objc private func shareButtonTapped() {
        guard let imageUrl = currentImageUrl, let url = URL(string: imageUrl) else { return }
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let value):
                self?.shareImage(image: value.image)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    @objc private func whatsappButtonTapped() {
        guard let imageUrl = currentImageUrl, let url = URL(string: imageUrl) else { return }
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let value):
                self?.shareToWhatsApp(image: value.image)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func shareImage(image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController {
            topVC.present(activityVC, animated: true)
        }
    }
    
    private func shareToWhatsApp(image: UIImage) {
        guard let imageData = image.pngData() else { return }
        let tempFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("share.png")
        do {
            try imageData.write(to: tempFile)
            let dic = UIDocumentInteractionController(url: tempFile)
            dic.uti = "net.whatsapp.image"
            if let topVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController {
                dic.presentOpenInMenu(from: topVC.view.bounds, in: topVC.view, animated: true)
            }
        } catch {
            print("Error sharing to WhatsApp: \(error)")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bannerImageView.image = nil
        currentImageUrl = nil
    }
}
