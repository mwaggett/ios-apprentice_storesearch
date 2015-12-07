//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Molly Waggett on 12/3/15.
//  Copyright © 2015 Molly Waggett. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
  var isPopUp = false
  var searchResult: SearchResult! {
    didSet {
      if isViewLoaded() {
        updateUI(searchResult)
      }
    }
  }
  var downloadTask: NSURLSessionDownloadTask?
  
  enum AnimationStyle {
    case Slide
    case Fade
  }
  var dismissAnimationStyle = AnimationStyle.Fade
  
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var priceButton: UIButton!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .Custom
    transitioningDelegate = self
  }
  
  deinit {
    print("deinit \(self)")
    downloadTask?.cancel()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    popupView.layer.cornerRadius = 10      
    if let result = searchResult {
      updateUI(result)
    }
    if isPopUp {
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("close"))
      gestureRecognizer.cancelsTouchesInView = false
      gestureRecognizer.delegate = self
      view.addGestureRecognizer(gestureRecognizer)
      view.backgroundColor = UIColor.clearColor()
    } else {
      if let backgroundImage = UIImage(named: "LandscapeBackground") {
        view.backgroundColor = UIColor(patternImage: backgroundImage)
      }
      popupView.hidden = true
      if let displayName = NSBundle.mainBundle().localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        title = displayName
      }
    }

  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  @IBAction func openInStore() {
    if let result = searchResult {
      if let url = NSURL(string: result.storeURL) {
        UIApplication.sharedApplication().openURL(url)
      }
    }
  }
  
  @IBAction func close() {
    dismissAnimationStyle = .Slide
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func updateUI(searchResult: SearchResult) {
    nameLabel.text = searchResult.name
    if searchResult.artistName.isEmpty {
      artistNameLabel.text = NSLocalizedString("Unknown", comment: "Artist name not found")
    } else {
      artistNameLabel.text = searchResult.artistName
    }
    kindLabel.text = searchResult.kindForDisplay()
    genreLabel.text = searchResult.genre
    
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.currencyCode = searchResult.currency    
    let priceText: String
    if searchResult.price == 0 {
      priceText = NSLocalizedString("Free", comment: "Price is 0")
    } else if let text = formatter.stringFromNumber(searchResult.price) {
      priceText = text
    } else {
      priceText = ""
    }
    priceButton.setTitle(priceText, forState: .Normal)
    
    if let url = NSURL(string: searchResult.artworkURL100) {
      downloadTask = artworkImageView.loadImageWithURL(url)
    }
    popupView.hidden = false
  }

}

extension DetailViewController: UIViewControllerTransitioningDelegate {
  
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
  }
    
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }
    
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    switch dismissAnimationStyle {
      case .Slide:
        return SlideOutAnimationController()
      case .Fade:
        return FadeOutAnimationController()
    }
  }
}

extension DetailViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    return touch.view === self.view
  }
      
}
