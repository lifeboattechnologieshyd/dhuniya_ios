//
//  PlayerVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 17/12/25.
//

import UIKit
import AVKit
import Kingfisher
import YouTubeiOSPlayerHelper
import Photos

class PlayerVC: UIViewController, YTPlayerViewDelegate {

    var selectedItem: MediaItem?
    var movieDetailsItem: MovieResponseItem?
    var videoURL: String?

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var downloaBtn: UIButton!
    @IBOutlet weak var imgCoverPic: UIImageView!
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblMovieDetails: UILabel!
    @IBOutlet weak var btnWatchNow: UIButton!
    @IBOutlet weak var tblVw: UITableView!

    private var ytPlayerView: YTPlayerView?
    private var player: AVPlayer?
    private var playerController: AVPlayerViewController?
    private var playerItem: AVPlayerItem?
    
    // Download properties
    private var downloadTask: URLSessionDownloadTask?
    private var progressAlert: UIAlertController?
    private var progressView: UIProgressView?

    override func viewDidLoad() {
        super.viewDidLoad()

      //  btnWatchNow.addTarget(self, action: #selector(watchNowButtonTapped(_:)), for: .touchUpInside)

        configureUI()
        fetchMovieDetails()
        setupTableView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanup()
    }

    deinit {
        cleanup()
        downloadTask?.cancel()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        cleanup()
        downloadTask?.cancel()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        downloadVideo()
    }

    @IBAction func watchNowButtonTapped(_ sender: Any) {

        guard let movie = movieDetailsItem else {
            showAlert(title: "Error", message: "Movie details not loaded")
            return
        }

        let videoURL = movie.movie_data?.converted_url ?? movie.movie_data?.video_url

        guard let finalURL = videoURL, !finalURL.isEmpty else {
            showAlert(title: "Error", message: "Video URL not available")
            return
        }

        if finalURL.contains("youtu.be") || finalURL.contains("youtube.com") {
            playYouTubeVideo(youtubeURL: finalURL)
        } else {
            playWithAVPlayer(urlString: finalURL)
        }
    }

    private func playYouTubeVideo(youtubeURL: String) {

        cleanup()

        guard let videoID = extractYouTubeID(from: youtubeURL) else {
            showAlert(title: "Error", message: "Invalid YouTube URL")
            return
        }

        let ytView = YTPlayerView(frame: videoView.bounds)
        ytView.delegate = self
        ytView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ytView.backgroundColor = .black

        videoView.addSubview(ytView)
        ytPlayerView = ytView

        ytView.load(
            withVideoId: videoID,
            playerVars: [
                "playsinline": 1,
                "autoplay": 1,
                "controls": 1,
                "rel": 0,
                "modestbranding": 1
            ]
        )
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {

        if error == .notEmbeddable {
            openInYouTubeApp()
            return
        }

        showAlert(title: "Playback Error", message: "Unable to play this video")
    }

    private func playWithAVPlayer(urlString: String) {

        cleanup()

        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid video URL")
            return
        }

        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        playerController = AVPlayerViewController()
        playerController?.player = player
        playerController?.showsPlaybackControls = true

        addChild(playerController!)
        videoView.addSubview(playerController!.view)
        playerController!.view.frame = videoView.bounds
        playerController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerController!.didMove(toParent: self)

        player?.play()
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

        return nil
    }

    private func openInYouTubeApp() {

        guard let movie = movieDetailsItem,
              let videoURL = movie.movie_data?.video_url,
              let videoID = extractYouTubeID(from: videoURL) else { return }

        let appURL = URL(string: "youtube://\(videoID)")!
        let webURL = URL(string: "https://www.youtube.com/watch?v=\(videoID)")!

        UIApplication.shared.open(
            UIApplication.shared.canOpenURL(appURL) ? appURL : webURL
        )
    }

    private func cleanup() {

        ytPlayerView?.stopVideo()
        ytPlayerView?.removeFromSuperview()
        ytPlayerView = nil

        player?.pause()
        player = nil
        playerItem = nil

        playerController?.willMove(toParent: nil)
        playerController?.view.removeFromSuperview()
        playerController?.removeFromParent()
        playerController = nil
    }

    private func showAlert(title: String, message: String) {

        if presentedViewController is UIAlertController { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PlayerVC {

    func configureUI() {

        guard let item = selectedItem else { return }

        lblMovieName.text = item.title ?? "Untitled"
        lblMovieDetails.text = "Watch now on Dhuniya"

        if let thumb = item.thumbnail_image,
           let encoded = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {

            imgCoverPic.kf.setImage(
                with: url,
                placeholder: UIImage(named: "thumbnail_image")
            )
        }
    }

    func fetchMovieDetails() {

        NetworkManager.shared.request(
            urlString: API.MOVIES
        ) { (result: Result<APIResponse<[MovieResponseItem]>, NetworkError>) in

            switch result {
            case .success(let response):

                guard let movies = response.info,
                      let selectedId = self.selectedItem?.id else { return }

                if let movie = movies.first(where: { $0.id == selectedId }) {

                    DispatchQueue.main.async {
                        self.movieDetailsItem = movie
                        self.lblMovieName.text = movie.title
                        self.lblMovieDetails.text = movie.synopsis

                        if let thumb = movie.thumbnail_image,
                           let encoded = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: encoded) {

                            self.imgCoverPic.kf.setImage(
                                with: url,
                                placeholder: UIImage(named: "thumbnail_image")
                            )
                        }

                        self.tblVw.reloadData()
                    }
                }

            case .failure:
                break
            }
        }
    }

    func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self

        tblVw.register(UINib(nibName: "PlayerFirstCell", bundle: nil),
                       forCellReuseIdentifier: "PlayerFirstCell")
        tblVw.register(UINib(nibName: "PlayerSecondCell", bundle: nil),
                       forCellReuseIdentifier: "PlayerSecondCell")
        tblVw.register(UINib(nibName: "PlayerThirdCell", bundle: nil),
                       forCellReuseIdentifier: "PlayerThirdCell")

        tblVw.estimatedRowHeight = 100
        tblVw.rowHeight = UITableView.automaticDimension
    }
}

extension PlayerVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {

        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PlayerFirstCell",
                for: indexPath) as! PlayerFirstCell
            
            cell.onShareTapped = { [weak self] in
                self?.shareMovie()
            }
            
            cell.onWatchListTapped = { [weak self] in
                self?.addToWatchList()
            }
            
            cell.onReviewTapped = { [weak self] in
                self?.openReview()
            }
            
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PlayerSecondCell",
                for: indexPath) as! PlayerSecondCell

            if let movie = movieDetailsItem {
                cell.lblDirectorName.text = movie.director_name
                cell.lblAudioLang.text = movie.language
                cell.lblCastDetails.text = movie.cast?.joined(separator: ", ")
                cell.lblProductionHouseName.text = movie.movie_maker_data?.name
                cell.lblProductionHouseDesc.text = movie.movie_maker_data?.description

                if let logo = movie.movie_maker_data?.logo,
                   let encoded = logo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: encoded) {

                    cell.imgProduction.kf.setImage(
                        with: url,
                        placeholder: UIImage(named: "thumbnail_image")
                    )
                }
            }

            return cell

        default:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PlayerThirdCell",
                for: indexPath) as! PlayerThirdCell

            cell.lblHeading.text = "Synopsis"
            cell.lblDesc.text = movieDetailsItem?.synopsis

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 104
        case 1: return 230
        default: return UITableView.automaticDimension
        }
    }
}

extension PlayerVC {
    
    func shareMovie() {
        
        guard let movie = movieDetailsItem else {
            showAlert(title: "Error", message: "Movie details not available")
            return
        }
        
        let movieTitle = movie.title ?? "Check out this movie"
        let movieSynopsis = movie.synopsis ?? ""
        let videoURL = movie.movie_data?.video_url ?? ""
        
        var shareText = "🎬 \(movieTitle)\n\n"
        
        if !movieSynopsis.isEmpty {
            shareText += "\(movieSynopsis)\n\n"
        }
        
        shareText += "Watch now on Dhuniya App!"
        
        var itemsToShare: [Any] = [shareText]
        
        if !videoURL.isEmpty, let url = URL(string: videoURL) {
            itemsToShare.append(url)
        }
        
        if let image = imgCoverPic.image {
            itemsToShare.append(image)
        }
        
        let activityVC = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )
        
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .print
        ]
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    func addToWatchList() {
        
        guard let movie = movieDetailsItem else {
            showAlert(title: "Error", message: "Movie details not available")
            return
        }
        
        showAlert(title: "Added!", message: "\(movie.title ?? "Movie") added to your watchlist")
    }
    
    func openReview() {
        
        guard let movie = movieDetailsItem else {
            showAlert(title: "Error", message: "Movie details not available")
            return
        }
        
        let alert = UIAlertController(
            title: "Write a Review",
            message: "Share your thoughts about \(movie.title ?? "this movie")",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Enter your review..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            if let review = alert.textFields?.first?.text, !review.isEmpty {
                self?.showAlert(title: "Thank You!", message: "Your review has been submitted")
            }
        })
        
        present(alert, animated: true)
    }
}

extension PlayerVC: URLSessionDownloadDelegate {
    
    func downloadVideo() {
        
        guard let movie = movieDetailsItem else {
            showAlert(title: "Error", message: "Movie details not available")
            return
        }
        
        // Get video URL
        let videoURLString = movie.movie_data?.converted_url ?? movie.movie_data?.video_url
        
        guard let urlString = videoURLString, !urlString.isEmpty else {
            showAlert(title: "Error", message: "Video URL not available")
            return
        }
        
        // Check if it's a YouTube video
        if urlString.contains("youtu.be") || urlString.contains("youtube.com") {
            showAlert(title: "Cannot Download", message: "YouTube videos cannot be downloaded directly. Please use YouTube app.")
            return
        }
        
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid video URL")
            return
        }
        
        // Request photo library permission
        requestPhotoLibraryPermission { [weak self] granted in
            if granted {
                self?.startDownload(from: url)
            } else {
                self?.showAlert(title: "Permission Denied", message: "Please allow photo library access in Settings to save videos")
            }
        }
    }
    
    private func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            completion(true)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
            
        case .denied, .restricted:
            completion(false)
            
        @unknown default:
            completion(false)
        }
    }
    
    private func startDownload(from url: URL) {
        
        // Show progress alert
        showDownloadProgressAlert()
        
        // Create download session
        let configuration = URLSessionConfiguration.default
        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: OperationQueue.main
        )
        
        downloadTask = session.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    private func showDownloadProgressAlert() {
        
        progressAlert = UIAlertController(
            title: "Downloading Video",
            message: "Please wait...\n\n",
            preferredStyle: .alert
        )
        
        // Add progress view
        progressView = UIProgressView(progressViewStyle: .default)
        progressView?.frame = CGRect(x: 10, y: 70, width: 250, height: 2)
        progressView?.progress = 0.0
        progressView?.tintColor = .systemBlue
        
        if let progressView = progressView {
            progressAlert?.view.addSubview(progressView)
        }
        
        // Add cancel button
        progressAlert?.addAction(UIAlertAction(title: "Cancel", style: .destructive) { [weak self] _ in
            self?.downloadTask?.cancel()
            self?.downloadTask = nil
        })
        
        if let alert = progressAlert {
            present(alert, animated: true)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        // Dismiss progress alert
        progressAlert?.dismiss(animated: true)
        
        // Save to Photos Library
        saveVideoToPhotos(from: location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async { [weak self] in
            self?.progressView?.progress = progress
            
            let percentage = Int(progress * 100)
            let downloadedMB = Double(totalBytesWritten) / (1024 * 1024)
            let totalMB = Double(totalBytesExpectedToWrite) / (1024 * 1024)
            
            self?.progressAlert?.message = String(format: "%.1f MB / %.1f MB\n%d%%\n", downloadedMB, totalMB, percentage)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        DispatchQueue.main.async { [weak self] in
            self?.progressAlert?.dismiss(animated: true)
            
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    print("Download cancelled")
                } else {
                    self?.showAlert(title: "Download Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func saveVideoToPhotos(from location: URL) {
        
        // Create temporary file path
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "\(movieDetailsItem?.title ?? "video")_\(Date().timeIntervalSince1970).mp4"
        let destinationURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            // Remove existing file if any
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy downloaded file to temp location
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
            // Save to Photos Library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
            }) { [weak self] success, error in
                
                // Clean up temp file
                try? FileManager.default.removeItem(at: destinationURL)
                
                DispatchQueue.main.async {
                    if success {
                        self?.showDownloadSuccessAlert()
                    } else {
                        self?.showAlert(title: "Save Failed", message: error?.localizedDescription ?? "Failed to save video to Photos")
                    }
                }
            }
            
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(title: "Error", message: "Failed to save video: \(error.localizedDescription)")
            }
        }
    }
    
    private func showDownloadSuccessAlert() {
        
        let alert = UIAlertController(
            title: "Download Complete ✅",
            message: "Video saved to Photos successfully!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        alert.addAction(UIAlertAction(title: "Open Photos", style: .default) { _ in
            if let url = URL(string: "photos-redirect://") {
                UIApplication.shared.open(url)
            }
        })
        
        present(alert, animated: true)
    }
}
