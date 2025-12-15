//
//  OopsVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 11/12/25.
//

import UIKit
import Lottie

class OopsVC: UIViewController {

    @IBOutlet weak var animationVw: UIView!
    @IBOutlet weak var okatbtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!

    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLottieAnimation()
    }

    func setupLottieAnimation() {
        let animation = LottieAnimation.named("error")
        animationView = LottieAnimationView(animation: animation)

        guard let animationView = animationView else { return }

        animationView.frame = animationVw.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0

        animationVw.addSubview(animationView)
        animationView.play()
    }

    @IBAction func okatbtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
