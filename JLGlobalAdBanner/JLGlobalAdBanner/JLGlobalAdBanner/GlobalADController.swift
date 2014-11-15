//
//  GlobalADController.swift
//  Decider
//
//  Created by Jordan Lewis on 13/07/2014.
//  Copyright (c) 2014 Jordan Lewis. All rights reserved.
//

import UIKit
import Foundation
import iAd

class GlobalADController: UIViewController, ADBannerViewDelegate, GADBannerViewDelegate {
    
    let kScreenRect:CGRect = UIScreen.mainScreen().bounds
    let kScreenWidth = UIScreen.mainScreen().bounds.width
    let kScreenHeight = UIScreen.mainScreen().bounds.height
    
    let kAdBannerID = "ca-app-pub-9389217251179381/5394265753"
    
    let kAdBannerTop: CGFloat = 0
    let kAdBannerBottom: CGFloat = UIScreen.mainScreen().bounds.height-50
    
    class var sharedADController : GlobalADController {
        struct Static {
            static let sharedADController : GlobalADController = GlobalADController()
        }
        return Static.sharedADController
    }
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        // Initialization code
        println("Init Ad Controller")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("View Did Load")

        self.view.frame = CGRectMake(0, 0, kScreenWidth, 50)
        self.view.backgroundColor = kDarkColor2
        
        var moreAppsButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        moreAppsButton.frame = CGRectMake(0, 0, kScreenWidth, 50)
        moreAppsButton.backgroundColor = kDarkColor2
        moreAppsButton.setTitle("More Apps by This Developer", forState: UIControlState.Normal)
        moreAppsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        moreAppsButton.addTarget(self, action: "moreApps", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(moreAppsButton)
        
        initAds()
    }
    
    func moreApps() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.parentViewController?.presentViewController(storyboard.instantiateViewControllerWithIdentifier("MoreAppsNav") as UIViewController, animated: true, completion: nil)
    }
    
    var iAdBannerView: ADBannerView = ADBannerView(adType: ADAdType.Banner)
    var adMobBannerView:GADBannerView = GADBannerView(frame: CGRectMake(0, -50, UIScreen.mainScreen().bounds.width, 50))
    
    func initAds() {
        initiAd()
    }
    
    // BEGIN iAD
    func initiAd() {
        iAdBannerView.delegate = self
        iAdBannerView.hidden = true
        iAdBannerView.frame = CGRectMake(0, -50, kScreenWidth, 50)
        self.view.addSubview(iAdBannerView)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        println("iAd did load Ad")
        showBanner(iAdBannerView)
        hideBanner(adMobBannerView)
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        println("iAd failed to load Ad with error \(error.localizedDescription)")
        initAdMob()
        adMobBannerView.loadRequest(GADRequest())
        hideBanner(iAdBannerView)
        showBanner(adMobBannerView)
    }
    // END iAD
    
    // BEGIN Admob
    func initAdMob() {
        adMobBannerView.adUnitID = kAdBannerID
        adMobBannerView.rootViewController = self
        adMobBannerView.hidden = true
        self.view.addSubview(adMobBannerView)
    }
    
    func adViewDidReceiveAd(view: GADBannerView!)  {
        println("AdMob did load Ad")
        showBanner(adMobBannerView)
        hideBanner(iAdBannerView)
    }
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        println("AdMob failed to load Ad with error \(error.localizedDescription)")
        hideBanner(adMobBannerView)
    }
    // END Admob
    
    func showBanner(banner:UIView) {
        if banner.hidden {
            banner.hidden = false
            UIView.animateWithDuration(0.5, animations: {
                banner.frame = CGRectMake(0, 0, self.kScreenWidth, 50)
            })
        }
    }
    
    func hideBanner(banner:UIView) {
        if !banner.hidden {
            banner.hidden = true
            UIView.animateWithDuration(0.5, animations: {
                banner.frame = CGRectMake(0, -50, self.kScreenWidth, 50)
            })
        }
    }

}
