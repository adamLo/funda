//
//  AanbodCacheTests.swift
//  FundaTests
//
//  Created by Adam Lovastyik on 16/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import XCTest
@testable import Funda

class AanbodCacheTests: XCTestCase {

    func testProcess() {
        
        let aanbods: [Aanbod] = [
            Aanbod(id: "1", makelaar: Makelaar(id: 1, name: "1"), url: "a", woonplaats: "b", adres: "c"),
            Aanbod(id: "2", makelaar: Makelaar(id: 1, name: "1"), url: "b", woonplaats: "b", adres: "c"),
            Aanbod(id: "3", makelaar: Makelaar(id: 2, name: "2"), url: "d", woonplaats: "c", adres: "d"),
            Aanbod(id: "4", makelaar: Makelaar(id: 2, name: "2"), url: "e", woonplaats: "c", adres: "e"),
            Aanbod(id: "5", makelaar: Makelaar(id: 2, name: "2"), url: "f", woonplaats: "d", adres: "f")
        ]
        
        let cache = AanbodCache(query: "x")
        cache.process(results: aanbods)
        
        XCTAssertEqual(cache.top10Agencies.count, 2)
        
        guard let first = cache.top10Agencies.first else {
            XCTFail("First not found")
            return
        }
        XCTAssertEqual(first.makelaar.id, 2)
        
        let aanbodsFirst = cache.aanbods(of: first.makelaar)
        XCTAssertEqual(aanbodsFirst.count, 3)
        
        let second = cache.top10Agencies[1]
        XCTAssertEqual(first.makelaar.id, 2)
        
        let aanbodsSecond = cache.aanbods(of: second.makelaar)
        XCTAssertEqual(aanbodsSecond.count, 2)
    }

}
