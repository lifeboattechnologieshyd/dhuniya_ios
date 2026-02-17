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
                print("Quotes Response: \(response)")
                if response.success, let data = response.info {
                    DispatchQueue.main.async {
                        self?.quotesData = data
                        self?.tblVw.reloadData()
                    }
                }
            case .failure(let error):
                print("Error fetching quotes: \(error)")
            }
        }
    }
    
    func fetchCartoons() {
        NetworkManager.shared.request(urlString: API.CARTOONS_API) { [weak self] (result: Result<APIResponse<[BannerModel]>, NetworkError>) in
            switch result {
            case .success(let response):
                print("Cartoons Response: \(response)")
                if response.success, let data = response.info {
                    DispatchQueue.main.async {
                        self?.cartoonData = data
                        self?.tblVw.reloadData()
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
                print("Banners Response: \(response)")
                if response.success, let data = response.info {
                    DispatchQueue.main.async {
                        self?.bannersData = data
                        self?.tblVw.reloadData()
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
            gridVC.hidesBottomBarWhenPushed = false
            navigationController?.pushViewController(gridVC, animated: true)
        }
    }
    
    func navigateToFullscreen(data: [BannerModel], selectedIndex: Int, title: String) {
        let storyboard = UIStoryboard(name: "DBuzz", bundle: nil)
        let fullscreenVC = storyboard.instantiateViewController(withIdentifier: "FullscreenVC") as! FullscreenVC
        fullscreenVC.data = data
        fullscreenVC.selectedIndex = selectedIndex
        fullscreenVC.titleText = title
        self.navigationController?.pushViewController(fullscreenVC, animated: true)
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
            cell.onItemSelected = { [weak self] index in
                guard let self = self else { return }
                print("Quote selected at index: \(index)")
                self.navigateToFullscreen(data: self.quotesData, selectedIndex: index, title: "Quotes")
            }
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BanersCell", for: indexPath) as! BanersCell
            cell.configureCell(with: bannersData)
            cell.viewAllBtn.addTarget(self, action: #selector(viewAllBanners), for: .touchUpInside)
            cell.onItemSelected = { [weak self] index in
                guard let self = self else { return }
                print("Banner selected at index: \(index)")
                self.navigateToFullscreen(data: self.bannersData, selectedIndex: index, title: "Banners")
            }
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartoonCell", for: indexPath) as! CartoonCell
            cell.configureCell(with: cartoonData)
            cell.viewallBtn.addTarget(self, action: #selector(viewAllCartoons), for: .touchUpInside)
            cell.onItemSelected = { [weak self] index in
                guard let self = self else { return }
                print("Cartoon selected at index: \(index)")
                self.navigateToFullscreen(data: self.cartoonData, selectedIndex: index, title: "Cartoons")
            }
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 424
        case 1: return 174
        case 2: return 184
        default: return 0
        }
    }
}
