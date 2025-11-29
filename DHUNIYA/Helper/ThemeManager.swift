//
//  ThemeManager.swift
//  DHUNIYA
//
//  Created by Lifeboat on 27/11/25.
//

import Foundation
import UIKit

extension UIColor {
    func colorFromHexString (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
//        var rgbValue:UInt32 = 0
//        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
enum Theme: Int {

    case light, dark
    
    /// this is app theme color. same for both modes as of now.
    
    var themeColor: UIColor {
        switch self {
        case .light:
            return UIColor().colorFromHexString("#0280FF")
        case .dark:
            return UIColor().colorFromHexString("#0280FF")
        }
    }
    
    /// this will be used for few buttons whose bg color is near blue and text is white in light
    var actionButtonColor : UIColor {
        switch self {
        case .light:
            return UIColor().colorFromHexString("ffffff")
        case .dark:
            return UIColor().colorFromHexString("ffffff")
        }
    }
    
    /// normal text color for labels and others
    var titleTextColor: UIColor {
        switch self {
        case .light:
            return UIColor().colorFromHexString("000000")
        case .dark:
            return UIColor().colorFromHexString("ffffff")
        }
    }
    var subTitleTextColor: UIColor {
        switch self {
        case .light:
            return UIColor().colorFromHexString("000000")
        case .dark:
            return UIColor().colorFromHexString("ffffff")
        }
    }
    
    // cards boxes related color

//    var mainColor: UIColor {
//        switch self {
//        case .light:
//            return UIColor().colorFromHexString("ffffff")
//        case .dark:
//            return UIColor().colorFromHexString("121212")
//        }
//    }

    
    var screenBgColor: UIColor {
        switch self {
        case .light:
            return UIColor().colorFromHexString("F2F2F2")
        case .dark:
            return UIColor().colorFromHexString("000000")
        }
    }
    
    
    var controlBorderColor: UIColor {
        switch self {
        case .light:
            return UIColor().colorFromHexString("A7AABC")
        case .dark:
            return UIColor().colorFromHexString("A7AABC")
        }
    }
   
    
    var grayBorderColor: UIColor {
        switch self {
        case .light:
            return UIColor().colorFromHexString("9A9A9A")
        case .dark:
            return UIColor().colorFromHexString("0280FF")
        }
    }
    
    //Customizing the Navigation Bar
    var barStyle: UIBarStyle {
        switch self {
        case .light:
            return .default
        case .dark:
            return .black
        }
    }

    var navigationBackgroundImage: UIImage? {
        return self == .light ? UIImage(named: "navBackground") : nil
    }
    var likeImageName : String {
        switch self {
        case .light:
            return "like"
        case .dark:
            return "like_dark_mode"
        }
    }
    
    var saveImageName : String {
        switch self {
        case .light:
            return "saved"
        case .dark:
            return "saved_dark_mode"
        }
    }
    var shareImageName : String {
        switch self {
        case .light:
            return "share"
        case .dark:
            return "share_b"
        }
    }
    var commentImageName : String {
        switch self {
        case .light:
            return "comment"
        case .dark:
            return "comment_dark_mode"
        }
    }
    var closeImageName : String {
        switch self {
        case .light:
            return "close_b"
        case .dark:
            return "close_w"
        }
    }
    
    var tabBarBackgroundImage: UIImage? {
        return self == .light ? UIImage(named: "tabBarBackground") : nil
    }

    var backgroundColor: UIColor {
        switch self {
        case .light:
            return UIColor().colorFromHexString("ffffff")
        case .dark:
            return UIColor().colorFromHexString("121212")
        }
    }

    var whiteBackgroundColor: UIColor {
        switch self {
        case .light:
            return .white
        case .dark:
            return .white
        }
    }
  
    
//
//    var subtitleTextColor: UIColor {
//        switch self {
//        case .light:
//            return UIColor().colorFromHexString("#0280FF")
//        case .dark:
//            return UIColor().colorFromHexString("ffffff")
//        }
//    }
    
}

// Enum declaration
let SelectedThemeKey = "light"

// This will let you use a theme in the app.
class ThemeManager {

    // ThemeManager
    static func currentTheme() -> Theme {
        if let storedTheme = UserDefaults.standard.value(forKey: "APPMODE") as? String {
            if storedTheme == "LIGHT"{
                return .light
            }else{
                return .dark
            }
        } else {
            return .light
        }
    }

    static func applyTheme(theme: Theme) {
        // First persist the selected theme using NSUserDefaults.
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()

        // You get your current (selected) theme and apply the main color to the tintColor property of your application’s window.
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.backgroundColor
        
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMaskFixed")

        UITabBar.appearance().barStyle = theme.barStyle
        UITabBar.appearance().backgroundImage = theme.tabBarBackgroundImage

        let tabIndicator = UIImage(named: "tabBarSelectionIndicator")?.withRenderingMode(.alwaysTemplate)
        let tabResizableIndicator = tabIndicator?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0))
        UITabBar.appearance().selectionIndicatorImage = tabResizableIndicator

        let controlBackground = UIImage(named: "controlBackground")?.withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        let controlSelectedBackground = UIImage(named: "controlSelectedBackground")?
            .withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))

        UISegmentedControl.appearance().setBackgroundImage(controlBackground, for: .normal, barMetrics: .default)
        UISegmentedControl.appearance().setBackgroundImage(controlSelectedBackground, for: .selected, barMetrics: .default)

        UIStepper.appearance().setBackgroundImage(controlBackground, for: .normal)
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .disabled)
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .highlighted)
        UIStepper.appearance().setDecrementImage(UIImage(named: "fewerPaws"), for: .normal)
        UIStepper.appearance().setIncrementImage(UIImage(named: "morePaws"), for: .normal)

        UISlider.appearance().setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        UISlider.appearance().setMaximumTrackImage(UIImage(named: "maximumTrack")?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0.0, bottom: 0, right: 6.0)), for: .normal)
        UISlider.appearance().setMinimumTrackImage(UIImage(named: "minimumTrack")?
            .withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 6.0, bottom: 0, right: 0)), for: .normal)

        UISwitch.appearance().onTintColor = theme.backgroundColor.withAlphaComponent(0.3)
        UISwitch.appearance().thumbTintColor = theme.backgroundColor
    }
}


