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
    var recommendedNewsList = [NewsModel]()
    var currentPage = 1
    var isLoading = false
    var isBannersLoaded = false
    var advertisements = [AdvertisementModel]()
    var tableItems: [Any] = []
    
    var nativeAdsCache: [Int: NativeAd] = [:]
    var loadingAdIndexes: Set<Int> = []
    
    // Pointer to track which banner to show next
    private let bannerPointerKey = "GlobalBannerRotationPointer"
    
    var selectedLanguage: String {
        return Session.shared.api_language
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Add back button if we were pushed from another NewsVC
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            let backButton = UIButton(type: .system)
            backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            backButton.tintColor = .white
            backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backButton)
            
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                backButton.widthAnchor.constraint(equalToConstant: 40),
                backButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        fetchBanners()
        getHeadlines()
        fetchAdvertisements()
        
        // If newsList is empty, getNews will load page 1 into it.
        // If newsList is pre-populated (e.g. from tapping recommended news), getNews will append page 1 to it!
        getNews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("LanguageChanged"), object: nil)
        fetchUserLocation { _ in }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure table view fits exactly above the tab bar if it's visible
        if let tabBar = self.tabBarController?.tabBar, !tabBar.isHidden {
            let tabBarTop = self.view.frame.height - tabBar.frame.height
            if tblVw.frame.height > tabBarTop {
                tblVw.frame.size.height = tabBarTop
            }
        }
    }
    
    @objc private func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchBanners() {
        NetworkManager.shared.request(urlString: API.BANNERS_API) { [weak self] (result: Result<APIResponse<[BannerModel]>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.info {
                    DispatchQueue.main.async {
                        // MACHA: Shuffle total banners once here
                        self?.bannersData = data.shuffled()
                        self?.isBannersLoaded = true
                        self?.prepareTableItems()
                        self?.preloadNativeAds()
                        self?.tblVw.reloadData()
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
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
        if currentPage == 1 { showLoader() }
        
        let urlString = "\(API.GET_NEWS)?offset=\(currentPage)&limit=\(limit)&language=\(selectedLanguage)"
        
        NetworkManager.shared.request(urlString: urlString) { [weak self] (result: Result<APIResponse<[NewsModel]>, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.hideLoader()
                if case .success(let response) = result, let data = response.info {
                    if self.currentPage == 1 { self.newsList = data }
                    else { self.newsList.append(contentsOf: data) }
                    self.prepareTableItems()
                    self.preloadNativeAds()
                    self.tblVw.reloadData()
                }
            }
        }
    }
    func getHeadlines() {
        let urlString = "\(API.BASE_URL)news/headline?language=\(selectedLanguage)"
        NetworkManager.shared.request(urlString: urlString) { [weak self] (result: Result<APIResponse<[NewsModel]>, NetworkError>) in
            DispatchQueue.main.async {
                if case .success(let response) = result, let data = response.info {
                    self?.recommendedNewsList = data
                    self?.tblVw.reloadData()
                }
            }
        }
    }
    func fetchAdvertisements() {
        let urlString = "\(API.ADS_API)?display_type=NEWS&language=\(selectedLanguage)"
        print("🌐 Fetching Ads: \(urlString)")
        NetworkManager.shared.request(urlString: urlString) { [weak self] (result: Result<APIResponse<[AdvertisementModel]>, NetworkError>) in
            if case .success(let response) = result {
                print("📦 Full Ads Response (NEWS): \(response)")
                if let info = response.info, !info.isEmpty {
                    print("✅ Received \(info.count) NEWS ads")
                    DispatchQueue.main.async {
                        self?.advertisements = info
                        self?.prepareTableItems()
                        self?.tblVw.reloadData()
                    }
                } else {
                    print("⚠️ No NEWS ads, trying OTHERS...")
                    self?.fetchFallbackAdvertisements()
                }
            }
        }
    }
    
    func fetchFallbackAdvertisements() {
        let urlString = "\(API.ADS_API)?display_type=OTHERS&language=\(selectedLanguage)"
        NetworkManager.shared.request(urlString: urlString) { [weak self] (result: Result<APIResponse<[AdvertisementModel]>, NetworkError>) in
            if case .success(let response) = result, let data = response.info {
                print("📦 Full Ads Response (OTHERS): \(data.count) ads")
                DispatchQueue.main.async {
                    self?.advertisements = data
                    self?.prepareTableItems()
                    self?.tblVw.reloadData()
                }
            }
        }
    }
    
    func prepareTableItems() {
        tableItems.removeAll()
        var newsIndex = 0
        let totalBannersCount = bannersData.count
        
        // Get the current pointer from storage
        var currentPointer = UserDefaults.standard.integer(forKey: bannerPointerKey)
        
        while newsIndex < newsList.count {
            // Add 3 news items
            var newsAddedInCycle = 0
            while newsAddedInCycle < 3 && newsIndex < newsList.count {
                tableItems.append(newsList[newsIndex])
                newsIndex += 1
                newsAddedInCycle += 1
            }
            
            if newsAddedInCycle > 0 {
                // 1. INSERT BANNER (Shuffled & Infinite Loop)
                if totalBannersCount > 0 {
                    var group: [BannerModel] = []
                    for _ in 0..<3 {
                        group.append(bannersData[currentPointer % totalBannersCount])
                        currentPointer += 1
                    }
                    tableItems.append(group)
                }
                
                // 2. INSERT NATIVE AD
                let adIdentifier = "NATIVE_AD_\(tableItems.count)"
                tableItems.append(adIdentifier)
            }
        }
        
        // Save pointer for next refresh or next app launch
        UserDefaults.standard.set(currentPointer, forKey: bannerPointerKey)
        
        // 3. INSERT CUSTOM ADVERTISEMENTS at their specified positions
        for ad in advertisements {
            if let pos = ad.position, pos >= 0 && pos <= tableItems.count {
                tableItems.insert(ad, at: pos)
            }
        }
    }
    
    func preloadNativeAds(near index: Int = 0) {
        let range = index...(index + 5)
        for (i, item) in tableItems.enumerated() {
            if range.contains(i), let adId = item as? String, adId.hasPrefix("NATIVE_AD") {
                if nativeAdsCache[i] == nil && !loadingAdIndexes.contains(i) {
                    loadNativeAd(for: i)
                }
            }
        }
    }
    
    func loadNativeAd(for index: Int) {
        guard nativeAdsCache[index] == nil, !loadingAdIndexes.contains(index) else { return }
        loadingAdIndexes.insert(index)
        NativeAdManager.shared.loadNativeAd(from: self) { [weak self] nativeAd in
            guard let self = self else { return }
            self.loadingAdIndexes.remove(index)
            if let ad = nativeAd {
                self.nativeAdsCache[index] = ad
                DispatchQueue.main.async {
                    if index < self.tableItems.count {
                        self.tblVw.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
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
        if #available(iOS 11.0, *) { tblVw.contentInsetAdjustmentBehavior = .never }
        tblVw.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tblVw.register(FullScreenNativeAdCell.self, forCellReuseIdentifier: FullScreenNativeAdCell.identifier)
        tblVw.register(FullScreenBannerCell.self, forCellReuseIdentifier: FullScreenBannerCell.identifier)
        tblVw.register(AdvertisementCell.self, forCellReuseIdentifier: AdvertisementCell.identifier)
    }
    
    func getRecommendedNews(forAdIndex adIndex: Int) -> [NewsModel] {
        guard !recommendedNewsList.isEmpty else { return [] }
        let startIndex = (adIndex * 3) % recommendedNewsList.count
        var result: [NewsModel] = []
        for i in 0..<3 {
            let index = (startIndex + i) % recommendedNewsList.count
            result.append(recommendedNewsList[index])
        }
        return result
    }
    
    func getAdIndex(for tableIndex: Int) -> Int {
        var adCount = 0
        for i in 0..<tableIndex {
            if i < tableItems.count, let id = tableItems[i] as? String, id.hasPrefix("NATIVE_AD") {
                adCount += 1
            }
        }
        return adCount
    }
    
    func getNewsIndex(for tableIndex: Int) -> Int {
        var newsCount = 0
        for i in 0..<tableIndex {
            if i < tableItems.count, tableItems[i] is NewsModel { newsCount += 1 }
        }
        return newsCount
    }

    func convertToDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }

    func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = Calendar.current.isDateInToday(date) ? "h:mm a" : "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    func fetchUserLocation(completion: @escaping (Result<LocationResponse, NetworkError>) -> Void) {
        NetworkManager.shared.requestRaw(urlString: API.USER_LOCATION) { (result: Result<LocationResponse, NetworkError>) in
            if case .success(let loc) = result { Session.shared.userLocation = loc }
        }
    }
    
    @objc private func languageChanged() {
        currentPage = 1
        newsList.removeAll()
        recommendedNewsList.removeAll()
        bannersData.shuffle()
        getNews()
        getHeadlines()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - TableView Extensions
extension NewsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableItems[indexPath.row]
        
        if let adId = item as? String, adId.hasPrefix("NATIVE_AD") {
            let cell = tableView.dequeueReusableCell(withIdentifier: FullScreenNativeAdCell.identifier, for: indexPath) as! FullScreenNativeAdCell
            
            let adIndex = getAdIndex(for: indexPath.row)
            let recommended = getRecommendedNews(forAdIndex: adIndex)
            
            if let nativeAd = nativeAdsCache[indexPath.row] {
                cell.configure(nativeAd: nativeAd, relatedNews: recommended)
                
                cell.onNewsClick = { [weak self] (index, news) in
                    guard let self = self else { return }
                    
                    // First, check if the tapped news is ALREADY in the current tableItems
                    if let existingIndex = self.tableItems.firstIndex(where: { ($0 as? NewsModel)?.id == news.id }) {
                        self.tblVw.scrollToRow(at: IndexPath(row: existingIndex, section: 0), at: .top, animated: true)
                        return
                    }
                    
                    // If it's not in the loaded items yet, insert it right after this Ad cell
                    let newsInsertIndex = self.getNewsIndex(for: indexPath.row)
                    
                    if self.newsList.count >= newsInsertIndex {
                        self.newsList.insert(news, at: newsInsertIndex)
                    } else {
                        self.newsList.append(news)
                    }
                    
                    // Rebuild tableItems to ensure the exact pattern (3 news -> banner -> ad)
                    self.prepareTableItems()
                    self.tblVw.reloadData()
                    
                    // Scroll to the newly inserted news item, which will be exactly at indexPath.row + 1
                    self.tblVw.scrollToRow(at: IndexPath(row: indexPath.row + 1, section: 0), at: .top, animated: true)
                }
                
            } else {
                cell.showLoading()
                loadNativeAd(for: indexPath.row)
            }
            return cell
        }
        
        if let banners = item as? [BannerModel] {
            let cell = tableView.dequeueReusableCell(withIdentifier: FullScreenBannerCell.identifier, for: indexPath) as! FullScreenBannerCell
            cell.configure(with: banners)
            return cell
        }
        
        if let ad = item as? AdvertisementModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: AdvertisementCell.identifier, for: indexPath) as! AdvertisementCell
            cell.configure(with: ad)
            cell.onKnowMore = { [weak self] in
                if let urlString = ad.destination_url, let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            }
            cell.onWhatsapp = {
                if let number = ad.whatsapp_number {
                    let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(number)")!
                    if UIApplication.shared.canOpenURL(whatsappURL) {
                        UIApplication.shared.open(whatsappURL)
                    }
                }
            }
            cell.onCall = {
                if let number = ad.mobile_number {
                    if let url = URL(string: "tel://\(number)") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            return cell
        }
        
        guard let news = item as? NewsModel else { return UITableViewCell() }
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
        }
        
        if let date = convertToDate(news.created_date) { cell.uploadedTime.text = formatDateTime(date) }
        
        cell.setNewsImage(from: news)
        cell.likeButton.tag = newsIndex
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let adId = tableItems[indexPath.row] as? String, adId.hasPrefix("NATIVE_AD"), nativeAdsCache[indexPath.row] == nil {
            loadNativeAd(for: indexPath.row)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        // Trigger preloading for nearby ads
        let visibleIndex = Int(offsetY / max(1, scrollView.frame.height))
        preloadNativeAds(near: visibleIndex)
        
        if offsetY > contentHeight - scrollView.frame.size.height - 200 {
            loadNextPage()
        }
    }
    
    func loadNextPage() {
        guard !isLoading else { return }
        currentPage += 1
        getNews()
    }
}

// MARK: - Actions Extension
extension NewsVC {
    @objc private func likeButtonTapped(_ sender: UIButton) {
        let newsIndex = sender.tag
        guard newsIndex < newsList.count else { return }
        let news = newsList[newsIndex]
        let isLiked = news.is_liked ?? false
        let apiUrl = isLiked ? API.NEWS_DISLIKE : API.NEWS_LIKE
        
        NetworkManager.shared.request(urlString: apiUrl, method: .POST, parameters: ["news_id": news.id]) { [weak self] (result: Result<APIResponse<LikeInfo>, NetworkError>) in
            DispatchQueue.main.async {
                if case .success = result {
                    self?.newsList[newsIndex].likes_count += isLiked ? -1 : 1
                    self?.newsList[newsIndex].is_liked = !isLiked
                    self?.prepareTableItems()
                    self?.tblVw.reloadData()
                }
            }
        }
    }
}

// MARK: - FullScreenBannerCell Definition
class FullScreenBannerCell: UITableViewCell {
    
    static let identifier = "FullScreenBannerCell"
    
    private var banners: [BannerModel] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .black
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 0
        pc.currentPage = 0
        pc.pageIndicatorTintColor = .darkGray
        pc.currentPageIndicatorTintColor = .white
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Dhuniya")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "share_banner"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let whatsappButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "whatsappshare"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        
        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        contentView.addSubview(logoImageView)
        contentView.addSubview(whatsappButton)
        contentView.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            pageControl.bottomAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -16),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            logoImageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            logoImageView.widthAnchor.constraint(equalToConstant: 70),
            
            whatsappButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            whatsappButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            whatsappButton.heightAnchor.constraint(equalToConstant: 24),
            whatsappButton.widthAnchor.constraint(equalToConstant: 24),
            
            shareButton.centerYAnchor.constraint(equalTo: whatsappButton.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: whatsappButton.leadingAnchor, constant: -12),
            shareButton.heightAnchor.constraint(equalToConstant: 24),
            shareButton.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BannerSlideCell.self, forCellWithReuseIdentifier: BannerSlideCell.identifier)
        
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        whatsappButton.addTarget(self, action: #selector(whatsappButtonTapped), for: .touchUpInside)
    }
    
    func configure(with banners: [BannerModel]) {
        self.banners = banners
        pageControl.numberOfPages = banners.count
        pageControl.currentPage = 0
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    @objc private func shareButtonTapped() {
        let index = pageControl.currentPage
        guard index < banners.count else { return }
        let banner = banners[index]
        if let images = banner.images, let firstImage = images.compactMap({ $0 }).first, let url = URL(string: firstImage) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                if case .success(let value) = result { self?.shareImage(image: value.image) }
            }
        }
    }
    
    @objc private func whatsappButtonTapped() {
        let index = pageControl.currentPage
        guard index < banners.count else { return }
        let banner = banners[index]
        if let images = banner.images, let firstImage = images.compactMap({ $0 }).first, let url = URL(string: firstImage) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                if case .success(let value) = result { self?.shareToWhatsApp(image: value.image) }
            }
        }
    }
    
    private func shareImage(image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
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
            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                dic.presentOpenInMenu(from: topVC.view.bounds, in: topVC.view, animated: true)
            }
        } catch { print(error) }
    }
}

extension FullScreenBannerCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerSlideCell.identifier, for: indexPath) as! BannerSlideCell
        cell.configure(with: banners[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = page
    }
}

// MARK: - BannerSlideCell
class BannerSlideCell: UICollectionViewCell {
    static let identifier = "BannerSlideCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with banner: BannerModel) {
        if let images = banner.images, let firstImage = images.compactMap({ $0 }).first {
            imageView.kf.setImage(with: URL(string: firstImage), placeholder: UIImage(named: "placeholder"))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
