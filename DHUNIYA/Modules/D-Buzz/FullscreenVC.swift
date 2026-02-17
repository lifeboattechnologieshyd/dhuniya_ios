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
    
    var data: [BannerModel] = []
    var selectedIndex: Int = 0
    var titleText: String = ""
    private var hasScrolledToInitialPosition = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = false
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasScrolledToInitialPosition && tblVw.bounds.height > 0 {
            hasScrolledToInitialPosition = true
            scrollToSelectedIndex()
        }
    }
    
    func setupUI() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UINib(nibName: "FullCell", bundle: nil), forCellReuseIdentifier: "FullCell")
        tblVw.separatorStyle = .none
        tblVw.isPagingEnabled = true
        tblVw.showsVerticalScrollIndicator = false
        tblVw.bounces = false
        
        if #available(iOS 11.0, *) {
            tblVw.contentInsetAdjustmentBehavior = .never
        }
        
        if #available(iOS 15.0, *) {
            tblVw.sectionHeaderTopPadding = 0
        }
    }
    
    func scrollToSelectedIndex() {
        guard selectedIndex < data.count else { return }
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        tblVw.reloadData()
        tblVw.layoutIfNeeded()
        tblVw.scrollToRow(at: indexPath, at: .top, animated: false)
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
            let documentInteractionController = UIDocumentInteractionController(url: tempFile)
            documentInteractionController.uti = "net.whatsapp.image"
            documentInteractionController.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
        } catch {
            print("Error sharing to WhatsApp: \(error)")
        }
    }
}

extension FullscreenVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullCell", for: indexPath) as! FullCell
        
        if let images = data[indexPath.row].images, let firstImage = images.first, let imageUrl = firstImage {
            cell.imgVw.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "placeholder"))
        }
        
        cell.shareBtn.tag = indexPath.row
        cell.whatsappBtn.tag = indexPath.row
        cell.shareBtn.addTarget(self, action: #selector(shareBtnTapped(_:)), for: .touchUpInside)
        cell.whatsappBtn.addTarget(self, action: #selector(whatsappBtnTapped(_:)), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
    
    @objc func shareBtnTapped(_ sender: UIButton) {
        let index = sender.tag
        if let images = data[index].images, let firstImage = images.first, let imageUrl = firstImage {
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
        if let images = data[index].images, let firstImage = images.first, let imageUrl = firstImage {
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
