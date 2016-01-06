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
import GoogleMobileAds

enum GlobalBannerAdLocation {
    case Top
    case Bottom
}

@objc protocol GlobalAdControllerDelegate {
    optional func interstitialAdWillPresentScreen()
    optional func interstitialAdWillLeaveApplication()
    optional func interstitialAdHasFinished()
}

class GlobalADController: UIViewController, ADBannerViewDelegate, ADInterstitialAdDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    // Delegate
    private var delegate:GlobalAdControllerDelegate?
    
    // The Screen Dimensions for Portrait
    private let kScreenRect:CGRect = UIScreen.mainScreen().bounds
    private let kScreenWidth:CGFloat = UIScreen.mainScreen().bounds.width
    private let kScreenHeight:CGFloat = UIScreen.mainScreen().bounds.height
    
    // The Admob Ad Unit IDs
    private var kAdBannerID:String = "" // Sample "ca-app-pub-9389217251179381/2392084158"
    private var kAdInterstitialID:String = "" // Sample "ca-app-pub-9389217251179381/5345550554"
    
    // Ad Banners
    private var iAdBannerView: ADBannerView = ADBannerView(adType: ADAdType.Banner)
    private var adMobBannerView:GADBannerView = GADBannerView(frame: CGRectMake(0, -50, UIScreen.mainScreen().bounds.width, 50))
    
    // Interstitial Ads
    private var iAdInterstitialAd:ADInterstitialAd = ADInterstitialAd()
    private var admobInterstitialAd:GADInterstitial = GADInterstitial(adUnitID: "")
    
    // The Background Button in case Banner Ads don't load
    private let moreAppsButton: UIButton = UIButton(type: UIButtonType.Custom)
    
    // Visual Config
    private let kAdBannerTop: CGFloat = 0
    private let kAdBannerBottom: CGFloat = UIScreen.mainScreen().bounds.height-50
    private var bannerBackgroundColor:UIColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
    private var bannerTextColor:UIColor = UIColor.orangeColor()
    
    // BEGIN Initialisation Code
    class var sharedADController : GlobalADController {
        struct Static {
            static let sharedADController : GlobalADController = GlobalADController()
        }
        return Static.sharedADController
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // Initialization code
        print("Init Ad Controller", terminator: "")
        
        // Prepare the Interstitial Ad
        reloadiAdInterstitialAd(&iAdInterstitialAd)
        reloadAdmobInterstitial(&admobInterstitialAd)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View Did Load", terminator: "")
        
        self.view.frame = CGRectMake(0, 0, kScreenWidth, 50)
        self.view.backgroundColor = UIColor.blackColor()
        
        // Create the background more apps button in case banner ads do not load
        moreAppsButton.frame = CGRectMake(0, 0, kScreenWidth, 50)
        moreAppsButton.backgroundColor = bannerBackgroundColor
        moreAppsButton.setTitle("More Apps by This Developer", forState: UIControlState.Normal)
        moreAppsButton.setTitleColor(bannerTextColor, forState: UIControlState.Normal)
        moreAppsButton.addTarget(self, action: "moreApps", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(moreAppsButton)
        
        initAds()
    }
    // END Initialisation Code
    
    // BEGIN Setters
    //TODO: Test if this works
    func setDelegate(d:GlobalAdControllerDelegate) {
        delegate = d
    }
    
    func setAdBannerLocation(lc:GlobalBannerAdLocation) {
        switch (lc) {
        case .Top:
            self.view.frame.origin.y = kAdBannerTop
            break
        case .Bottom:
            self.view.frame.origin.y = kAdBannerBottom
            break
        }
    }
    
    func setAdmobBannerAdUnitID(unitID:String) {
        kAdBannerID = unitID
    }
    
    func setAdmobInterstitialAdUnitID(unitID:String) {
        kAdInterstitialID = unitID
    }
    
    func setBannerBackgroundColor(color:UIColor) {
        self.bannerBackgroundColor = color
        self.moreAppsButton.backgroundColor = color
    }
    
    func setBannerTextColor(color:UIColor) {
        self.bannerTextColor = color
        self.moreAppsButton.setTitleColor(color, forState: UIControlState.Normal)
    }
    // END Setters
    
    // BEGIN More Apps Code
    private func moreApps() {
        //let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        let moreAppsNav:UINavigationController = UINavigationController(rootViewController: DAAppsViewController())
        moreAppsNav.navigationBar.barTintColor = UIColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1)
        moreAppsNav.navigationBar.tintColor = UIColor.whiteColor()
        moreAppsNav.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName:UIColor.whiteColor(),
            //NSFontAttributeName:UIFont(name: kFontNameOpenSans, size: 21)!
        ]
        self.parentViewController?.presentViewController(moreAppsNav, animated: true, completion: nil)
        
        //NSNotificationCenter.defaultCenter().postNotificationName("GlobalAdController Show More Apps", object: nil)
        
        //self.parentViewController?.presentViewController(storyboard.instantiateViewControllerWithIdentifier("MoreAppsNav"), animated: true, completion: nil)
    }
    // END More Apps Code
    
    // BEGIN Banner Ad Code
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
        print("iAd did load Ad", terminator: "")
        showBanner(iAdBannerView)
        hideBanner(adMobBannerView)
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("iAd failed to load Ad with error \(error.localizedDescription)", terminator: "")
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
        print("AdMob did load Ad", terminator: "")
        showBanner(adMobBannerView)
        hideBanner(iAdBannerView)
    }
    
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob failed to load Ad with error \(error.localizedDescription)", terminator: "")
        hideBanner(adMobBannerView)
    }
    // END Admob
    
    // BEGIN Controlling the Banners
    private func showBanner(banner:UIView) {
        if banner.hidden {
            banner.hidden = false
            UIView.animateWithDuration(0.5, animations: {
                banner.frame = CGRectMake(0, 0, self.kScreenWidth, 50)
            })
        }
    }
    
    private func hideBanner(banner:UIView) {
        if !banner.hidden {
            banner.hidden = true
            UIView.animateWithDuration(0.5, animations: {
                banner.frame = CGRectMake(0, -50, self.kScreenWidth, 50)
            })
        }
    }
    // END Controlling the Banners
    // END Banner Ad Code
    
    // BEGIN Interstitial Ad Code
    func showInterstitialAdInViewController(vc:UIViewController) throws {
        if iAdInterstitialAd.loaded {
            iAdInterstitialAd.presentInView(vc.view)
        } else if admobInterstitialAd.isReady {
            self.interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Manual
            if !self.requestInterstitialAdPresentation() {
                if admobInterstitialAd.isReady {
                    admobInterstitialAd.presentFromRootViewController(vc)
                } else {
                    // Failed to load
                    delegate?.interstitialAdHasFinished?()
                }
            } else {
                // Failed to load
                delegate?.interstitialAdHasFinished?()
            }
        } else {
            delegate?.interstitialAdHasFinished?()
        }
    }
    
    //TODO: Test this and see if it actually reloads it
    private func reloadiAdInterstitialAd(inout interstitial:ADInterstitialAd) {
        
    }
    
    //TODO: Test this and see if it actually reloads it
    private func reloadAdmobInterstitial(inout interstitial:GADInterstitial) {
        let _interstitial = GADInterstitial(adUnitID: kAdInterstitialID);
        _interstitial.delegate = self
        _interstitial.loadRequest(GADRequest())
        interstitial = _interstitial
    }
    
    // BEGIN iAd Delegate Functions
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        delegate?.interstitialAdHasFinished?()
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) { }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) { }
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) { }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {}
    // END iAd Delegate Functions
    
    // BEGIN Admob Delegate Functions
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        // Reload the ad so that it is ready for the next presentation
        reloadAdmobInterstitial(&admobInterstitialAd)
    }
    
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {}
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {}
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        delegate?.interstitialAdHasFinished?()
    }
    
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        delegate?.interstitialAdWillLeaveApplication?()
    }
    
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        delegate?.interstitialAdWillPresentScreen?()
    }
    // END Admob Delegate Functions
    
    // END Interstitial Ad Code
}
