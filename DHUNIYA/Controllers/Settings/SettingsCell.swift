//
//  SettingsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 24/11/25.
//

import UIKit

protocol SettingsCellDelegate: AnyObject {
    func didSelectLanguage(_ language: String)
}

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var newsTeluguButton: UIButton!
    @IBOutlet weak var newslanguageLbl: UILabel!
    @IBOutlet weak var newsEnglishButton: UIButton!
    @IBOutlet weak var newsHindiButton: UIButton!
    @IBOutlet weak var teluguButton: UIButton!
    @IBOutlet weak var applanguageLbl: UILabel!
    
    weak var delegate: SettingsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Add target actions for language buttons
        newsEnglishButton.addTarget(self, action: #selector(englishTapped), for: .touchUpInside)
        newsTeluguButton.addTarget(self, action: #selector(teluguTapped), for: .touchUpInside)
    }
    
    @objc private func englishTapped() {
        // Update UI for immediate feedback
        newsEnglishButton.backgroundColor = .systemBlue
        newsTeluguButton.backgroundColor = .clear
        delegate?.didSelectLanguage("en")
    }
    
    @objc private func teluguTapped() {
        // Update UI for immediate feedback
        newsEnglishButton.backgroundColor = .clear
        newsTeluguButton.backgroundColor = .systemBlue
        delegate?.didSelectLanguage("te")
    }
    
    // Configure button appearance based on selected language
    func configureSelection(selectedLanguage: String) {
        let isTelugu = selectedLanguage.lowercased() == "te" || selectedLanguage.uppercased() == "TELUGU"
        newsEnglishButton.backgroundColor = isTelugu ? .clear : .systemBlue
        newsTeluguButton.backgroundColor = isTelugu ? .systemBlue : .clear
    }
}

