//
//  NoInternetVC.swift
//  DHUNIYA
//
//  Created by Lifeboat on 11/12/25.
//

import UIKit
import Lottie

class NoInternetVC: UIViewController {

    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var animationVw: UIView!
    @IBOutlet weak var backBtn: UIButton!

    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLottieAnimation()
    }

    func setupLottieAnimation() {
        let animation = LottieAnimation.named("NoInternet")
        animationView = LottieAnimationView(animation: animation)

        guard let animationView = animationView else { return }

        animationView.frame = animationVw.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0

        animationVw.addSubview(animationView)
        animationView.play()
    }

    @IBAction func retryBtnTapped(_ sender: UIButton) {
        // your retry logic here
    }

    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
