//
//  BecomeNewsReporterVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

class BecomeNewsReporterVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var tblVw: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        self.navigationItem.hidesBackButton = true
        
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.register(UINib(nibName: "ReportersCell", bundle: nil), forCellReuseIdentifier: "ReportersCell")
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension BecomeNewsReporterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportersCell", for: indexPath) as! ReportersCell
        
        // When Submit button tapped
        cell.onSubmitTapped = { [weak self] in
            guard let self = self else { return }
            
            var selectedLanguages = [String]()
            if cell.englishButton.isSelected { selectedLanguages.append("ENGLISH") }
            if cell.hindiButton.isSelected { selectedLanguages.append("HINDI") }
            if cell.teluguButton.isSelected { selectedLanguages.append("TELUGU") }

            // Build payload
            let payload: [String: Any] = [
                "reporter_name": cell.reporternameTF.text ?? "",
                "mobile": cell.mobilenumberTF.text ?? "",
                "username": cell.usernameTF.text ?? "",
                "description": cell.tellyourselfTV.text ?? "",
                "languages": selectedLanguages
            ]
            
            // Call API
            NetworkManager.shared.request(
                urlString: API.BASE_URL + "news/reporter/apply",
                method: .POST,
                parameters: payload
            ) { (result: Result<APIResponse<NewsReporterApplyInfo>, NetworkError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.success, let info = response.info {
                            print(info.message)
                            self.presentApplicationSentVC()
                        } else {
                            self.showError(response.description)
                        }
                    case .failure(let error):
                        self.showError(error.localizedDescription)
                    }
                }
            }
        }
        
        return cell 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1100
    }
}

extension BecomeNewsReporterVC {
    
    func presentApplicationSentVC() {
        let vc = UIStoryboard(name: "BecomeNewsReporter", bundle: nil)
            .instantiateViewController(withIdentifier: "ApplicationSentVC") as! ApplicationSentVC
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
