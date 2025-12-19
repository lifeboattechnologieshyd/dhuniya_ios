//
//  EditReferalCode.swift
//  DHUNIYA
//
//  Created by Lifeboat on 27/11/25.
//
import UIKit

class EditReferalCodeVC: UIViewController {
    
    @IBOutlet weak var referalcodeVW: UIView!
    @IBOutlet weak var CodeTf: UITextField!
    @IBOutlet weak var comfirmButton: UIButton!
    @IBOutlet weak var referalRules: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Pre-fill with current referral code
        CodeTf.text = Session.shared.userDetails?.referral_code
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func comfirmButtonTapped(_ sender: UIButton) {
        guard let newCode = CodeTf.text, !newCode.isEmpty else { return }
        
        guard let url = URL(string: API.GET_REFERRALS) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"  // PUT is correct for updating referral
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Session.shared.accesstoken)", forHTTPHeaderField: "Authorization")
        
        let body = ["referral_code": newCode]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let _ = data, error == nil {
                    // Update local session
                    if var user = Session.shared.userDetails {
                        user.referral_code = newCode
                        Session.shared.userDetails = user
                    }
                    
                    // Notify observers that referral code changed
                    NotificationCenter.default.post(name: Notification.Name("ReferralCodeUpdated"), object: nil)
                    
                    self.dismiss(animated: true)
                } else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: error?.localizedDescription ?? "Failed to update",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }.resume()
    }
}
