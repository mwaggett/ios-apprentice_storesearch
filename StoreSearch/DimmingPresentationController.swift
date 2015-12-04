//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Molly Waggett on 12/3/15.
//  Copyright © 2015 Molly Waggett. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  
  lazy var dimmingView = GradientView(frame: CGRect.zero)
  
  override func presentationTransitionWillBegin() {
    if let containerView = containerView {
      dimmingView.frame = containerView.bounds
      containerView.insertSubview(dimmingView, atIndex: 0)
    }
  }
  
  override func shouldRemovePresentersView() -> Bool {
    return false
  }
  
}