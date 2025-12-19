//
//  ReporterVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 03/12/25.
//


import UIKit

enum NewsType {
    case submitted
    case published
    case rejected
    case drafts
}

class ReporterVC: UIViewController {

    var reporterProfile: ReporterProfile?

    var selectedNewsType: NewsType = .submitted
    
    var allPosts: [ReporterPost] = []
    var submittedPosts: [ReporterPost] = []
    var publishedPosts: [ReporterPost] = []
    var rejectedPosts: [ReporterPost] = []
    var draftPosts: [ReporterPost] = []
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var lblPhonenumber: UILabel!
    @IBOutlet weak var btnProfilepic: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var rankVw: UIView!
    @IBOutlet weak var publishVw: UIView!
    @IBOutlet weak var ranknumberLbl: UILabel!
    @IBOutlet weak var noofpublished: UILabel!
    @IBOutlet weak var viewsVw: UIView!
    @IBOutlet weak var noofViewsLbl: UILabel!
    @IBOutlet weak var interactionsVw: UIView!
    @IBOutlet weak var noofinteractionsLbl: UILabel!
    @IBOutlet weak var earningsLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var withdrawBtn: UIButton!
    @IBOutlet weak var publishnewarticleBtn: UIButton!
    @IBOutlet weak var submittedBtn: UIButton!
    @IBOutlet weak var publishedBtn: UIButton!
    @IBOutlet weak var rejectedBtn: UIButton!
    @IBOutlet weak var draftsBtn: UIButton!
    @IBOutlet weak var tblVw: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make profile image circular
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        
        // BUTTON BASE SETUP
        let buttons = [submittedBtn, publishedBtn, rejectedBtn, draftsBtn]
        buttons.forEach { button in
            button?.titleLabel?.numberOfLines = 1
            button?.titleLabel?.lineBreakMode = .byClipping
            button?.titleLabel?.adjustsFontSizeToFitWidth = false
            button?.contentHorizontalAlignment = .center
            button?.contentVerticalAlignment = .center
            button?.adjustsImageWhenHighlighted = false
            button?.adjustsImageWhenDisabled = false
        }
        
        // 🔥 iOS 15+ CONFIGURATION KILL (MANDATORY)
        if #available(iOS 15.0, *) {
            let buttons = [submittedBtn, publishedBtn, rejectedBtn, draftsBtn]
            buttons.forEach { button in
                button?.configuration = nil
            }
        }
        
        // 🔥 EXTRA SAFETY: REMOVE ALL BACKGROUND HIGHLIGHTS
        let allButtons = [submittedBtn, publishedBtn, rejectedBtn, draftsBtn]
        allButtons.forEach {
            $0?.backgroundColor = .clear
            $0?.setBackgroundImage(UIImage(), for: .normal)
            $0?.setBackgroundImage(UIImage(), for: .highlighted)
            $0?.setBackgroundImage(UIImage(), for: .selected)
            $0?.showsTouchWhenHighlighted = false
        }
        
        // 🔥 FORCE TITLES (THIS IS WHY YOUR TEXT WAS MISSING)
        forceSetButtonTitles()
        
        // Default selection
        selectedNewsType = .submitted
        updateButtonSelection(selected: submittedBtn)
        
        self.navigationItem.hidesBackButton = true

        tblVw.delegate = self
        tblVw.dataSource = self

        tblVw.register(UINib(nibName: "SubmittedNewsCell", bundle: nil), forCellReuseIdentifier: "SubmittedNewsCell")
        tblVw.register(UINib(nibName: "PublishedCell", bundle: nil), forCellReuseIdentifier: "PublishedCell")
        tblVw.register(UINib(nibName: "RejectedCell", bundle: nil), forCellReuseIdentifier: "RejectedCell")
        tblVw.register(UINib(nibName: "DraftsCell", bundle: nil), forCellReuseIdentifier: "DraftsCell")

        setupProfileImageObserver(imageView: profileImage)
        fetchReporterProfileData()
        fetchReporterPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
    }
    
    // 🔥 THIS FIXES EMPTY BUTTON TEXT
    private func forceSetButtonTitles() {
        submittedBtn.setTitle("Submitted", for: .normal)
        publishedBtn.setTitle("Published", for: .normal)
        rejectedBtn.setTitle("Rejected", for: .normal)
        draftsBtn.setTitle("Drafts", for: .normal)
    }

    private func updateButtonSelection(selected: UIButton) {
        let buttons = [submittedBtn, publishedBtn, rejectedBtn, draftsBtn]

        buttons.forEach { button in
            guard let button = button else { return }

            if button == selected {
                button.setTitleColor(.systemBlue, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            } else {
                button.setTitleColor(.black, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            }

            // 🔥 ENSURE NO BACKGROUND EVER
            button.backgroundColor = .clear
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submittedBtnTapped(_ sender: UIButton) {
        selectedNewsType = .submitted
        updateButtonSelection(selected: submittedBtn)
        tblVw.reloadData()
    }

    @IBAction func publishedBtnTapped(_ sender: UIButton) {
        selectedNewsType = .published
        updateButtonSelection(selected: publishedBtn)
        tblVw.reloadData()
    }

    @IBAction func rejectedBtnTapped(_ sender: UIButton) {
        selectedNewsType = .rejected
        updateButtonSelection(selected: rejectedBtn)
        tblVw.reloadData()
    }

    @IBAction func draftsBtnTapped(_ sender: UIButton) {
        selectedNewsType = .drafts
        updateButtonSelection(selected: draftsBtn)
        tblVw.reloadData()
    }

    private func fetchReporterProfileData() {
        NetworkManager.shared.request(urlString: API.REPORTER_PROFILE, method: .GET) { [weak self] (result: Result<APIResponse<ReporterProfile>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if response.success, let profile = response.info {
                        self.reporterProfile = profile
                        self.updateUI(with: profile)
                        self.tblVw.reloadData()
                    } else {
                        self.showError(response.description)
                    }
                case .failure(let error):
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    private func fetchReporterPosts() {
        NetworkManager.shared.request(urlString: API.REPORTER_POSTS, method: .GET) { [weak self] (result: Result<APIResponse<[ReporterPost]>, NetworkError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if response.success, let posts = response.info {
                        self.allPosts = posts
                        self.filterPosts()
                        self.tblVw.reloadData()
                    } else {
                        self.showError(response.description)
                    }
                case .failure(let error):
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    private func updateUI(with profile: ReporterProfile) {
        usernameLbl.text = profile.reporterName
        lblPhonenumber.text = Session.shared.mobileNumber
        ranknumberLbl.text = "\(profile.rank)"
        noofpublished.text = "\(profile.approvedNewsCount)"
        noofViewsLbl.text = "\(profile.viewsCount)"
        
        let interactions = profile.likesCount + profile.commentsCount + profile.sharesCount + profile.whatsappSharesCount
        noofinteractionsLbl.text = "\(interactions)"
        amountLbl.text = "₹\(profile.currentEarnings)"
    }

    private func filterPosts() {
        submittedPosts = allPosts.filter { $0.status.uppercased() == "PENDING" }
        publishedPosts = allPosts.filter { $0.status.uppercased() == "APPROVED" }
        rejectedPosts = allPosts.filter { $0.status.uppercased() == "REJECTED" }
        draftPosts = allPosts.filter { $0.status.uppercased() == "DRAFT" }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ReporterVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedNewsType {
        case .submitted: return submittedPosts.count
        case .published: return publishedPosts.count
        case .rejected: return rejectedPosts.count
        case .drafts: return draftPosts.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedNewsType {
        case .submitted:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubmittedNewsCell", for: indexPath) as! SubmittedNewsCell
            cell.selectionStyle = .none
            let post = submittedPosts[indexPath.row]
            cell.newsTitleLbl.text = post.title
            return cell
        case .published:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublishedCell", for: indexPath) as! PublishedCell
            cell.selectionStyle = .none
            let post = publishedPosts[indexPath.row]
            cell.newsTitleLbl.text = post.title
            return cell
        case .rejected:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RejectedCell", for: indexPath) as! RejectedCell
            cell.selectionStyle = .none
            let post = rejectedPosts[indexPath.row]
            cell.newsTitleLbl.text = post.title
            return cell
        case .drafts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DraftsCell", for: indexPath) as! DraftsCell
            cell.selectionStyle = .none
            let post = draftPosts[indexPath.row]
            cell.newsTitleLbl.text = post.title
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 70 }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 4 }
}
