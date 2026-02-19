//
//  NativeAdManager.swift
//  DHUNIYA
//

import UIKit
import GoogleMobileAds

class NativeAdManager: NSObject {
    
    static let shared = NativeAdManager()
    
    private var requestQueue: [(viewController: UIViewController, completion: (NativeAd?) -> Void)] = []
    private var isLoading = false
    private var currentAdLoader: AdLoader?
    private var currentCompletion: ((NativeAd?) -> Void)?
    
    func loadNativeAd(from viewController: UIViewController,
                      completion: @escaping (NativeAd?) -> Void) {
        
        requestQueue.append((viewController: viewController, completion: completion))
        print("📥 Ad queued. Total: \(requestQueue.count)")
        processNextRequest()
    }
    
    private func processNextRequest() {
        guard !isLoading, !requestQueue.isEmpty else { return }
        
        isLoading = true
        let request = requestQueue.removeFirst()
        
        let adUnitID = "ca-app-pub-4345653517995764/6941447018"
        
        self.currentCompletion = request.completion
        
        let videoOptions = VideoOptions()
        videoOptions.shouldStartMuted = true
        
        let mediaOptions = NativeAdMediaAdLoaderOptions()
        mediaOptions.mediaAspectRatio = .landscape
        
        currentAdLoader = AdLoader(
            adUnitID: adUnitID,
            rootViewController: request.viewController,
            adTypes: [.native],
            options: [mediaOptions, videoOptions]
        )
        
        currentAdLoader?.delegate = self
        currentAdLoader?.load(Request())
        
        print("📢 Loading Native Ad... (Queue: \(requestQueue.count))")
    }
}

extension NativeAdManager: NativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print("✅ Native Ad Loaded: \(nativeAd.headline ?? "N/A")")
        
        currentCompletion?(nativeAd)
        currentCompletion = nil
        isLoading = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.processNextRequest()
        }
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("❌ Native Ad Failed: \(error.localizedDescription)")
        
        currentCompletion?(nil)
        currentCompletion = nil
        isLoading = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.processNextRequest()
        }
    }
}
