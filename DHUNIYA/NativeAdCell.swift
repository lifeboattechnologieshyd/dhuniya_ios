//
//  FullScreenNativeAdCell.swift
//  DHUNIYA
//

import UIKit
import GoogleMobileAds
import Kingfisher

class FullScreenNativeAdCell: UITableViewCell {
    
    static let identifier = "FullScreenNativeAdCell"
    
    // MARK: - Top Half (Ad) Properties
    private let topContainer = UIView()
    private let nativeAdView = NativeAdView()
    private let mediaView = MediaView()
    private let adHeadline = UILabel()
    private let adBadge = UILabel()
    private let ctaButton = UIButton(type: .system)
    private let advertiserLabel = UILabel()
    
    // Loading Views
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    
    // MARK: - Bottom Half (News) Properties
    private let bottomContainer = UIView()
    private let recommendedTitle = UILabel()
    private let newsStackView = UIStackView()
    
    // Store related news for tap
    private var relatedNewsList: [NewsModel] = []
    
    // Callback when a recommended news item is clicked
    var onNewsClick: ((Int, NewsModel) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        // 1. Top Container (Ad) - 52% Height with top padding
        contentView.addSubview(topContainer)
        topContainer.backgroundColor = .systemGray6
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. Bottom Container (News) - Remaining Height
        contentView.addSubview(bottomContainer)
        bottomContainer.backgroundColor = .white
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ✅ Top Container with TOP PADDING (safe area)
            topContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50), // Top padding for status bar
            topContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainer.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.48), // Reduced from 0.55
            
            // ✅ Bottom Container - NO GAP between Ad and News
            bottomContainer.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: 0), // No gap
            bottomContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // Bottom padding
        ])
        
        setupAdUI()
        setupLoadingUI()
        setupNewsUI()
    }
    
    private func setupAdUI() {
        // Native Ad View
        topContainer.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nativeAdView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            nativeAdView.topAnchor.constraint(equalTo: topContainer.topAnchor),
            nativeAdView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor)
        ])
        
        // Media View (Video/Image)
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        nativeAdView.addSubview(mediaView)
        
        // Ad Badge
        adBadge.text = "Ad"
        adBadge.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        adBadge.backgroundColor = .systemYellow
        adBadge.textColor = .black
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 3
        adBadge.clipsToBounds = true
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.addSubview(adBadge)
        
        // Headline
        adHeadline.font = UIFont.boldSystemFont(ofSize: 16)
        adHeadline.textColor = .black
        adHeadline.numberOfLines = 2
        adHeadline.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.addSubview(adHeadline)
        
        // Advertiser Label
        advertiserLabel.font = UIFont.systemFont(ofSize: 12)
        advertiserLabel.textColor = .darkGray
        advertiserLabel.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.addSubview(advertiserLabel)
        
        // CTA Button
        ctaButton.backgroundColor = .systemBlue
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        ctaButton.layer.cornerRadius = 6
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.addSubview(ctaButton)
        
        NSLayoutConstraint.activate([
            // ✅ Media takes up top 70% of the ad space
            mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            mediaView.heightAnchor.constraint(equalTo: nativeAdView.heightAnchor, multiplier: 0.70),
            
            // ✅ Badge below media - reduced spacing
            adBadge.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            adBadge.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 8),
            adBadge.widthAnchor.constraint(equalToConstant: 26),
            adBadge.heightAnchor.constraint(equalToConstant: 16),
            
            // Advertiser next to badge
            advertiserLabel.leadingAnchor.constraint(equalTo: adBadge.trailingAnchor, constant: 8),
            advertiserLabel.centerYAnchor.constraint(equalTo: adBadge.centerYAnchor),
            
            // ✅ Headline - reduced top spacing
            adHeadline.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            adHeadline.trailingAnchor.constraint(equalTo: ctaButton.leadingAnchor, constant: -12),
            adHeadline.topAnchor.constraint(equalTo: adBadge.bottomAnchor, constant: 6),
            
            // CTA Button
            ctaButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            ctaButton.centerYAnchor.constraint(equalTo: adHeadline.centerYAnchor),
            ctaButton.widthAnchor.constraint(equalToConstant: 90),
            ctaButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        // Link GAD Views
        nativeAdView.mediaView = mediaView
        nativeAdView.headlineView = adHeadline
        nativeAdView.callToActionView = ctaButton
        nativeAdView.advertiserView = advertiserLabel
    }
    
    private func setupLoadingUI() {
        loadingIndicator.color = .gray
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        loadingLabel.text = "Loading Ad..."
        loadingLabel.font = UIFont.systemFont(ofSize: 14)
        loadingLabel.textColor = .darkGray
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topContainer.addSubview(loadingIndicator)
        topContainer.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: -15),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 10),
            loadingLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor)
        ])
    }
    
    private func setupNewsUI() {
        // "Recommended News" Header
        recommendedTitle.text = "RECOMMENDED NEWS"
        recommendedTitle.font = UIFont.systemFont(ofSize: 13, weight: .heavy)
        recommendedTitle.textColor = .darkGray
        recommendedTitle.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(recommendedTitle)
        
        // StackView for 3 News items
        newsStackView.axis = .vertical
        newsStackView.distribution = .fillEqually
        newsStackView.spacing = 0 // ✅ No spacing between news items
        newsStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(newsStackView)
        
        NSLayoutConstraint.activate([
            // ✅ Reduced top spacing for header
            recommendedTitle.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 8),
            recommendedTitle.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            
            // ✅ News stack with minimal spacing
            newsStackView.topAnchor.constraint(equalTo: recommendedTitle.bottomAnchor, constant: 8),
            newsStackView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            newsStackView.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            newsStackView.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor)
        ])
    }
    
    // MARK: - Show Loading
    func showLoading() {
        loadingIndicator.startAnimating()
        loadingLabel.isHidden = false
        nativeAdView.isHidden = true
    }
    
    // MARK: - Hide Loading
    private func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden = true
        nativeAdView.isHidden = false
    }
    
    // MARK: - Configure Method
    func configure(nativeAd: NativeAd, relatedNews: [NewsModel]) {
        hideLoading()
        
        // 1. Configure Ad
        nativeAdView.nativeAd = nativeAd
        mediaView.mediaContent = nativeAd.mediaContent
        adHeadline.text = nativeAd.headline
        advertiserLabel.text = nativeAd.advertiser ?? "Sponsored"
        ctaButton.setTitle(nativeAd.callToAction ?? "Open", for: .normal)
        
        // 2. Store news list
        self.relatedNewsList = relatedNews
        
        // 3. Configure News
        newsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, news) in relatedNews.prefix(3).enumerated() {
            let newsRow = createNewsRow(news: news, index: index)
            newsStackView.addArrangedSubview(newsRow)
        }
    }
    
    private func createNewsRow(news: NewsModel, index: Int) -> UIView {
        let row = UIView()
        row.backgroundColor = .clear
        
        // Add Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(newsRowTapped(_:)))
        row.tag = index
        row.addGestureRecognizer(tap)
        row.isUserInteractionEnabled = true
        
        // Image on RIGHT
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 8
        imgView.backgroundColor = .darkGray
        imgView.setKFImage(news.image?.first)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title on LEFT
        let titleLbl = UILabel()
        titleLbl.text = news.title
        titleLbl.textColor = .black
        titleLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLbl.numberOfLines = 2
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        // Divider Line
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(imgView)
        row.addSubview(titleLbl)
        row.addSubview(divider)
        
        NSLayoutConstraint.activate([
            // ✅ Image Right - slightly smaller
            imgView.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            imgView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            imgView.widthAnchor.constraint(equalToConstant: 90),
            imgView.heightAnchor.constraint(equalToConstant: 60),
            
            // Title Left
            titleLbl.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            titleLbl.trailingAnchor.constraint(equalTo: imgView.leadingAnchor, constant: -12),
            titleLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            // Divider
            divider.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            divider.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        return row
    }
    
    @objc private func newsRowTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag, index < relatedNewsList.count else { return }
        
        // Tap animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.view?.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.view?.transform = .identity
            }
        }
        
        onNewsClick?(index, relatedNewsList[index])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden = true
        nativeAdView.nativeAd = nil
        nativeAdView.isHidden = false
        relatedNewsList.removeAll()
        newsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
