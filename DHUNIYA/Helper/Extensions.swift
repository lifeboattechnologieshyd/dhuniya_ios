//
//  Extensions.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit
import Kingfisher

// MARK: - UIView extensions
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
    
    // Shadow properties
    @IBInspectable var shadowColor: UIColor? {
        get { layer.shadowColor.flatMap { UIColor(cgColor: $0) } }
        set { layer.shadowColor = newValue?.cgColor }
    }
    @IBInspectable var shadowOpacity: Float {
        get { layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    @IBInspectable var shadowRadius: CGFloat {
        get { layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    @IBInspectable var shadowOffset: CGSize {
        get { layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    func addDottedBorder(color: UIColor = .lightGray, cornerRadius: CGFloat = 10) {
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
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: CGRect(
            x: 0,
            y: bounds.height - shadowHeight,
            width: bounds.width,
            height: shadowHeight
        )).cgPath
    }
    
    func applyBlur(intensity: CGFloat = 0.25) {
        removeBlur()
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = intensity
        blurView.tag = 999
        addSubview(blurView)
    }
    func removeBlur() {
        // Remove all UIVisualEffectView subviews
        subviews
            .filter { $0 is UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }
    }

    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let vc = parentResponder as? UIViewController {
                return vc
            }
        }
        return nil
    }
}



// MARK: - UIViewController extension
extension UIViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSafeAlert(message: String) {
        if let presented = presentedViewController as? UIAlertController {
            presented.dismiss(animated: false)
        }
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func dismissAllPresented(animated: Bool = false, completion: (() -> Void)? = nil) {
        var rootVC = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        while let presented = rootVC?.presentedViewController {
            rootVC = presented
        }
        rootVC?.presentingViewController?.dismiss(animated: animated, completion: completion)
    }
}

// MARK: - Date extension
extension Date {
    func timeAgo() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60, hour = 3600, day = 86400, week = 604800
        
        if secondsAgo < minute { return "\(secondsAgo) sec ago" }
        else if secondsAgo < hour { return "\(secondsAgo / minute) min ago" }
        else if secondsAgo < day { return "\(secondsAgo / hour) hours ago" }
        else if secondsAgo < week { return "\(secondsAgo / day) days ago" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: self)
    }
}

// MARK: - UIImageView extension
extension UIImageView {
    func setKFImage(_ urlString: String?, placeholder: UIImage? = UIImage(named: "news_placeholder")) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.3)), .cacheOriginalImage]
        )
    }
}
extension String {
    
    func extractYoutubeId() -> String? {
        if let url = URL(string: self) {
            if url.absoluteString.contains("youtube.com/shorts") {
                return url.lastPathComponent
            }
        }
        return nil
    }
    func youtubeThumbnailURL(quality: String = "hqdefault") -> String {
        "https://img.youtube.com/vi/\(self)/\(quality).jpg"
    }
    
}
extension UIImageView {
    
    
    func loadImage(url: String, placeHolderImage: String = "SchoolFirst") {
        guard let url = URL(string: url) else {
            self.image = UIImage(named: placeHolderImage)
            return
        }
        
        DispatchQueue.main.async {
            let size = self.bounds.size
            
            let finalSize = (size.width > 0 && size.height > 0)
            ? size
            : CGSize(width: UIScreen.main.bounds.width / 3,
                     height: UIScreen.main.bounds.width / 3)
            
            let processor = DownsamplingImageProcessor(size: finalSize)
            
            self.kf.indicatorType = .activity
            
            self.kf.setImage(
                with: url,
                placeholder: UIImage(named: placeHolderImage),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2)),
                    .cacheOriginalImage,
                    .memoryCacheExpiration(.days(21)),
                    .diskCacheExpiration(.days(30))
                ]
            )
        }
    }
}
