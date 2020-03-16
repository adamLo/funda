//
//  AanbodCache.swift
//  Funda
//
//  Created by Adam Lovastyik on 15/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import Foundation

/// Wrapper struct for top-n data
struct MakelaarSummary {
    let makelaar: Makelaar
    let count: Int
}

/// Fetche and caches data
class AanbodCache {
    
    private var allData = [Aanbod]()
    
    /// Contains top 10 agencies by number of properties
    private(set) var top10Agencies = [MakelaarSummary]()
    
    /// Block to execute when a batch of data has been processed
    var dataUpdated: ((_ progress: Float?) -> ())?
    
    /// Block to execute on error
    var errorOccured: ((_ error: Error) -> ())?
    
    /// Location to search for
    let query: String?
    
    // Fetcher
    private let aanbodFetcher: AanbodFetcher
    
    /// Indicates whether cache is currently performing fetch operation
    private(set) var isFetching = false
    
    /// Delay to prevent search stoped by remote due too many attempts at a time
    static let queryDelayInterval: TimeInterval = 0.25
    
    /// Queue to ensure thread safety
    private let dataProcessQueue = DispatchQueue(label: "DataProcess")
    
    /// Search is finished when true
    private(set) var isStopped = false
        
    init(query: String) {
        
        self.query = query.prefix(1) == "/" ? query : "/\(query)"
        aanbodFetcher = AanbodFetcher()
        aanbodFetcher.query = query
    }
    
    /// Starts fetching and processing, reset clears cache and stopped flag, finished block executed when stopped or finished
    func start(reset: Bool = false, finished: (() -> ())?) {
        
        if isStopped {
            if !reset {
                finished?()
                return
            }
            else {
                isStopped = false
            }
        }
        
        if reset {
            dataProcessQueue.async {
                self.allData.removeAll()
            }
            isStopped = false
        }
        
        isFetching = true
        
        let completion: AanbodCompletion = {[weak self] (results, pageCount, error) in
            
            guard let `self` = self else {
                finished?()
                return
            }
            
            if let _error = error {
                // We have an error
                self.errorOccured?(_error)
            }
            else if let _results = results {
                if _results.isEmpty {
                    // No more data fetched, end of operation
                    DispatchQueue.main.async {
                        self.isFetching = false
                        finished?()
                    }
                }
                else {
                    // We have some data to process
                    var progress: Float?
                    if let _pageCount = pageCount, _pageCount > 0 {
                        // Progress depends on page count
                        progress = Float(self.aanbodFetcher.pageIndex) / Float(_pageCount)
                    }
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Process results
                        self.process(results: _results)
                        DispatchQueue.main.async {
                            // Finished with batch, update UI
                            self.dataUpdated?(progress)
                        }
                        if self.isStopped {
                            // User stopped query
                            DispatchQueue.main.async {
                                self.isFetching = false
                                finished?()
                            }
                        }
                        else {
                            // Feth next batch
                            DispatchQueue.main.asyncAfter(deadline: .now() + AanbodCache.queryDelayInterval) {
                                self.start(reset: false, finished: finished)
                            }
                        }
                    }
                }
            }
            else {
                // fallback: no error, no results - finished
                DispatchQueue.main.async {
                    self.isFetching = false
                    finished?()
                }
            }
        }
        
        aanbodFetcher.fetch(query: query, startPage: aanbodFetcher.pageIndex, completion: completion)
    }
    
    /// Processes fetched data and updates cache
    func process(results: [Aanbod]) {
            
        // Contains hash of agencyId: count
        var agenciesCount = [Int: Int]()
        
        dataProcessQueue.sync {
            // Append new data
            for aanbod in results {
                self.allData.append(aanbod)
            }
            // Count each agency's properties
            for aanbod in allData {
                agenciesCount[aanbod.makelaar.id] = (agenciesCount[aanbod.makelaar.id] ?? 0) + 1
            }
        }
        
        // Sort them by number of propertes, descending
        let sorted = agenciesCount.sorted(by: { (value1, value2) -> Bool in
            return value1.value > value2.value
        })

        var top10 = [MakelaarSummary]()
        var count = 0
        for item in sorted {
            
            guard count < 10 else {break}
            
            let agencyId = item.key
            let aanbodCount = item.value
            
            dataProcessQueue.sync {
                // Collect properties for each agency
                if let aanbod = self.allData.first(where: { (_aanbod) -> Bool in
                    return _aanbod.makelaar.id == agencyId
                }) {
                    let summary = MakelaarSummary(makelaar: aanbod.makelaar, count: aanbodCount)
                    top10.append(summary)
                    count += 1
                }
            }
        }
        
        dataProcessQueue.sync {
            self.top10Agencies = top10
        }
    }
    
    /// Returns properties of an agency
    func aanbods(of agency: Makelaar) -> [Aanbod] {
        
        var aanbods: [Aanbod]!
        
        dataProcessQueue.sync {
            aanbods = allData.filter({ (aanbod) -> Bool in
                return aanbod.makelaar.id == agency.id
            })
        }
        
        return aanbods
    }
    
    /// Stops fetching
    func stop() {
        isStopped = true
    }
}
