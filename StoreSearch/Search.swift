//
//  Search.swift
//  StoreSearch
//
//  Created by Molly Waggett on 12/7/15.
//  Copyright © 2015 Molly Waggett. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
  
  enum Category: Int {
    case All = 0
    case Music = 1
    case Software = 2
    case Audiobooks = 3
    
    var entityName: String {
      switch self {
      case .All: return ""
      case .Music: return "musicTrack"
      case .Software: return "software"
      case .Audiobooks: return "audiobook"
      }
    }
  }
  
  enum State {
    case NotSearchedYet // also used when there is an error
    case Loading
    case NoResults
    case Results([SearchResult])
  }

  private(set) var state: State = .NotSearchedYet
  private var dataTask: NSURLSessionDataTask? = nil
  
  func performSearchForText(text: String, category: Category, completion: SearchComplete) {
    print("Searching...")
    if !text.isEmpty {
      dataTask?.cancel()
      state = .Loading
      
      if let url = urlWithSearchText(text, category: category) {
        let session = NSURLSession.sharedSession()
        dataTask = session.dataTaskWithURL(url, completionHandler: { data, response, error in
          self.state = .NotSearchedYet
          var success = false
          if let error = error where error.code == -999 {
            return
          }
          if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200, let data = data, dictionary = self.parseJSON(data) {
            var searchResults = self.parseDictionary(dictionary)
            if searchResults.isEmpty {
              self.state = .NoResults
            } else {
              searchResults.sortInPlace(<)
              self.state = .Results(searchResults)
            }
            success = true
          }         
          dispatch_async(dispatch_get_main_queue()) {
            completion(success)
          }
        })
        dataTask?.resume()
      }
    }
  }
  
  private func urlWithSearchText(searchText: String, category: Category) -> NSURL? {
    let entityName = category.entityName
    let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
    let url = NSURL(string: urlString)
    return url
  }
  
  private func parseJSON(data: NSData) -> [String: AnyObject]? {
    do {
      return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
    } catch {
      print("JSON Error: \(error)")
      return nil
    }
  }
  
  private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
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
  
  private func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
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
  
  private func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
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
  
  private func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
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
  
  private func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
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
}
