//
//  Extensions.swift
//  DHUNIYA
//
//  Created by Lifeboat on 22/11/25.
//

import UIKit
import Kingfisher
import ObjectiveC


struct FontManager {

    // MARK: Telugu
    static func teluguTitle(_ size: CGFloat) -> UIFont {
        return UIFont(
            name: "NotoSansTeluguCondensed-Medium",
            size: size
        ) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func teluguBody(_ size: CGFloat) -> UIFont {
        return UIFont(
            name: "NotoSansTeluguCondensed-Regular",
            size: size
        ) ?? UIFont.systemFont(ofSize: size)
    }

    // MARK:  English
    static func englishTitle(_ size: CGFloat) -> UIFont {
        return UIFont(
            name: "Lexend-Medium",
            size: size
        ) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func englishBody(_ size: CGFloat) -> UIFont {
        return UIFont(
            name: "Lexend-Regular",
            size: size
        ) ?? UIFont.systemFont(ofSize: size)
    }
}

// MARK:UIView extensions
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

            // make sure layout is up to date
            layoutIfNeeded()

            // remove any existing border
            layer.sublayers?
                .filter { $0.name == "dotted-border" }
                .forEach { $0.removeFromSuperlayer() }

            let shapeLayer = CAShapeLayer()
            shapeLayer.name = "dotted-border"
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.lineDashPattern = [6, 3]
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 1.5

            // IMPORTANT: draw inside the bounds so it doesn't cut
            let rect = bounds.insetBy(dx: shapeLayer.lineWidth / 2,
                                      dy: shapeLayer.lineWidth / 2)
            shapeLayer.frame = bounds
            shapeLayer.path = UIBezierPath(
                roundedRect: rect,
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


// MARK:  UIViewController extension
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
    /// Call this in `viewDidLoad()` of any VC where you want the profile image to update
    func setupProfileImageObserver(imageView: UIImageView) {
        // Set initial image
        imageView.image = Session.shared.profileImage
        
        // Listen for updates
        NotificationCenter.default.addObserver(forName: Notification.Name("ProfileImageUpdated"), object: nil, queue: .main) { _ in
            imageView.image = Session.shared.profileImage
        }
    }
}


// MARK:  Date extension
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

// MARK:  UIImageView extension
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
        // Shorts URL
        if let url = URL(string: self), url.absoluteString.contains("youtube.com/shorts") {
            return url.lastPathComponent
        }
        
        // Normal youtube URL
        let pattern = "(?<=v=)[^&]+|(?<=be/)[^?&]+|(?<=embed/)[^?&]+"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let nsString = self as NSString
            if let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: nsString.length)) {
                return nsString.substring(with: match.range)
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
extension UITableView {

    func setCellSpacing(_ height: CGFloat) {
        self.sectionHeaderHeight = height
        self.sectionFooterHeight = height
        self.separatorStyle = .none
    }
}

extension UILabel {
    func setupLineSpacing(lineSpace : CGFloat, font: UIFont =  CustomFonts.LSB18.font) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        let attributedString = NSMutableAttributedString(string: self.text ?? "")
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}
extension UITextView {

    func setupLineSpacing(lineSpace: CGFloat,
                          font: UIFont = CustomFonts.LR16.font) {

        guard let text = self.text, !text.isEmpty else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes([
            .paragraphStyle: paragraphStyle,
            .font: font
        ], range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
}

enum CustomFonts : String {
    
    case LB12, LB14, LB16, LB18, LB20, LB24, LB100,
         LR12, LR14, LR16,LR18,
         LEL12,LEL16, LEL14,
         LL12, LL14,LL16,
         LM12, LM16, LM14,
         LSB12,LSB14,LSB16, LSB18,LSB20, LSB24

    var font: UIFont {
        switch self {
        case .LB12:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Bold", size: 12)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Bold", size: 12)!
        case .LB14:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Bold", size: 14)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Bold", size: 14)!

        case .LB16:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Bold", size: 16)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Bold", size: 16)!

        case .LB18:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Bold", size: 18)!

            }
            return UIFont(name: "NotoSansTeluguCondensed-Bold", size: 18)!

        case .LB20:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Bold", size: 20)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Bold", size: 20)!

        case .LB24:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Bold", size: 24)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Bold", size: 24)!
        case .LB100:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Bold", size: 100)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Bold", size: 100)!
        case .LR12:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Regular", size: 12)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Regular", size: 12)!

            
        case .LR14:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Regular", size: 14)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Regular", size: 14)!

        case .LR16:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Regular", size: 16)!
            }
            return UIFont(name: "Lexend-Regular", size: 16)!

//            return UIFont(name: "NotoSansTeluguCondensed-Regular", size: 16)!

        case .LR18:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Regular", size: 18)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Regular", size: 18)!

        case .LEL12:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-ExtraLight", size: 12)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-ExtraLight", size: 12)!

        case .LEL14:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-ExtraLight", size: 14)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-ExtraLight", size: 14)!

        case .LEL16:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-ExtraLight", size: 16)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-ExtraLight", size: 16)!

        case .LL12:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Light", size: 12)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Light", size: 12)!

        case .LL14:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Light", size: 14)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Light", size: 14)!

        case .LL16:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Light", size: 16)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Light", size: 16)!

        case .LM12:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Medium", size: 12)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Medium", size: 12)!

        case .LM16:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Medium", size: 16)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Medium", size: 16)!

        case .LM14:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-Medium", size: 14)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-Medium", size: 14)!

        case .LSB12:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-SemiBold", size: 12)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-SemiBold", size: 12)!
        case .LSB14:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-SemiBold", size: 14)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-SemiBold", size: 14)!
            
        case .LSB16:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-SemiBold", size: 16)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-SemiBold", size: 16)!

        case .LSB18:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-SemiBold", size: 18)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-SemiBold", size: 18)!

        case .LSB20:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-SemiBold", size: 20)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-SemiBold", size: 20)!

        case .LSB24:
            if Session.shared.news_language == "en" {
                return UIFont(name: "Lexend-SemiBold", size: 24)!
            }
            return UIFont(name: "NotoSansTeluguCondensed-SemiBold", size: 24)!
        }
    }
}



extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
extension SubmitNewsCell {
    func presentVC(_ viewController: UIViewController, from parentVC: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = .push
        transition.subtype = .fromRight
        parentVC.view.window?.layer.add(transition, forKey: kCATransition)

        viewController.modalPresentationStyle = .fullScreen
        parentVC.present(viewController, animated: false)
    }
}
import Network

class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    private init() {}

    func start(_ handler: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                handler(true)
            } else {
                handler(false)
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }
}
private var lastClickTimeKey: Void?

extension UIButton {
    private var lastClickTime: TimeInterval {
        get { return objc_getAssociatedObject(self, &lastClickTimeKey) as? TimeInterval ?? 0 }
        set { objc_setAssociatedObject(self, &lastClickTimeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Add debounce action to button
    func addDebouncedAction(interval: TimeInterval = 0.5, action: @escaping () -> Void) {
        self.addTargetClosure { [weak self] in
            guard let self = self else { return }
            let now = Date().timeIntervalSince1970
            if now - self.lastClickTime > interval {
                self.lastClickTime = now
                action()
            }
        }
    }
}

// MARK: UIControl Closure Extension

private var actionKey: Void?

extension UIControl {
    func addTargetClosure(closure: @escaping () -> Void) {
        objc_setAssociatedObject(self, &actionKey, closure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(handleAction), for: .touchUpInside)
    }

    @objc private func handleAction() {
        if let closure = objc_getAssociatedObject(self, &actionKey) as? () -> Void {
            closure()
        }
    }
}
