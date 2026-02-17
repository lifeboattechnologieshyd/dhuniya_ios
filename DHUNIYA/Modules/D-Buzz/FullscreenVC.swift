//
//  FullscreenVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 16/02/26.
//

import UIKit
import Kingfisher

class FullscreenVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    
    var collectionView: UICollectionView!
    var data: [BannerModel] = []
    var selectedIndex: Int = 0
    var titleText: String = ""
    
    private var hasScrolledToInitial = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVw.isHidden = true
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = view.bounds.size
            layout.invalidateLayout()
        }
        
        guard !hasScrolledToInitial else { return }
        guard selectedIndex < data.count else { return }
        guard view.bounds.height > 0 else { return }
        
        hasScrolledToInitial = true
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: self.selectedIndex, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = view.bounds.size
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(FullscreenImageCell.self, forCellWithReuseIdentifier: "FullscreenImageCell")
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        view.addSubview(collectionView)
    }
    
    @objc func backBtnAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func shareImage(image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func shareToWhatsApp(image: UIImage) {
        guard let imageData = image.pngData() else { return }
        let tempFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("share.png")
        do {
            try imageData.write(to: tempFile)
            let dic = UIDocumentInteractionController(url: tempFile)
            dic.uti = "net.whatsapp.image"
            dic.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
        } catch {
            print("Error sharing to WhatsApp: \(error)")
        }
    }
}

extension FullscreenVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullscreenImageCell", for: indexPath) as! FullscreenImageCell
        
        if let images = data[indexPath.item].images,
           let firstImage = images.first,
           let imageUrl = firstImage {
            cell.imgVw.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "placeholder"))
        }
        
        cell.shareBtn.tag = indexPath.item
        cell.whatsappBtn.tag = indexPath.item
        cell.shareBtn.addTarget(self, action: #selector(shareBtnTapped(_:)), for: .touchUpInside)
        cell.whatsappBtn.addTarget(self, action: #selector(whatsappBtnTapped(_:)), for: .touchUpInside)
        cell.backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }
    
    @objc func shareBtnTapped(_ sender: UIButton) {
        let index = sender.tag
        if let images = data[index].images,
           let firstImage = images.first,
           let imageUrl = firstImage {
            KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!) { result in
                switch result {
                case .success(let value):
                    self.shareImage(image: value.image)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    @objc func whatsappBtnTapped(_ sender: UIButton) {
        let index = sender.tag
        if let images = data[index].images,
           let firstImage = images.first,
           let imageUrl = firstImage {
            KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!) { result in
                switch result {
                case .success(let value):
                    self.shareToWhatsApp(image: value.image)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
}

class FullscreenImageCell: UICollectionViewCell {
    
    let imgVw = UIImageView()
    let shareBtn = UIButton(type: .custom)
    let whatsappBtn = UIButton(type: .custom)
    let backBtn = UIButton(type: .system)
    let logoImgVw = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .black
        
        // Image View - Full screen
        imgVw.contentMode = .scaleAspectFit
        imgVw.clipsToBounds = true
        imgVw.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imgVw)
        
        // Back Button - Top Left
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .white
        backBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backBtn.layer.cornerRadius = 20
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backBtn)
        
        // Dhuniya Logo - Bottom Left
        logoImgVw.image = UIImage(named: "Dhuniya")
        logoImgVw.contentMode = .scaleToFill
        logoImgVw.clipsToBounds = true
        logoImgVw.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoImgVw)
        
        // WhatsApp Button - Bottom Right
        whatsappBtn.setImage(UIImage(named: "whatsappshare"), for: .normal)
        whatsappBtn.imageView?.contentMode = .scaleAspectFit
        whatsappBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(whatsappBtn)
        
        // Share Button - Left of WhatsApp
        shareBtn.setImage(UIImage(named: "share_banner"), for: .normal)
        shareBtn.imageView?.contentMode = .scaleAspectFit
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shareBtn)
        
        NSLayoutConstraint.activate([
            // Image - fill entire cell
            imgVw.topAnchor.constraint(equalTo: contentView.topAnchor),
            imgVw.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imgVw.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imgVw.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Back button - top left
            backBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            backBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backBtn.widthAnchor.constraint(equalToConstant: 40),
            backBtn.heightAnchor.constraint(equalToConstant: 40),
            
            // Dhuniya logo - bottom left
            // bottom: 0, leading: 4, height: 40, width: 60
            logoImgVw.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            logoImgVw.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            logoImgVw.heightAnchor.constraint(equalToConstant: 40),
            logoImgVw.widthAnchor.constraint(equalToConstant: 70),
            
            // WhatsApp button - bottom right
            // bottom: 4, trailing: 16, height: 16, width: 16
            whatsappBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            whatsappBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            whatsappBtn.heightAnchor.constraint(equalToConstant: 24),
            whatsappBtn.widthAnchor.constraint(equalToConstant: 24),
            
            // Share button - left of WhatsApp, gap 12
            // same height & width as whatsapp
            shareBtn.centerYAnchor.constraint(equalTo: whatsappBtn.centerYAnchor),
            shareBtn.trailingAnchor.constraint(equalTo: whatsappBtn.leadingAnchor, constant: -12),
            shareBtn.heightAnchor.constraint(equalToConstant: 24),
            shareBtn.widthAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgVw.image = nil
        shareBtn.removeTarget(nil, action: nil, for: .allEvents)
        whatsappBtn.removeTarget(nil, action: nil, for: .allEvents)
        backBtn.removeTarget(nil, action: nil, for: .allEvents)
    }
}
