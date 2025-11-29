//
//  NewsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit

class NewsCell: UITableViewCell {
    
    var onCommentButtonTapped: (() -> Void)? 
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var shareVw: UIView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var newsTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var uploadedTime: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var NewsImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        
        // Share button action
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        // Comment button action
        commentButton.addTarget(self, action: #selector(commentTapped), for: .touchUpInside)
    }
    
    @objc func commentTapped() {
        // Call closure defined in the view controller
        onCommentButtonTapped?()
    }
    
    @objc func shareTapped() {
        // Save original visibility states
        let wasShareVwHidden = shareVw.isHidden
        let wasDownloadHidden = downloadButton.isHidden

        // Show shareVw & hide download button for screenshot
        shareVw.isHidden = false
        downloadButton.isHidden = true
        layoutIfNeeded()

        // Capture screenshot
        let screenshot = captureScreenshot()

        // Restore original visibility
        shareVw.isHidden = wasShareVwHidden
        downloadButton.isHidden = wasDownloadHidden

        // Present iOS share sheet
        let activityVC = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController {
            
            topVC.present(activityVC, animated: true)
        }
    }

    func captureScreenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }

    @objc func downloadTapped() {
        guard let image = NewsImg.image else {
            showSimpleAlert(title: "Error", message: "Image not available")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            showSimpleAlert(title: "Error", message: "Unable to save image")
        } else {
            showSimpleAlert(title: "Saved", message: "News image saved to Photos")
        }
    }
    
    func showSimpleAlert(title: String, message: String) {
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topVC.present(alert, animated: true)
        }
    }
    
    func setNewsImage(from urlString: String?) {
        if let urlStr = urlString, !urlStr.isEmpty, let url = URL(string: urlStr) {
            // Load image from URL
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.NewsImg.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.NewsImg.image = UIImage(named: "news_placeholder") // default image
                    }
                }
            }.resume()
        } else {
            // If URL is nil or empty, use default image
            self.NewsImg.image = UIImage(named: "news_placeholder")
        }
    }
}
