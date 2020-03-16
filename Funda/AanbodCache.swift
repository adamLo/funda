//
//  AanbodCache.swift
//  Funda
//
//  Created by Adam Lovastyik on 15/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import Foundation

struct MakelaarSummary {
    let makelaar: Makelaar
    let count: Int
}

class AanbodCache {
    
    private var allData = [Aanbod]()
    private(set) var top10Agencies = [MakelaarSummary]()
    
    var dataUpdated: ((_ progress: Float?) -> ())?
    var errorOccured: ((_ error: Error) -> ())?
    
    let query: String?
    private let aanbodFetcher: AanbodFetcher
    
    private(set) var isFetching = false
    
    static let queryDelayInterval: TimeInterval = 0.25
    
    private let dataProcessQueue = DispatchQueue(label: "DataProcess")
    
    private(set) var isStopped = false
        
    init(query: String) {
        
        self.query = query.prefix(1) == "/" ? query : "/\(query)"
        aanbodFetcher = AanbodFetcher()
        aanbodFetcher.query = query
    }
    
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
                self.errorOccured?(_error)
            }
            else if let _results = results {
                if _results.isEmpty {
                    DispatchQueue.main.async {
                        self.isFetching = false
                        finished?()
                    }
                }
                else {
                    
                    var progress: Float?
                    if let _pageCount = pageCount, _pageCount > 0 {
                        progress = Float(self.aanbodFetcher.pageIndex) / Float(_pageCount)
                    }
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.process(results: _results)
                        DispatchQueue.main.async {
                            self.dataUpdated?(progress)
                        }
                        if self.isStopped {
                            DispatchQueue.main.async {
                                self.isFetching = false
                                finished?()
                            }
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + AanbodCache.queryDelayInterval) {
                                self.start(reset: false, finished: finished)
                            }
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.isFetching = false
                    finished?()
                }
            }
        }
        
        aanbodFetcher.fetch(query: query, startPage: aanbodFetcher.pageIndex, completion: completion)
    }
    
    private func process(results: [Aanbod]) {
            
        // Contains hash of agencyId: count
        var agenciesCount = [Int: Int]()
        
        dataProcessQueue.sync {
            
            for aanbod in results {
                self.allData.append(aanbod)
            }

            for aanbod in allData {
                agenciesCount[aanbod.makelaar.id] = (agenciesCount[aanbod.makelaar.id] ?? 0) + 1
            }
        }
        
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
    
    func aanbods(of agency: Makelaar) -> [Aanbod] {
        
        var aanbods: [Aanbod]!
        
        dataProcessQueue.sync {
            aanbods = allData.filter({ (aanbod) -> Bool in
                return aanbod.makelaar.id == agency.id
            })
        }
        
        return aanbods
    }
    
    func stop() {
        isStopped = true
    }
}
