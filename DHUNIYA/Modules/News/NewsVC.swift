//
//  NewsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit

class NewsVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    var newsList = [NewsModel]()
    var currentPage = 1
    var totalPages = 10
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Allow extending under navigation bar only
        self.edgesForExtendedLayout = [.top]
        
        // Optional but safe
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
        let urlString = "\(API.GET_NEWS)?offset=\(currentPage)&limit=\(limit)"
        
        NetworkManager.shared.request(urlString: urlString) { (result: Result<APIResponse<[NewsModel]>, NetworkError>) in
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if let data = response.info {
                    if self.currentPage == 1 {
                        self.newsList = data
                    } else {
                        self.newsList.append(contentsOf: data)
                    }
                    
                    DispatchQueue.main.async {
                        self.tblVw.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        
        // let auto layout decide the height
        tblVw.rowHeight = UITableView.automaticDimension
        //        tblVw.estimatedRowHeight = 600
        
        tblVw.separatorStyle = .none
        
        // if you have nav/tab bar, this is safe but optional
        if #available(iOS 11.0, *) {
            tblVw.contentInsetAdjustmentBehavior = .never
        }
        
        tblVw.register(UINib(nibName: "NewsCell", bundle: nil),
                       forCellReuseIdentifier: "NewsCell")
    }
    
    func formatDateTime(_ date: Date) -> String {
        let now = Date()
        let secondsIn24Hours: TimeInterval = 24 * 60 * 60
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if now.timeIntervalSince(date) < secondsIn24Hours {
            // Within 24 hours → show only time
            formatter.dateFormat = "h:mm a"
        } else {
            // After 24 hours → show date
            formatter.dateFormat = "dd MMM yyyy"
        }
        
        return formatter.string(from: date)
    }
    
    func convertToDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
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

extension NewsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let news = newsList[indexPath.row]
        
        // Set text FIRST
        cell.newsTitle.text = news.title
        cell.newsTextView.text = news.description
        cell.likeLbl.text = "\(news.likes_count)"
        cell.commentLbl.text = "\(news.comments_count)"
        
        cell.updateLikeUI(isLiked: news.is_liked == true)
        
        // Apply font based on language
        if news.language.uppercased() == "TELUGU" {
            cell.newsTextView.setupLineSpacing(lineSpace: 8, font: CustomFonts.LR16.font)
            cell.newsTitle.setupLineSpacing(lineSpace: 10, font: CustomFonts.LSB18.font)
        } else {
            cell.newsTitle.font = FontManager.englishTitle(16)
            cell.newsTextView.font = FontManager.englishBody(14)
        }
        // Date
        if let date = convertToDate(news.created_date) {
            cell.uploadedTime.text = formatDateTime(date)
        } else {
            cell.uploadedTime.text = news.created_date
        }
        
        // Image
        cell.NewsImg.setKFImage(news.image?.first)
        
        // Like button
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        // Comment action
        cell.onCommentButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "News", bundle: nil)
            if let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC {
                
                commentsVC.newsId = news.id
                
                // 🔥 THIS IS THE MISSING LINK
                commentsVC.onCommentAdded = {
                    self.newsList[indexPath.row].comments_count += 1
                    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 { // Near bottom
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
    
    // Toggle like/dislike based on current status
    @objc private func likeButtonTapped(_ sender: UIButton) {
        let news = newsList[sender.tag]
        
        if news.is_liked == true {
            sendDislikeRequest(newsId: news.id) { success in
                DispatchQueue.main.async {
                    if success {
                        self.newsList[sender.tag].likes_count -= 1
                        self.newsList[sender.tag].is_liked = false
                        self.tblVw.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
                    }
                }
            }
        } else {
            sendLikeRequest(newsId: news.id) { success in
                DispatchQueue.main.async {
                    if success {
                        self.newsList[sender.tag].likes_count += 1
                        self.newsList[sender.tag].is_liked = true
                        self.tblVw.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
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
        
        NetworkManager.shared.request(urlString: API.NEWS_COMMENTS, method: .POST, parameters: payload) { (result: Result<APIResponse<CommentResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success {
                    completion(true)
                } else {
                    print("Comment API error:", response.description)
                    completion(false)
                }
            case .failure(let error):
                print("Comment API failed:", error)
                completion(false)
            }
        }
    }
}
