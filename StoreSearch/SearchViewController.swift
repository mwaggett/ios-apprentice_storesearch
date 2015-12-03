//
//  ViewController.swift
//  StoreSearch
//
//  Created by Molly Waggett on 12/2/15.
//  Copyright © 2015 Molly Waggett. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  
  var searchResults = [SearchResult]()
  var hasSearched = false
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

// SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    hasSearched = true
    searchResults = [SearchResult]()
    for i in 0...2 {
      if let searchText = searchBar.text {
        let searchResult = SearchResult()
        searchResult.name = String(format: "Fake Result %d for", i)
        searchResult.artistName = searchText
        searchResults.append(searchResult)
      }
    }
    tableView.reloadData()
  }
}

// TableViewDataSource
extension SearchViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cellIdentifier = "SearchResultCell"
    var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
    }
    
    if searchResults.count == 0 {
      cell!.textLabel?.text = "(Nothing found)"
      cell!.detailTextLabel?.text = ""
    } else {
      let searchResult = searchResults[indexPath.row]
      cell!.textLabel?.text = searchResult.name
      cell!.detailTextLabel?.text = searchResult.artistName
    }
    return cell!
  }
}

// TableViewDelegate
extension SearchViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if searchResults.count == 0 {
      return nil
    } else {
      return indexPath
    }
  }
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

