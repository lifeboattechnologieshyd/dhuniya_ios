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
    
    @IBAction func btnKnowMoreTapped(_ sender: UIButton) {
        if let parentVC = self.parentViewController() {
            let storyboard = UIStoryboard(name: "Refer&Earn", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ReferAndEarnVC") as? ReferAndEarnVC {
                parentVC.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @IBAction func btnEditReferralCodeTapped(_ sender: UIButton) {
        if let parentVC = self.parentViewController() {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "EditReferalCodeVC") as? EditReferalCodeVC {
                parentVC.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }


}
