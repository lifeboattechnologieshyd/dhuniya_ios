//
//  FeelsPageViewController.swift
//  DHUNIYA
//
//  Created by AI on 18/04/26.
//

import UIKit

class FeelsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var items: [FeelItem] = []
    var currentIndex: Int = 0
    
    // We could pre-load or lazily load controllers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.view.backgroundColor = .black
        
        // Hide navigation bar for true full screen
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if items.count > 0 && currentIndex < items.count {
            let initialVC = viewControllerAtIndex(currentIndex)
            setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController {
        let stbd = UIStoryboard(name: "Feels", bundle: nil)
        let vc = stbd.instantiateViewController(identifier: "FeelPlayerController") as! FeelPlayerController
        vc.selected_feel_item = items[index]
        vc.pageIndex = index
        return vc
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? FeelPlayerController,
              let index = vc.pageIndex else { return nil }
        
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        
        return viewControllerAtIndex(previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? FeelPlayerController,
              let index = vc.pageIndex else { return nil }
        
        let nextIndex = index + 1
        guard nextIndex < items.count else { return nil }
        
        return viewControllerAtIndex(nextIndex)
    }
}
