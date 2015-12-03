//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Molly Waggett on 12/3/15.
//  Copyright © 2015 Molly Waggett. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  
  override func shouldRemovePresentersView() -> Bool {
    return false
  }
  
}