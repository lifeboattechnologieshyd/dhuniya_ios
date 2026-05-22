//
//  MainTabBarController.swift
//  DHUNIYA
//
//  Created by Lifeboat on 09/04/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom initialization for the tab bar
        setupTabBar()
    }
    
    private func setupTabBar() {
        // Set tab bar appearance (optional)
        tabBar.backgroundColor = .white
        tabBar.tintColor = .systemBlue
    }
}
