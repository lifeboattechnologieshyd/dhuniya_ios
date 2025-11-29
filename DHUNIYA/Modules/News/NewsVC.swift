//
//  NewsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit

class NewsVC: UIViewController {

    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!

    var newsList = [NewsModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getNews()
    }
    
    func getNews() {
        NetworkManager.shared.request(urlString: "https://dev-api.dhuniya.in/news/posts") { (result: Result<APIResponse<[NewsModel]>, NetworkError>)  in
            
            switch result {
            case .success(let response):
                if let data = response.info {
                    self.newsList = data
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
        tblVw.rowHeight = UITableView.automaticDimension
        tblVw.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
    }

    func convertToDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }

    func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, dd MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

extension NewsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let news = newsList[indexPath.row]
        
        cell.newsTitle.text = news.title
        cell.newsTextView.text = news.description
        cell.likeLbl.text = "\(news.likes_count)"
        
        if let date = convertToDate(news.created_date) {
            cell.uploadedTime.text = formatDateTime(date)
        } else {
            cell.uploadedTime.text = news.created_date
        }
        
        if let firstImage = news.image?.first, !firstImage.isEmpty, let imageUrl = URL(string: firstImage) {
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.NewsImg.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.NewsImg.image = UIImage(named: "news_placeholder")
                    }
                }
            }.resume()
        } else {
            cell.NewsImg.image = UIImage(named: "news_placeholder")
        }
        
        // Like button action
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        // Comment button action (closure)
        cell.onCommentButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "News", bundle: nil)
            if let commentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC {
                
                commentsVC.newsId = news.id
                commentsVC.modalPresentationStyle = .overFullScreen
                commentsVC.modalTransitionStyle = .crossDissolve
                self.present(commentsVC, animated: true)
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
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
            urlString: "https://dev-api.dhuniya.in/news/posts/like",
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
            urlString: "https://dev-api.dhuniya.in/news/posts/dislike",
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
        
        NetworkManager.shared.request(urlString: "https://dev-api.dhuniya.in/news/posts/comments",method: .POST,parameters: payload) { (result:Result<APIResponse<CommentResponse>, NetworkError>) in
            
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

