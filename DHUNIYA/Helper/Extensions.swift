//
//  Extensions.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit

extension UIView {
    
    // Corner Radius
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    // Border Width
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    // Border Color
    @IBInspectable var borderColor: UIColor? {
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    // Shadow Color
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let cgColor = layer.shadowColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set { layer.shadowColor = newValue?.cgColor }
    }
    
    // Shadow Opacity
    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    
    // Shadow Radius
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    // Shadow Offset
    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    func addDottedBorder(color: UIColor = .lightGray, cornerRadius: CGFloat = 10) {
        
        // Remove old dotted layers to avoid duplicates
        self.layer.sublayers?
            .filter { $0.name == "dotted-border" }
            .forEach { $0.removeFromSuperlayer() }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "dotted-border"
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineDashPattern = [6, 3]
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.frame = bounds
        
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
        
        layer.addSublayer(shapeLayer)
    }
    func addBottomShadow(color: UIColor = .black,
                         opacity: Float = 0.15,
                         radius: CGFloat = 6,
                         shadowHeight: CGFloat = 4) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        self.layer.shadowRadius = radius
        
        // improves performance
        self.layer.shadowPath = UIBezierPath(rect: CGRect(
            x: 0,
            y: self.bounds.height - shadowHeight,
            width: self.bounds.width,
            height: shadowHeight
        )).cgPath
    }
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let vc = parentResponder as? UIViewController {
                return vc
            }
        }
        return nil
    }
    
    //  Add soft blur
    func applyBlur(intensity: CGFloat = 0.25) {
        removeBlur()  // avoid stacking blurs
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = intensity   // adjust blur amount
        blurView.tag = 999           // identifier for removing
        addSubview(blurView)
    }
    
    // Remove blur
    func removeBlur() {
        viewWithTag(999)?.removeFromSuperview()
    }
}




 

extension UIViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
    
extension Date {
    func timeAgo() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))

        let minute = 60
        let hour = 3600
        let day = 86400
        let week = 604800

        if secondsAgo < minute {
            return "\(secondsAgo) sec ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) min ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: self)
    }
}



