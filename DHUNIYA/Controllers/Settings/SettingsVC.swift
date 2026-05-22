//
//  SettingsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

import UIKit
import FirebaseMessaging

class SettingsVC: UIViewController {

    @IBOutlet weak var topVw: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tblVw: UITableView!
    
    // Temporary state for the language selection before saving
    var tempSelectedLanguage: String = "te"
    
    lazy var saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 8
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.addTarget(self, action: #selector(onSaveTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topVw.addBottomShadow()
        self.navigationController?.setNavigationBarHidden(true, animated: false)


        tblVw.delegate = self
        tblVw.dataSource = self

        tblVw.register(UINib(nibName: "SettingsCell", bundle: nil),forCellReuseIdentifier: "SettingsCell")
        tempSelectedLanguage = Session.shared.news_language.lowercased()
        if tempSelectedLanguage == "telugu" { tempSelectedLanguage = "te" }
        if tempSelectedLanguage == "english" { tempSelectedLanguage = "en" }
        
        // Add save button to the bottom of the screen
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    @IBAction func onBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Helper to get current selected language
    func currentLanguage() -> String {
        return UserDefaults.standard.string(forKey: "selectedNewsLanguage") ?? "telugu"
    }
    
    // Update UI for selected language (optional visual feedback)
    func updateLanguageSelection() {
        // Reload table to reflect selection state in cells
        tblVw.reloadData()
    }
    
    // Called by SettingsCell delegate when a language is tapped
    func languageSelected(_ language: String) {
        tempSelectedLanguage = language.lowercased()
        updateLanguageSelection()
    }
    
    @objc private func onSaveTapped() {
        // Map back to internal storage format if necessary, or just save 'en'/'te'
        let oldLanguage = Session.shared.news_language
        let newLanguage = tempSelectedLanguage
        
        if oldLanguage != newLanguage {
            Messaging.messaging().unsubscribe(fromTopic: oldLanguage) { error in
                if let error = error {
                    print("Failed to unsubscribe from old topic \(oldLanguage): \(error)")
                } else {
                    print("Successfully unsubscribed from topic \(oldLanguage)")
                }
            }
            
            Messaging.messaging().subscribe(toTopic: newLanguage) { error in
                if let error = error {
                    print("Failed to subscribe to new topic \(newLanguage): \(error)")
                } else {
                    print("Successfully subscribed to topic \(newLanguage)")
                }
            }
        }
        
        Session.shared.news_language = tempSelectedLanguage
        
        // Notify other parts of the app that language changed
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        
        // Optionally show an alert or go back
        let alert = UIAlertController(title: "Success", message: "Language settings saved successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }

}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingsCell",
            for: indexPath
        ) as! SettingsCell
        
        cell.delegate = self
        // Configure cell button states based on currently *selected* temporary language
        cell.configureSelection(selectedLanguage: tempSelectedLanguage)

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 650
    }
}

// Conform to SettingsCellDelegate
extension SettingsVC: SettingsCellDelegate {
    func didSelectLanguage(_ language: String) {
        languageSelected(language)
    }
}
