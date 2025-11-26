//
//  NewsCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var whatsappLbl: UILabel!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var newsTextView: UITextView!
    @IBOutlet weak var dhuniyaWatermarkImg: UIImageView!
    @IBOutlet weak var uploadedTime: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var NewsImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        whatsappButton.addTarget(self, action: #selector(whatsappTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
    }
    
    @objc func whatsappTapped() {
        let message = newsTitle.text ?? ""
        let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "whatsapp://send?text=\(encoded)"
        
        if let url = URL(string: urlString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showSimpleAlert(
                title: "WhatsApp Not Installed",
                message: "Please install WhatsApp to continue."
            )
        }
    }
    
    @objc func downloadTapped() {
        guard let image = NewsImg.image else {
            showSimpleAlert(title: "Error", message: "Image not available")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            showSimpleAlert(title: "Error", message: "Unable to save image")
        } else {
            showSimpleAlert(title: "Saved", message: "News image saved to Photos")
        }
    }
    
    func showSimpleAlert(title: String, message: String) {
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topVC.present(alert, animated: true)
        }
    }
}
