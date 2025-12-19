//
//  CommentsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 29/11/25.
//
import UIKit

class CommentsVC: UIViewController {
    
    @IBOutlet weak var bgVw: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userimage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var txtFieldComment: UITextField!
    var newsId: Int = 0                    // News ID to fetch comments
    var commentsList: [CommentModel] = []  // Store API comments
    var onCommentAdded: (() -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.isOpaque = false
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        fetchComments()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bgVw.layer.cornerRadius = 30
        bgVw.layer.maskedCorners = [
            .layerMinXMinYCorner,  // top-left
            .layerMaxXMinYCorner   // top-right
        ]
        bgVw.layer.masksToBounds = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(UINib(nibName: "CommentsCell", bundle: nil),
                           forCellReuseIdentifier: "CommentsCell")
    }
    
    private func fetchComments() {
        NetworkManager.shared.request(
            urlString: API.NEWS_COMMENTS + "?news_id=\(newsId)",
            method: .GET
        ) { (result: Result<APIResponse<[CommentModel]>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success {
                    self.commentsList = response.info?.reversed() ?? []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("Comments API Error:", error)
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func postComment() {
        
        let payload : [String: Any] =
        [
            "news_id": newsId,
            "comment": self.txtFieldComment.text  ?? ""
        ]
        NetworkManager.shared.request(
            urlString: API.NEWS_COMMENTS,
            method: .POST,
            parameters: payload
        ) { (result: Result<APIResponse<CommentModel>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success {
                    
                    if let comment = response.info {
                        self.commentsList.append(comment)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.onCommentAdded?()
                        self.txtFieldComment.text = ""
                        self.dismiss(animated: true)
                    }
                }
     case .failure(let error):
                print("Comments API Error:", error)
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    
    @IBAction func onClickSend(_ sender: UIButton) {
        if txtFieldComment.hasText {
            self.postComment()
        }else{
            self.showAlert(message: "Comment cannot be empty")
        }
    }
    
    
    @objc func closeTapped() {
        self.dismiss(animated: true)
    }
}

extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsList.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell",
                                                 for: indexPath) as! CommentsCell
        let comment = commentsList[indexPath.row]
        
        // Fill your cell UI
        cell.commentLabel.text = comment.comment
        cell.usernameLbl.text = comment.username ?? "Guest"
        
        // Show created date or fallback
        let dateString = comment.updation_date ?? comment.created_date
        cell.createddateLbl.text = formatDate(dateString)
        
        // Load profile image if available
        if let urlStr = comment.profile_image, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.userpicture.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.userpicture.image = UIImage(named: "user_placeholder")
                    }
                }
            }.resume()
        } else {
            cell.userpicture.image = UIImage(named: "user_placeholder")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func formatDate(_ isoString: String) -> String {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: isoString) else {
            return isoString
        }
        
        let now = Date()
        let secondsIn24Hours: TimeInterval = 24 * 60 * 60
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if now.timeIntervalSince(date) < secondsIn24Hours {
            // Less than 24 hours → show time
            displayFormatter.dateFormat = "h:mm a"
        } else {
            // More than 24 hours → show date
            displayFormatter.dateFormat = "dd MMM yyyy"
        }
        
        return displayFormatter.string(from: date)
    }
    
}
