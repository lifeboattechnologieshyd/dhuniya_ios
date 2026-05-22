//
//  NativeAdManager.swift
//  DHUNIYA
//

import UIKit
import GoogleMobileAds

class NativeAdManager: NSObject {
    
    static let shared = NativeAdManager()
    
    private var requestQueue: [(viewController: UIViewController, completion: (NativeAd?) -> Void)] = []
    private var loadingCount = 0
    private let maxConcurrentLoads = 2
    private var currentAdLoaders: [AdLoader] = []
    
    func loadNativeAd(from viewController: UIViewController,
                      completion: @escaping (NativeAd?) -> Void) {
        
        requestQueue.append((viewController: viewController, completion: completion))
        print("📥 Ad queued. Total: \(requestQueue.count)")
        processNextRequest()
    }
    
    private func processNextRequest() {
        guard loadingCount < maxConcurrentLoads, !requestQueue.isEmpty else { return }
        
        loadingCount += 1
        let request = requestQueue.removeFirst()
        
        let adUnitID = "ca-app-pub-4345653517995764/6941447018"
        
        let videoOptions = VideoOptions()
        videoOptions.shouldStartMuted = true
        
        let mediaOptions = NativeAdMediaAdLoaderOptions()
        mediaOptions.mediaAspectRatio = .landscape
        
        let loader = AdLoader(
            adUnitID: adUnitID,
            rootViewController: request.viewController,
            adTypes: [.native],
            options: [mediaOptions, videoOptions]
        )
        
        loader.delegate = self
        currentAdLoaders.append(loader)
        
        // Store the completion handler in the loader's delegate context or a map
        // For simplicity with this delegate pattern, we'll use a wrapper
        let context = AdRequest(loader: loader, completion: request.completion)
        objc_setAssociatedObject(loader, &AssociatedKeys.requestContext, context, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        loader.load(Request())
        
        print("📢 Loading Native Ad... (Active: \(loadingCount), Queue: \(requestQueue.count))")
        
        // Try to start another if we have capacity
        processNextRequest()
    }
}

private struct AssociatedKeys {
    static var requestContext = "requestContext"
}

private class AdRequest {
    let loader: AdLoader
    let completion: (NativeAd?) -> Void
    init(loader: AdLoader, completion: @escaping (NativeAd?) -> Void) {
        self.loader = loader
        self.completion = completion
    }
}

extension NativeAdManager: NativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print("✅ Native Ad Loaded: \(nativeAd.headline ?? "N/A")")
        
        if let context = objc_getAssociatedObject(adLoader, &AssociatedKeys.requestContext) as? AdRequest {
            context.completion(nativeAd)
        }
        
        finalizeRequest(adLoader)
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("❌ Native Ad Failed: \(error.localizedDescription)")
        
        if let context = objc_getAssociatedObject(adLoader, &AssociatedKeys.requestContext) as? AdRequest {
            context.completion(nil)
        }
        
        finalizeRequest(adLoader)
    }
    
    private func finalizeRequest(_ loader: AdLoader) {
        loadingCount = max(0, loadingCount - 1)
        currentAdLoaders.removeAll(where: { $0 === loader })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.processNextRequest()
        }
    }
}
