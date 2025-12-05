//
//  RefferAndEarnCell.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//
import UIKit

class RefferAndEarnCell: UITableViewCell {
    
    @IBOutlet weak var btnEditReferralCode: UIButton!
    @IBOutlet weak var btnShareApp: UIButton!
    @IBOutlet weak var lblreferalCode: UILabel!
    @IBOutlet weak var referCodeView: UIView!
    @IBOutlet weak var btnInsta: UIButton!
    @IBOutlet weak var btnWhatsApp: UIButton!
    @IBOutlet weak var btnTelegram: UIButton!
    @IBOutlet weak var btnFb: UIButton!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var shareAppTitle: UILabel!
    @IBOutlet weak var viewShareApp: UIView!
    @IBOutlet weak var btnKnowMore: UIButton!
    @IBOutlet weak var lblReferralCodeText: UILabel!
    @IBOutlet weak var refferView: UIView!
    @IBOutlet weak var lblRefferText: UILabel!
    @IBOutlet weak var referalCodeBlurView: UIView!
    
    var referrals: [ReferralUser] = [] {
        didSet {
            lblRefferText.text = referrals.isEmpty ? "No referrals yet" : "You have \(referrals.count) referrals"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Listen for referral code updates
        NotificationCenter.default.addObserver(self, selector: #selector(referralCodeUpdated), name: Notification.Name("ReferralCodeUpdated"), object: nil)
        
        btnWhatsApp.addTarget(self, action: #selector(shareViaWhatsApp), for: .touchUpInside)
        btnTelegram.addTarget(self, action: #selector(shareViaTelegram), for: .touchUpInside)
        btnFb.addTarget(self, action: #selector(shareViaFacebook), for: .touchUpInside)
        btnInsta.addTarget(self, action: #selector(shareViaInstagram), for: .touchUpInside)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addDottedBorder()
    }
    
    func addDottedBorder() {
        referCodeView.layer.sublayers?.removeAll(where: { $0.name == "dottedBorder" })
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "dottedBorder"
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineDashPattern = [6, 3]
        shapeLayer.fillColor = nil
        shapeLayer.frame = referCodeView.bounds
        shapeLayer.path = UIBezierPath(roundedRect: referCodeView.bounds, cornerRadius: 8).cgPath
        referCodeView.layer.addSublayer(shapeLayer)
    }
    
    func configure() {
        updateReferralCode()
        btnEditReferralCode.isHidden = !(Session.shared.userDetails?.can_change_referral_code ?? false)
        lblRefferText.text = referrals.isEmpty ? "No referrals yet" : "You have \(referrals.count) referrals"
    }
    
    private func updateReferralCode() {
        if let code = Session.shared.userDetails?.referral_code, !code.isEmpty {
            lblreferalCode.text = code
            referalCodeBlurView.isHidden = true
        } else {
            lblreferalCode.text = ""
            referalCodeBlurView.isHidden = false
        }
    }
    
    @objc private func referralCodeUpdated() {
        updateReferralCode()
    }
    
    @IBAction func btnKnowMoreTapped(_ sender: UIButton) {
        if let parentVC = self.parentViewController() {
            let storyboard = UIStoryboard(name: "Refer&Earn", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ReferAndEarnVC") as? ReferAndEarnVC {
                parentVC.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func btnEditReferralCodeTapped(_ sender: UIButton) {
        guard let parentVC = self.parentViewController() else { return }
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditReferalCodeVC") as? EditReferalCodeVC {
            editVC.modalPresentationStyle = .overFullScreen
            parentVC.present(editVC, animated: true)
        }
    }
    
    private func referralShareText() -> String {
        let code = Session.shared.userDetails?.referral_code ?? ""
        return "Join the app using my referral code: \(code) and get benefits!"
    }
    
    @objc private func shareViaWhatsApp() {
        openURLScheme("whatsapp://send?text=\(referralShareText().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")", appName: "WhatsApp")
    }
    
    @objc private func shareViaTelegram() {
        openURLScheme("tg://msg?text=\(referralShareText().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")", appName: "Telegram")
    }
    
    @objc private func shareViaFacebook() {
        openURLScheme("fb-messenger://share?link=\(referralShareText().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")", appName: "Facebook")
    }
    
    @objc private func shareViaInstagram() {
        openURLScheme("instagram://share?text=\(referralShareText().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")", appName: "Instagram")
    }
    
    private func openURLScheme(_ urlString: String, appName: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let parentVC = self.parentViewController() {
            let alert = UIAlertController(title: "\(appName) Not Installed", message: "Please install \(appName) to share the referral.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            parentVC.present(alert, animated: true)
        }
    }
    
}
