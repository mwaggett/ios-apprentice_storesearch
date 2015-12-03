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
  var isLoading = false
  var dataTask: NSURLSessionDataTask?
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.becomeFirstResponder()
    
    tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    
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

  func urlWithSearchText(searchText: String) -> NSURL? {
    let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
    let url = NSURL(string: urlString)
    return url
  }
  
  func parseJSON(data: NSData) -> [String: AnyObject]? {
    do {
      return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
    } catch {
      print("JSON Error: \(error)")
      return nil
    }
  }
  
  func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
    guard let array = dictionary["results"] as? [AnyObject] else {
      print("Expected 'results' array")
      return []
    }
    var searchResults = [SearchResult]()
    for resultDict in array {
      if let resultDict = resultDict as? [String: AnyObject] {
        var searchResult: SearchResult?
        if let wrapperType = resultDict["wrapperType"] as? String {
          switch wrapperType {
            case "track":
              searchResult = parseTrack(resultDict)
            case "audiobook":
              searchResult = parseAudioBook(resultDict)
            case "software":
              searchResult = parseSoftware(resultDict)
            default:
              break
          }
        } else if let kind = resultDict["kind"] as? String where kind == "ebook" {
          searchResult = parseEBook(resultDict)
        }
        
        if let result = searchResult {
          searchResults.append(result)
        }
      }
    }
    return searchResults
  }
  
  func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    if let name = dictionary["trackName"] as? String {
      searchResult.name = name
    }
    if let artistName = dictionary["artistName"] as? String {
      searchResult.artistName = artistName
    }
    if let artworkURL60 = dictionary["artworkUrl60"] as? String {
      searchResult.artworkURL60 = artworkURL60
    }
    if let artworkURL100 = dictionary["artworkUrl100"] as? String {
      searchResult.artworkURL100 = artworkURL100
    }
    if let storeURL = dictionary["trackViewUrl"] as? String {
      searchResult.storeURL = storeURL
    }
    if let kind = dictionary["kind"] as? String {
      searchResult.kind = kind
    }
    if let currency = dictionary["currency"] as? String {
      searchResult.currency = currency
    }
    if let price = dictionary["trackPrice"] as? Double {
      searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
      searchResult.genre = genre
    }
    return searchResult
  }
  
  func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    if let name = dictionary["collectionName"] as? String {
      searchResult.name = name
    }
    if let artistName = dictionary["artistName"] as? String {
      searchResult.artistName = artistName
    }
    if let artworkURL60 = dictionary["artworkUrl60"] as? String {
      searchResult.artworkURL60 = artworkURL60
    }
    if let artworkURL100 = dictionary["artworkUrl100"] as? String {
      searchResult.artworkURL100 = artworkURL100
    }
    if let storeURL = dictionary["collectionViewUrl"] as? String {
      searchResult.storeURL = storeURL
    }
    searchResult.kind = "audiobook"
    if let currency = dictionary["currency"] as? String {
      searchResult.currency = currency
    }
    if let price = dictionary["collectionPrice"] as? Double {
      searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
      searchResult.genre = genre
    }
    return searchResult
  }
  
  func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    if let name = dictionary["trackName"] as? String {
      searchResult.name = name
    }
    if let artistName = dictionary["artistName"] as? String {
      searchResult.artistName = artistName
    }
    if let artworkURL60 = dictionary["artworkUrl60"] as? String {
      searchResult.artworkURL60 = artworkURL60
    }
    if let artworkURL100 = dictionary["artworkUrl100"] as? String {
      searchResult.artworkURL100 = artworkURL100
    }
    if let storeURL = dictionary["trackViewUrl"] as? String {
      searchResult.storeURL = storeURL
    }
    if let kind = dictionary["kind"] as? String {
      searchResult.kind = kind
    }
    if let currency = dictionary["currency"] as? String {
      searchResult.currency = currency
    }
    if let price = dictionary["price"] as? Double {
      searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
      searchResult.genre = genre
    }
    return searchResult
  }
  
  func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    if let name = dictionary["trackName"] as? String {
      searchResult.name = name
    }
    if let artistName = dictionary["artistName"] as? String {
      searchResult.artistName = artistName
    }
    if let artworkURL60 = dictionary["artworkUrl60"] as? String {
      searchResult.artworkURL60 = artworkURL60
    }
    if let artworkURL100 = dictionary["artworkUrl100"] as? String {
      searchResult.artworkURL100 = artworkURL100
    }
    if let storeURL = dictionary["trackViewUrl"] as? String {
      searchResult.storeURL = storeURL
    }
    if let kind = dictionary["kind"] as? String {
      searchResult.kind = kind
    }
    if let currency = dictionary["currency"] as? String {
      searchResult.currency = currency
    }
    if let price = dictionary["trackPrice"] as? Double {
      searchResult.price = price
    }
    if let genres: AnyObject = dictionary["genres"] {
      searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
    }
    return searchResult
  }
  
  func kindForDisplay(kind: String) -> String {
    switch kind {
      case "album": return "Album"
      case "audiobook": return "Audio Book"
      case "book": return "Book"
      case "ebook": return "E-Book"
      case "feature-movie": return "Movie" case "music-video": return "Music Video" case "podcast": return "Podcast"
      case "software": return "App"
      case "song": return "Song"
      case "tv-episode": return "TV Episode"
      default: return kind
    }
  }
  
  func showNetworkError() {
    let alert = UIAlertController(
      title: "Whoops...",
      message: "There was an error reading from the iTunes Store. Please try again.",
      preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
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
    if let searchText = searchBar.text {
      if !searchText.isEmpty {
        searchBar.resignFirstResponder()
        dataTask?.cancel()
        isLoading = true
        tableView.reloadData()
        hasSearched = true
        searchResults = [SearchResult]()
  
        if let url = urlWithSearchText(searchText) {
          let session = NSURLSession.sharedSession()
          dataTask = session.dataTaskWithURL(url, completionHandler: { data, response, error in
            if let error = error where error.code == -999 {
              return
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
              if let data = data, dictionary = self.parseJSON(data) {
                self.searchResults = self.parseDictionary(dictionary)
                self.searchResults.sortInPlace(<)
          
                dispatch_async(dispatch_get_main_queue()) {
                  self.isLoading = false
                  self.tableView.reloadData()
                }
                return
              }
            } else {
              print("Failure! \(response!)")
            }
            dispatch_async(dispatch_get_main_queue()) {
              self.hasSearched = false
              self.isLoading = false
              self.tableView.reloadData()
              self.showNetworkError()
            }
          })
          dataTask?.resume()
        }
      }
    }
  }
}

// TableViewDataSource
extension SearchViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 1
    } else if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if isLoading {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    } else if searchResults.count == 0 {
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
      let searchResult = searchResults[indexPath.row]
      cell.nameLabel.text = searchResult.name
      if searchResult.artistName.isEmpty {
        cell.artistNameLabel.text = "Unknown"
      } else {
        cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
      }
      return cell
    }
  }
}

// TableViewDelegate
extension SearchViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if searchResults.count == 0 || isLoading {
      return nil
    } else {
      return indexPath
    }
  }
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

