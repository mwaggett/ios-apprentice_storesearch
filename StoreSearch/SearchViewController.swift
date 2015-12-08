//
//  ViewController.swift
//  StoreSearch
//
//  Created by Molly Waggett on 12/2/15.
//  Copyright © 2015 Molly Waggett. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  
  weak var splitViewDetail: DetailViewController?
  var landscapeViewController: LandscapeViewController?
  
  var search = Search()
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var tableView: UITableView!
  
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = NSLocalizedString("Search", comment: "Split-view master button")
    
    if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
      searchBar.becomeFirstResponder()
    }
    
    tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
    
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    
    tableView.rowHeight = 80
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowDetail" {
      if case .Results(let list) = search.state {
        let detailViewController = segue.destinationViewController as! DetailViewController
        let indexPath = sender as! NSIndexPath
        let searchResult = list[indexPath.row]
        detailViewController.searchResult = searchResult
        detailViewController.isPopUp = true
      }
    }
  }
  
  override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    
    let rect = UIScreen.mainScreen().bounds
    if (rect.width == 736 && rect.height == 414) || (rect.width == 414 && rect.height == 736) {
      if presentedViewController != nil {
        dismissViewControllerAnimated(true, completion: nil)
      }
    } else if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
      switch newCollection.verticalSizeClass {
      case .Compact:
        showLandscapeViewWithCoordinator(coordinator)
      case .Regular, .Unspecified:
        hideLandscapeViewWithCoordinator(coordinator)
      }
    }
  }

  @IBAction func segmentChanged(sender: UISegmentedControl) {
    performSearch()
  }
  
  func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
    precondition(landscapeViewController == nil)
    landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
    if let controller = landscapeViewController {
      controller.search = search
      controller.view.frame = view.bounds
      controller.view.alpha = 0
      view.addSubview(controller.view)
      addChildViewController(controller)
      coordinator.animateAlongsideTransition({ _ in
        controller.view.alpha = 1
        self.searchBar.resignFirstResponder()
        if self.presentedViewController != nil {
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      }, completion: { _ in
          controller.didMoveToParentViewController(self)
      })
    }
  }
  
  func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
    if let controller = landscapeViewController {
      controller.willMoveToParentViewController(nil)
      coordinator.animateAlongsideTransition({ _ in
        if self.presentedViewController != nil {
          self.dismissViewControllerAnimated(true, completion: nil)
        }
        controller.view.alpha = 0
      }, completion: { _ in
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        self.landscapeViewController = nil
      })
    }
  }
  
  func hideMasterPane() {
    UIView.animateWithDuration(0.25, animations: {
      self.splitViewController!.preferredDisplayMode = .PrimaryHidden
    }, completion: { _ in
      self.splitViewController!.preferredDisplayMode = .Automatic
    })
  }
  
  func showNetworkError() {
    let alert = UIAlertController(
      title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
      message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"),
      preferredStyle: .Alert)
    let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Error alert: button"), style: .Default, handler: nil)
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
  }
}

// SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    performSearch()
  }
  
  func performSearch() {
    if let searchText = searchBar.text, category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
      search.performSearchForText(searchText, category: category, completion: { success in
        if !success {
          self.showNetworkError()
        }
        self.landscapeViewController?.searchResultsReceived()
        self.tableView.reloadData()
      })
      tableView.reloadData()
      searchBar.resignFirstResponder()
    }
  }
}

// TableViewDataSource
extension SearchViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch search.state {
      case .NotSearchedYet:
        return 0
      case .Loading:
        return 1
      case .NoResults:
        return 1
      case .Results(let list):
        return list.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch search.state {
    case .NotSearchedYet:
      fatalError("Should never get here")
    case .Loading:
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    case .NoResults:
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
    case .Results(let list):
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
      let searchResult = list[indexPath.row]
      cell.configureForSearchResult(searchResult)
      return cell
    }
  }
}

// TableViewDelegate
extension SearchViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    switch search.state {
      case .NotSearchedYet, .Loading, .NoResults:
        return nil
      case .Results:
        return indexPath
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    searchBar.resignFirstResponder()
    if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .Compact {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      performSegueWithIdentifier("ShowDetail", sender: indexPath)
    } else {
      if case .Results(let list) = search.state {
        if splitViewController!.displayMode != .AllVisible {
          hideMasterPane()
        }
        splitViewDetail?.searchResult = list[indexPath.row]
      }
    }
  }
  
}

