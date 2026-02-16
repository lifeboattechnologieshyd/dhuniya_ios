//
//  DBuzzVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 16/02/26.
//

import UIKit

class DBuzzVC: UIViewController {
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var topVw: UIView!
    
    var quotesData: [BannerModel] = []
    var cartoonData: [BannerModel] = []
    var bannersData: [BannerModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topVw.addBottomShadow()
        setupTableView()
        fetchAllData()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        }
    
    func setupTableView() {
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UINib(nibName: "QuoteCell", bundle: nil), forCellReuseIdentifier: "QuoteCell")
        tblVw.register(UINib(nibName: "BanersCell", bundle: nil), forCellReuseIdentifier: "BanersCell")
        tblVw.register(UINib(nibName: "CartoonCell", bundle: nil), forCellReuseIdentifier: "CartoonCell")
        tblVw.separatorStyle = .none
    }
    
    func fetchAllData() {
        fetchQuotes()
        fetchCartoons()
        fetchBanners()
    }
    
    func fetchQuotes() {
        NetworkManager.shared.request(urlString: API.QUOTES_API) { [weak self] (result: Result<APIResponse<[BannerModel]>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.info {
                    DispatchQueue.main.async {
                        self?.quotesData = data
                        self?.tblVw.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                }
            case .failure(let error):
                print("Error fetching quotes: \(error)")
            }
        }
    }
    
    func fetchCartoons() {
        NetworkManager.shared.request(urlString:API.CARTOONS_API) { [weak self] (result: Result<APIResponse<[BannerModel]>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.info {
                    DispatchQueue.main.async {
                        self?.cartoonData = data
                        self?.tblVw.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                    }
                }
            case .failure(let error):
                print("Error fetching cartoons: \(error)")
            }
        }
    }
    
    func fetchBanners() {
        NetworkManager.shared.request(urlString: API.BANNERS_API) { [weak self] (result: Result<APIResponse<[BannerModel]>, NetworkError>) in
            switch result {
            case .success(let response):
                if response.success, let data = response.info {
                    DispatchQueue.main.async {
                        self?.bannersData = data
                        self?.tblVw.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                    }
                }
            case .failure(let error):
                print("Error fetching banners: \(error)")
            }
        }
    }
    
    @objc func viewAllQuotes() {
        navigateToGrid(with: quotesData, title: "Quotes")
    }
    
    @objc func viewAllBanners() {
        navigateToGrid(with: bannersData, title: "Banners")
    }
    
    @objc func viewAllCartoons() {
        navigateToGrid(with: cartoonData, title: "Cartoons")
    }
    
    func navigateToGrid(with data: [BannerModel], title: String) {
        let storyboard = UIStoryboard(name: "DBuzz", bundle: nil)
        if let gridVC = storyboard.instantiateViewController(withIdentifier: "GridVC") as? GridVC {
            gridVC.data = data
            gridVC.titleText = title
            navigationController?.pushViewController(gridVC, animated: true)
        }
    }
}

extension DBuzzVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteCell
            cell.configureCell(with: quotesData)
            cell.viewallBtn.addTarget(self, action: #selector(viewAllQuotes), for: .touchUpInside)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BanersCell", for: indexPath) as! BanersCell
            cell.configureCell(with: bannersData)
            cell.viewAllBtn.addTarget(self, action: #selector(viewAllBanners), for: .touchUpInside)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartoonCell", for: indexPath) as! CartoonCell
            cell.configureCell(with: cartoonData)
            cell.viewallBtn.addTarget(self, action: #selector(viewAllCartoons), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 424
        case 1: return 174
        case 2: return 174
        default: return 0
        }
    }
}
