//
//  FeelPlayerController.swift
//  SchoolFirst
//
//  Created by Ranjith Padidala on 18/10/25.
//

import UIKit
import YouTubeiOSPlayerHelper

class FeelPlayerController: UIViewController {

    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var shareLbl: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selected_feel_item: FeelItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        setupUI()
        loadFeelData()
        playYouTubeVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure buttons and labels are always on top
        bringControlsToFront()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Extra safety to bring controls to front
        bringControlsToFront()
    }
    
    private func setupUI() {
        // Add shadow to top view
        topView.addBottomShadow()
        
        // Make sure all controls are visible
        btnLike?.isHidden = false
        btnShare?.isHidden = false
        likeLbl?.isHidden = false
        shareLbl?.isHidden = false
        lblTitle?.isHidden = false
        
        btnLike?.alpha = 1.0
        btnShare?.alpha = 1.0
        likeLbl?.alpha = 1.0
        shareLbl?.alpha = 1.0
        
        // Style buttons
        styleButtons()
        
        // Setup player view
        playerView.backgroundColor = .black
        playerView.delegate = self
    }
    
    private func styleButtons() {
        // Like button styling
        updateLikeButtonAppearance()
        
        // Share button styling
        btnShare?.tintColor = .systemBlue
        
        // Labels styling
        likeLbl?.textColor = .label
        likeLbl?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        shareLbl?.textColor = .label
        shareLbl?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    private func bringControlsToFront() {
        // Bring all interactive elements to front
        view.bringSubviewToFront(topView)
        view.bringSubviewToFront(btnLike)
        view.bringSubviewToFront(btnShare)
        view.bringSubviewToFront(likeLbl)
        view.bringSubviewToFront(shareLbl)
        view.bringSubviewToFront(lblTitle)
        view.bringSubviewToFront(activityIndicator)
    }
    
    private func loadFeelData() {
        guard let feel = selected_feel_item else { return }
        
        lblTitle.text = feel.title
        likeLbl.text = "\(feel.totalLikes ?? 0)"
        shareLbl.text = "\(feel.shareCount ?? 0)"
        
        updateLikeButtonAppearance()
    }
    
    private func updateLikeButtonAppearance() {
        let isLiked = selected_feel_item?.isLiked ?? false
        
        if isLiked {
            btnLike?.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            btnLike?.tintColor = .systemRed
        } else {
            btnLike?.setImage(UIImage(systemName: "heart"), for: .normal)
            btnLike?.tintColor = .systemGray
        }
    }
    
    func playYouTubeVideo() {
        guard let videoURL = selected_feel_item.youtubeVideo,
              let videoID = videoURL.extractYoutubeId() else {
            print("Invalid YouTube URL")
            showFeelsAlert("Invalid video URL")
            return
        }
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        playerView.load(withVideoId: videoID, playerVars: [
            "playsinline": 1,
            "autoplay": 1,
            "mute": 0,
            "controls": 1,
            "modestbranding": 1,
            "rel": 0,
            "showinfo": 0
        ])
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        playerView.stopVideo()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickLike(_ sender: UIButton) {
        guard let feel = selected_feel_item else { return }
        
        let isCurrentlyLiked = feel.isLiked ?? false
        let currentLikes = Int(likeLbl.text ?? "0") ?? 0
        
        // Optimistic UI update
        if isCurrentlyLiked {
            // Unlike
            likeLbl.text = "\(max(currentLikes - 1, 0))"
            selected_feel_item.isLiked = false
        } else {
            // Like
            likeLbl.text = "\(currentLikes + 1)"
            selected_feel_item.isLiked = true
        }
        
        updateLikeButtonAppearance()
        
        // API call
        toggleLikeFeel(feel: feel, isCurrentlyLiked: isCurrentlyLiked) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                // Update the actual count from server if needed
                if isCurrentlyLiked {
                    self.selected_feel_item.totalLikes = max((self.selected_feel_item.totalLikes ?? 1) - 1, 0)
                } else {
                    self.selected_feel_item.totalLikes = (self.selected_feel_item.totalLikes ?? 0) + 1
                }
            } else {
                // Revert on failure
                self.selected_feel_item.isLiked = isCurrentlyLiked
                self.likeLbl.text = "\(currentLikes)"
                self.updateLikeButtonAppearance()
            }
        }
    }
    
    @IBAction func onClickShare(_ sender: UIButton) {
        guard let feel = selected_feel_item else { return }
        openShareSheet(for: feel)
    }
    
    func toggleLikeFeel(feel: FeelItem, isCurrentlyLiked: Bool, completion: ((Bool) -> Void)? = nil) {
        let endpoint = isCurrentlyLiked ? "unlike/feel" : "like/feel"
        let urlString = "\(API.BASE_URL)ott_service/\(endpoint)"
        let params = ["feel_id": feel.id]
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<EmptyInfo>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print(" \(isCurrentlyLiked ? "Unliked" : "Liked") successfully")
                        completion?(true)
                    } else {
                        self.showFeelsAlert(response.description.isEmpty ? "Operation failed" : response.description)
                        completion?(false)
                    }
                    
                case .failure(let error):
                    self.showFeelsAlert(error.localizedDescription)
                    completion?(false)
                }
            }
        }
    }
    
    func shareFeel(feelId: String) {
        let urlString = "\(API.BASE_URL)ott_service/share/feel"
        let params = ["feel_id": feelId]
        
        NetworkManager.shared.request(
            urlString: urlString,
            method: .POST,
            parameters: params
        ) { [weak self] (result: Result<APIResponse<EmptyInfo>, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        print(" Shared successfully")
                    } else {
                        print(" Share tracking failed: \(response.description)")
                    }
                    
                case .failure(let error):
                    print(" Share error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func openShareSheet(for feel: FeelItem) {
        var shareItems: [Any] = []
        
        // Add title
        if !feel.title.isEmpty {
            shareItems.append(feel.title)
        }
        
        // Add YouTube URL
        if let youtube = feel.youtubeVideo {
            shareItems.append(youtube)
        }
        
        guard !shareItems.isEmpty else {
            showFeelsAlert("Nothing to share")
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        
        activityVC.completionWithItemsHandler = { [weak self] activityType, completed, _, error in
            guard let self = self else { return }
            
            if completed {
                // Increment share count
                self.incrementShareCount()
                
                // Call API to track share
                self.shareFeel(feelId: feel.id)
            }
            
            if let error = error {
                print("Share error: \(error.localizedDescription)")
            }
        }
        
        // iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = btnShare
            popover.sourceRect = btnShare.bounds
            popover.permittedArrowDirections = .any
        }
        
        self.present(activityVC, animated: true)
    }
    
    private func incrementShareCount() {
        let currentShares = Int(shareLbl.text ?? "0") ?? 0
        shareLbl.text = "\(currentShares + 1)"
        selected_feel_item.shareCount = currentShares + 1
    }
    
    func showFeelsAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Oops",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    deinit {
        playerView?.stopVideo()
        print("🗑️ FeelPlayerController deinitialized")
    }
}

extension FeelPlayerController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("YouTube player ready")
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        playerView.playVideo()
        
        // Ensure controls are on top after player loads
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.bringControlsToFront()
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .unstarted:
            print("📹 Player unstarted")
        case .ended:
            print("📹 Video ended")
        case .playing:
            print("▶️ Video playing")
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        case .paused:
            print("⏸️ Video paused")
        case .buffering:
            print("⏳ Video buffering")
        case .cued:  // ✅ CORRECT: Keep it as 'cued'
            print("📹 Video cued")
        case .unknown:
            print("❓ Unknown state")
        @unknown default:
            print("❓ Unknown player state")
        }
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
        var errorMessage = "Failed to load video"
        
        switch error {
        case .invalidParam:
            errorMessage = "Invalid video parameter"
        case .html5Error:  // ✅ Lowercase 'html5Error'
            errorMessage = "HTML5 player error"
        case .videoNotFound:
            errorMessage = "Video not found or unavailable"
        case .notEmbeddable:
            errorMessage = "Video cannot be embedded"
        case .unknown:
            errorMessage = "Unknown player error"
        @unknown default:
            errorMessage = "Player error occurred"
        }
        
        print("❌ YouTube Player Error: \(errorMessage)")
        showFeelsAlert(errorMessage)
    }
}
