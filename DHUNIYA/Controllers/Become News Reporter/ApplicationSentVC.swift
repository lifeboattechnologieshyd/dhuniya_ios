//
//  ApplicationSentVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 04/12/25.
//

import UIKit
import Lottie

class ApplicationSentVC: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var animationVw: UIView!
    @IBOutlet weak var okayBtn: UIButton!
    
    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        playSuccessAnimation()
    }
    
    func playSuccessAnimation() {
        animationView = LottieAnimationView(name: "Success") 
        animationView?.frame = animationVw.bounds
        animationView?.contentMode = .scaleAspectFit
        animationView?.loopMode = .playOnce
        
        if let animationView = animationView {
            animationVw.addSubview(animationView)
            animationView.play()
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okayBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
