//
//  WebViewVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 27/11/25.
//

import UIKit
import WebKit

class WebViewViewController: BaseViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var webView: WKWebView!
    var url : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        
        var link = ""
        self.topView.backgroundColor = ThemeManager.currentTheme().backgroundColor
        if let urlString = url {
            link = urlString
        }else{
            link = "https://web.dhuniya.in/terms.html"
        }
        let request = URLRequest(url: URL(string: link)!)
        webView.load(request)
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
