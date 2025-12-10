//
//  NewsAddCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 08/12/25.
//
import UIKit
import MobileCoreServices
import AVKit

class NewsAddCell: UITableViewCell {

    @IBOutlet weak var newsLanguageLbl: UILabel!
    @IBOutlet weak var englishBtn: UIButton!
    @IBOutlet weak var teluguBtn: UIButton!
    @IBOutlet weak var hindiBtn: UIButton!
    @IBOutlet weak var politicsBtn: UIButton!
    @IBOutlet weak var financeBtn: UIButton!
    @IBOutlet weak var carsandbikesBtn: UIButton!
    @IBOutlet weak var startupBtn: UIButton!
    @IBOutlet weak var newsDescriptionTv: UITextView!
    @IBOutlet weak var newsTitleTv: UITextView!
    @IBOutlet weak var newsTitleLbl: UILabel!
    @IBOutlet weak var newsDescriptionLbl: UILabel!
    @IBOutlet weak var artBtn: UIButton!
    @IBOutlet weak var newsLocationLbl: UILabel!
    @IBOutlet weak var addTagsLbl: UILabel!
    @IBOutlet weak var moviesBtn: UIButton!
    @IBOutlet weak var newsLocationTf: UITextField!
    @IBOutlet weak var addTagsTf: UITextField!
    @IBOutlet weak var saveDraftBtn: UIButton!
    @IBOutlet weak var videoLbl: UILabel!
    @IBOutlet weak var videoVw: UIView!
    @IBOutlet weak var uncheckedBoxBtn: UIButton!
    @IBOutlet weak var imageVw: UIView!
    @IBOutlet weak var addTagsBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var imageUploadBtn: UIButton!
    @IBOutlet weak var imageViewLbl: UILabel!
    @IBOutlet weak var sportsBtn: UIButton!
    @IBOutlet weak var telanganaBtn: UIButton!
    @IBOutlet weak var internationalAffairsBtn: UIButton!
    @IBOutlet weak var newsCategoryLbl: UILabel!
    @IBOutlet weak var englishView: UIView!
    @IBOutlet weak var teluguView: UIView!
    @IBOutlet weak var hindiView: UIView!
    @IBOutlet weak var politicsView: UIView!
    @IBOutlet weak var financeView: UIView!
    @IBOutlet weak var carsView: UIView!
    @IBOutlet weak var startupView: UIView!
    @IBOutlet weak var artView: UIView!
    @IBOutlet weak var moviesView: UIView!
    @IBOutlet weak var sportsView: UIView!
    @IBOutlet weak var telanganaView: UIView!
    @IBOutlet weak var internationalView: UIView!

    
    var isChecked: Bool = false
    var selectedLanguage: String = "ENGLISH"
    var selectedImage: UIImage?
    var selectedVideoURL: URL?
    private var selectedCategories: Set<String> = []
    
    private lazy var categoryButtons: [UIButton: String] = [
        politicsBtn: "Politics",
        financeBtn: "Finance",
        carsandbikesBtn: "Cars & Bikes",
        startupBtn: "Start-up",
        artBtn: "Art",
        moviesBtn: "Movies",
        sportsBtn: "Sports",
        telanganaBtn: "Telangana",
        internationalAffairsBtn: "International Affairs"
    ]
    
    private lazy var categoryViews: [UIButton: UIView] = [
        politicsBtn: politicsView,
        financeBtn: financeView,
        carsandbikesBtn: carsView,
        startupBtn: startupView,
        artBtn: artView,
        moviesBtn: moviesView,
        sportsBtn: sportsView,
        telanganaBtn: telanganaView,
        internationalAffairsBtn: internationalView
    ]
    
    private lazy var languageViews: [UIButton: UIView] = [
        englishBtn: englishView,
        teluguBtn: teluguView,
        hindiBtn: hindiView
    ]
    
    private lazy var languageTitles: [UIButton: String] = [
        englishBtn: "English",
        teluguBtn: "Telugu",
        hindiBtn: "Hindi"
    ]
    
    private let tagOptions = ["Politics","Sports","International Affairs","Telangana","Finance","Movies","Art","Start-up","Cars & Bikes"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLanguageButtons()
        setupCategoryButtons()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageVw.addDottedBorder(color: .lightGray, cornerRadius: 8)
        videoVw.addDottedBorder(color: .lightGray, cornerRadius: 8)
    }

    // MARK  Language Button Setup
    private func setupLanguageButtons() {
        // Configure buttons and views
        for (button, view) in languageViews {
            // Clear any existing configuration
            button.configuration = nil
            
            // Set title and appearance
            button.setTitle(languageTitles[button], for: .normal)
            button.backgroundColor = .clear
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.contentHorizontalAlignment = .center
            button.addTarget(self, action: #selector(languageButtonTapped(_:)), for: .touchUpInside)
            
            // Configure view borders
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemGray.cgColor
            view.layer.cornerRadius = 6
            view.backgroundColor = .clear
            view.clipsToBounds = true
        }
        
        // Set default selection to English
        updateLanguageSelection(selected: englishBtn)
    }

    @objc private func languageButtonTapped(_ sender: UIButton) {
        updateLanguageSelection(selected: sender)
    }
    
    private func updateLanguageSelection(selected button: UIButton?) {
        // Reset all buttons and view borders
        languageViews.forEach { btn, view in
            btn.setTitleColor(.black, for: .normal)
            view.layer.borderColor = UIColor.systemGray.cgColor
            view.backgroundColor = .clear
        }
        
        // Highlight selected button
        if let selectedBtn = button, let selectedView = languageViews[selectedBtn] {
            selectedLanguage = selectedBtn.currentTitle?.uppercased() ?? "ENGLISH"
            
            selectedBtn.setTitleColor(.systemBlue, for: .normal)
            selectedView.layer.borderColor = UIColor.systemBlue.cgColor
            selectedView.backgroundColor = .clear
        }
    }

    // MARK: Category Button Setup
    private func setupCategoryButtons() {
        for (button, title) in categoryButtons {
            button.configuration = nil
            button.setTitle(title, for: .normal)
            button.backgroundColor = .clear
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)

            if let view = categoryViews[button] {
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor.systemGray.cgColor
                view.layer.cornerRadius = 6
            }
        }
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        // Reset all buttons and view borders
        categoryViews.forEach { btn, view in
            btn.setTitleColor(.black, for: .normal)
            view.layer.borderColor = UIColor.systemGray.cgColor
        }
        
        // Highlight selected
        if let view = categoryViews[sender] {
            sender.setTitleColor(.systemBlue, for: .normal)
            view.layer.borderColor = UIColor.systemBlue.cgColor
            
            if let cat = categoryButtons[sender] {
                selectedCategories = [cat]
                addTagsTf.text = cat
            }
        }
    }

    // MARK: Actions
    @IBAction func onTapuncheckboxButtonx(_ sender: UIButton) {
        isChecked.toggle()
        uncheckedBoxBtn.setImage(UIImage(named: isChecked ? "checked_box" : "Unchecked_box"), for: .normal)
    }

    @IBAction func addTagsBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        for option in tagOptions {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { _ in
                self.selectedCategories.insert(option)
                self.addTagsTf.text = self.selectedCategories.joined(separator: ", ")
                self.updateCategoryButtonUI(for: option)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(alert, animated: true)
        }
    }

    private func updateCategoryButtonUI(for category: String) {
        for (button, name) in categoryButtons {
            if name == category, let view = categoryViews[button] {
                button.setTitleColor(.white, for: .normal)
                view.backgroundColor = .systemBlue
            }
        }
    }

    @IBAction func imageUploadBtnTapped(_ sender: UIButton) {
        openPicker(for: .photoLibrary, mediaTypes: ["public.image"])
    }
    
    @IBAction func videoBtnTapped(_ sender: UIButton) {
        openPicker(for: .savedPhotosAlbum, mediaTypes: ["public.movie"])
    }
    
    private func openPicker(for sourceType: UIImagePickerController.SourceType, mediaTypes: [String]) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.delegate = self
        picker.allowsEditing = true
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(picker, animated: true)
        }
    }

    @IBAction func submitBtnTapped(_ sender: UIButton) {
        let reporterId = String(Session.shared.userDetails?.id ?? 0)
        let reporterName = Session.shared.userDetails?.username ?? ""

        // Check each field individually
        if let title = newsTitleTv.text, title.isEmpty {
            showAlert(title: "Missing Field", message: "Please enter a news title")
            return
        }

        if let description = newsDescriptionTv.text, description.isEmpty {
            showAlert(title: "Missing Field", message: "Please enter a news description")
            return
        }

        if let city = newsLocationTf.text, city.isEmpty {
            showAlert(title: "Missing Field", message: "Please enter a city/location")
            return
        }

        if selectedCategories.isEmpty {
            showAlert(title: "Missing Field", message: "Please select at least one category")
            return
        }

        if reporterId.isEmpty || reporterName.isEmpty {
            showAlert(title: "Missing Field", message: "Reporter information is missing")
            return
        }

        // All fields are filled, proceed with uploading image / posting news
        if let image = selectedImage {
            uploadImage(image) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let uploadedUrls):
                        self.postNews(reporterId: reporterId, reporterName: reporterName, uploadedImageUrls: uploadedUrls)
                    case .failure(let error):
                        self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                    }
                }
            }
        } else {
            postNews(reporterId: reporterId, reporterName: reporterName, uploadedImageUrls: [])
        }
    }

    // MARK: Network Calls
    private func postNews(reporterId: String, reporterName: String, uploadedImageUrls: [String]) {
        let payload: [String: Any] = [
            "title": newsTitleTv.text ?? "",
            "description": newsDescriptionTv.text ?? "",
            "city": [newsLocationTf.text ?? ""],
            "district": [newsLocationTf.text ?? ""],
            "language": selectedLanguage,
            "categories": Array(selectedCategories).map { $0.uppercased() },
            "image": uploadedImageUrls
        ]

        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Session.shared.accesstoken)"
        ]

        NetworkManager.shared.request(
            urlString: API.NEWS_POST,
            method: .POST,
            parameters: payload,
            headers: headers
        ) { (result: Result<APIResponse<EmptyInfo>, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.showAlert(title: response.success ? "Success" : "Error", message: response.description) {
                        // Navigate to ReportVC after success
                        if response.success {
                            self.navigateToReportVC()
                        }
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    private func uploadImage(_ image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: API.STORE_FILES),
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Session.shared.accesstoken ?? "")", forHTTPHeaderField: "Authorization")

        let body = NSMutableData()

        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"entity\"\r\n\r\n")
        body.appendString("news\r\n")

        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"files\"; filename=\"image.jpg\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")

        request.httpBody = body as Data

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Upload Failed with Error:", error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("Upload Failed: No data received")
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let response = try JSONDecoder().decode(FileUploadResponse.self, from: data)
                print("Upload Response:", response)
                if response.success {
                    completion(.success(response.info))
                } else {
                    let error = NSError(domain: "", code: response.errorCode, userInfo: [NSLocalizedDescriptionKey: response.description])
                    completion(.failure(error))
                }
            } catch {
                print("Upload JSON Decode Error:", error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK:  Helper Methods
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        if let parentVC = self.parentViewController() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            parentVC.present(alert, animated: true)
        }
    }

    private func navigateToReportVC() {
        guard let parentVC = self.parentViewController() else { return }
        let storyboard = UIStoryboard(name: "Reporter", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReporterVC")
        if let nav = parentVC.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            parentVC.present(vc, animated: true)
        }
    }
}

// MARK: UIImagePickerControllerDelegate
extension NewsAddCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let pickedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            selectedImage = pickedImage
            imageVw.subviews.forEach { $0.removeFromSuperview() }
            let imageView = UIImageView(frame: imageVw.bounds)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = pickedImage
            imageVw.addSubview(imageView)
        } else if let videoURL = info[.mediaURL] as? URL {
            selectedVideoURL = videoURL
            videoVw.subviews.forEach { $0.removeFromSuperview() }
            let label = UILabel(frame: videoVw.bounds)
            label.text = "Video Selected"
            label.textAlignment = .center
            label.textColor = .black
            videoVw.addSubview(label)
        }
    }
}
