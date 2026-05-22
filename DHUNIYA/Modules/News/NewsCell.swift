//
//  NewsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit
import YouTubeiOSPlayerHelper
import Kingfisher

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
    
    private var ytPlayerView: YTPlayerView?
    private var currentVideoID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
         
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        
        // Share button action
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        // Comment button action
        commentButton.addTarget(self, action: #selector(commentTapped), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanupPlayer()
        NewsImg.isHidden = false
        NewsImg.image = nil
    }
    
    private func cleanupPlayer() {
        ytPlayerView?.stopVideo()
        ytPlayerView?.removeFromSuperview()
        ytPlayerView = nil
        currentVideoID = nil
    }
    func updateLikeUI(isLiked: Bool) {
        if isLiked {
            likeButton.setImage(UIImage(named: "red"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "black"), for: .normal)
        }
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
    
    func setNewsImage(from model: NewsModel) {
        cleanupPlayer()
        
        // Check for YouTube URL first
        if let youtubeUrls = model.youtube_url, let firstUrl = youtubeUrls.first, !firstUrl.isEmpty {
            if let videoID = extractYouTubeID(from: firstUrl) {
                setupYouTubePlayer(videoID: videoID)
                return
            }
        }
        
        // Fallback to image
        NewsImg.isHidden = false
        if let images = model.image, let firstImage = images.first, let url = URL(string: firstImage) {
            NewsImg.kf.setImage(with: url, placeholder: UIImage(named: "news_placeholder"))
        } else {
            NewsImg.image = UIImage(named: "news_placeholder")
        }
    }
    
    private func setupYouTubePlayer(videoID: String) {
        currentVideoID = videoID
        
        let player = YTPlayerView()
        player.backgroundColor = .black
        player.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(player)
        
        NSLayoutConstraint.activate([
            player.topAnchor.constraint(equalTo: NewsImg.topAnchor),
            player.leadingAnchor.constraint(equalTo: NewsImg.leadingAnchor),
            player.trailingAnchor.constraint(equalTo: NewsImg.trailingAnchor),
            player.bottomAnchor.constraint(equalTo: NewsImg.bottomAnchor)
        ])
        
        ytPlayerView = player
        NewsImg.isHidden = true // Hide image when video is present
        
        player.load(withVideoId: videoID, playerVars: [
            "playsinline": 1,
            "rel": 0,
            "modestbranding": 1,
            "controls": 1
        ])
    }
    
    private func extractYouTubeID(from url: String) -> String? {
        if url.contains("youtu.be/") {
            return url.components(separatedBy: "youtu.be/").last?.components(separatedBy: "?").first
        }
        if url.contains("youtube.com/watch") {
            return URLComponents(string: url)?
                .queryItems?
                .first(where: { $0.name == "v" })?.value
        }
        if url.contains("youtube.com/embed/") {
            return url.components(separatedBy: "youtube.com/embed/").last?.components(separatedBy: "?").first
        }
        return nil
    }
}
