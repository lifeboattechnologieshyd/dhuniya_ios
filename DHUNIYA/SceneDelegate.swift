//
//  SceneDelegate.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var isNoInternetShown = false
    private var isUpdateAlertShown = false

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)

        // Load the initial view controller from Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let rootVC = storyboard.instantiateInitialViewController() {
            window?.rootViewController = rootVC
            window?.makeKeyAndVisible()
        }

        // Start network monitoring
        NetworkMonitor.shared.start { isConnected in
            DispatchQueue.main.async {
                if isConnected {
                    self.hideNoInternetScreen()
                } else {
                    self.showNoInternetScreen()
                }
            }
        }

        // Check for app update
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkForUpdate()
        }
    }

    // MARK: Root view controller helpers

    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let loginVC = storyboard.instantiateInitialViewController() {
            window?.rootViewController = loginVC
            window?.makeKeyAndVisible()
        }
    }

    private func showMainTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            window?.rootViewController = tabBarVC
            window?.makeKeyAndVisible()
        }
    }

    private func userIsLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    // MARK: No Internet

    private func showNoInternetScreen() {
        guard !isNoInternetShown else { return }
        isNoInternetShown = true

        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
        let noInternetVC = storyboard.instantiateViewController(withIdentifier: "NoInternetVC")
        noInternetVC.modalPresentationStyle = .fullScreen

        window?.rootViewController?.present(noInternetVC, animated: true)
    }

    private func hideNoInternetScreen() {
        guard isNoInternetShown else { return }
        isNoInternetShown = false

        window?.rootViewController?.dismiss(animated: true)
    }

    // MARK: Update Available Alert

    private func checkForUpdate() {
        guard !isUpdateAlertShown else { return }
        guard let bundleID = Bundle.main.bundleIdentifier else { return }

        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleID)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            guard error == nil, let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   !results.isEmpty,
                   let appStoreVersion = results.first?["version"] as? String {
                    
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                    let cleanCurrent = currentVersion.trimmingCharacters(in: .whitespaces)
                    let cleanAppStore = appStoreVersion.trimmingCharacters(in: .whitespaces)
                    
                    if self.isVersion(cleanCurrent, olderThan: cleanAppStore) {
                        DispatchQueue.main.async {
                            self.isUpdateAlertShown = true
                            self.showUpdateAlert()
                        }
                    }
                }
            } catch {
                // Silently fail - don't interrupt user experience
            }
        }.resume()
    }

    private func isVersion(_ current: String, olderThan appStore: String) -> Bool {
        guard !current.isEmpty, !appStore.isEmpty else { return false }
        
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        let appStoreComponents = appStore.split(separator: ".").compactMap { Int($0) }
        
        guard !currentComponents.isEmpty, !appStoreComponents.isEmpty else { return false }
        
        let maxLength = max(currentComponents.count, appStoreComponents.count)
        
        for i in 0..<maxLength {
            let currentValue = i < currentComponents.count ? currentComponents[i] : 0
            let appStoreValue = i < appStoreComponents.count ? appStoreComponents[i] : 0
            
            if currentValue < appStoreValue {
                return true  // Current version is older
            } else if currentValue > appStoreValue {
                return false // Current version is newer
            }
        }
        
        return false // Versions are equal
    }

    private func showUpdateAlert() {
        guard let rootVC = window?.rootViewController else { return }
        
        var topController = rootVC
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        let alert = UIAlertController(
            title: "Update Available",
            message: "A new version of the app is available. Please update to continue.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Update",
            style: .default,
            handler: { _ in
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id6478494902") {
                    UIApplication.shared.open(url)
                }
            })
        )

        alert.addAction(UIAlertAction(
            title: "Later",
            style: .cancel,
            handler: { [weak self] _ in
                self?.isUpdateAlertShown = false
            }
        ))

        topController.present(alert, animated: true)
    }

    // MARK: SceneDelegate default methods

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
