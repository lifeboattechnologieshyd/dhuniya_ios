//
//  NewsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var whatsappLbl: UILabel!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var newsTextView: UITextView!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var uploadedTime: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var NewsImg: UIImageView!
    
    private var likeCount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        whatsappButton.addTarget(self, action: #selector(whatsappTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
    }
    
    @objc private func likeTapped() {
        likeCount += 1
        likeLbl.text = "\(likeCount)"
        
        // Fill the heart
        likeButton.setImage(UIImage(named: "like_filled"), for: .normal)
        likeButton.tintColor = .systemRed
        
        // After 1 second → go back to empty heart
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.likeButton.setImage(UIImage(named: "like_empty"), for: .normal)
            self?.likeButton.tintColor = .lightGray
        }
    }
    
    @objc private func shareTapped() {
        let text = newsTitle.text ?? ""
        
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController {
            
            let shareVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            topVC.present(shareVC, animated: true)
        }
    }
    
    @objc private func whatsappTapped() {
        let message = newsTitle.text ?? ""
        let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "whatsapp://send?text=\(encoded)"
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            if let topVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController {
                
                let alert = UIAlertController(
                    title: "WhatsApp Not Installed",
                    message: "Please install WhatsApp to continue.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                topVC.present(alert, animated: true)
            }
        }
    }
}
