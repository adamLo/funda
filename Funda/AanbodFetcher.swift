//
//  AanbodFetcher.swift
//  Funda
//
//  Created by Adam Lovastyik on 15/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import Foundation

typealias AanbodCompletion = ((_ results: [Aanbod]?, _ pageCount: Int?, _ error: Error?) -> ())

/// Fetches a batch of properties from remote
class AanbodFetcher {
    
    let baseURL = URL(string: "http://partnerapi.funda.nl/feeds/Aanbod.svc/")!
    let apiKey = "ac1b0b1572524640a0ecc54de453ea9f"
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    /// Location to search
    var query: String?
    
    /// Current page
    var pageIndex: Int = 1
    
    /// Size of batch
    var pageSize: Int = 25
    
    /// Search type
    var type: SearchType = .koop
    
    static let ErrorDomain = "AANBODFETCHER"
    
    private struct QueryKeys {
        static let type     = "type"
        static let zo       = "zo"
        static let page     = "page"
        static let pageSize = "pagesize"
    }
    
    private struct JSONKeys {
        static let objects      = "Objects"
        static let paging       = "Paging"
        static let pageCount    = "AantalPaginas"
    }
    
    enum SearchType: String {
        case koop
    }
    
    /// Fetches one batch, returns result in completion: either array of properties and page count or an error
    func fetch(type: SearchType = .koop, query: String? = nil, startPage: Int = 1, pageSize: Int = 25, completion: AanbodCompletion?) {
        
        // Construct URL
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent("json").appendingPathComponent(apiKey).appendingPathComponent(""), resolvingAgainstBaseURL: false) else {
            completion?(nil, nil, NSError(domain: AanbodFetcher.ErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot construct URL"]))
            return
        }
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: QueryKeys.type, value: type.rawValue))
        if let _query = query?.nilIfEmpty {
            queryItems.append(URLQueryItem(name: QueryKeys.zo, value: _query))
        }
        queryItems.append(URLQueryItem(name: QueryKeys.page, value: "\(startPage)"))
        queryItems.append(URLQueryItem(name: QueryKeys.pageSize, value: "\(pageSize)"))
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion?(nil, nil, NSError(domain: AanbodFetcher.ErrorDomain, code: -2, userInfo: [NSLocalizedDescriptionKey: "Cannot construct URL"]))
            return
        }
        
        print("*** \(url.absoluteString)")
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let _error = error {
                // We have an error
                DispatchQueue.main.async {
                    completion?(nil, nil, _error)
                }
                return
            }
                        
            // Extract json data
            guard let _data = data, let json = try? JSONSerialization.jsonObject(with: _data, options: []) as? JSON else {
                DispatchQueue.main.async {
                    completion?(nil, nil, NSError(domain: AanbodFetcher.ErrorDomain, code: -3, userInfo: [NSLocalizedDescriptionKey: "No valid JSON response received"]))
                }
                return
            }
            
            // Find page count to determine progress
            guard let objects = json[JSONKeys.objects] as? JSONArray else {
                DispatchQueue.main.async {
                    completion?(nil, nil, NSError(domain: AanbodFetcher.ErrorDomain, code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"]))
                }
                return
            }
            
            // Calculate progress
            var pageCount: Int?
            if let paging = json[JSONKeys.paging] as? JSON  {
                pageCount = paging[JSONKeys.pageCount] as? Int
            }
            
            // Process json
            var results = [Aanbod]()
            for json in objects {
                guard let aanbod = Aanbod(json: json) else {continue}
                results.append(aanbod)
            }
            
            DispatchQueue.main.async {
                self.pageIndex += 1
                completion?(results, pageCount, nil)
            }
        }
        task.resume()
        
        self.query = query
        self.pageIndex = startPage
        self.pageSize = pageSize
    }
}
