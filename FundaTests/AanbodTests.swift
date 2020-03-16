//
//  AanbodTests.swift
//  FundaTests
//
//  Created by Adam Lovastyik on 16/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import XCTest
@testable import Funda

class AanbodTests: XCTestCase {
    
    func testInitValid() {
        
        guard let jsonData = "{\"Id\": \"abc123\", \"MakelaarId\": 1234, \"MakelaarNaam\": \"Makelaar X\", \"URL\": \"http://www.funda.nl/koop/amsterdam/huis-41791905-krasseurstraat-45/\", \"Woonplaats\": \"Amsterdam\", \"Adres\": \"Krasseurstraat 45\"}".data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
            XCTFail("Failed to init json data")
            return
        }
        
        let aanbod = Aanbod(json: json)
        XCTAssertNotNil(aanbod)
        
        XCTAssertEqual(aanbod?.id, "abc123")
        XCTAssertNotNil(aanbod?.makelaar)
        XCTAssertEqual(aanbod?.makelaar.id, 1234)
        XCTAssertEqual(aanbod?.makelaar.name, "Makelaar X")
        XCTAssertEqual(aanbod?.url, "http://www.funda.nl/koop/amsterdam/huis-41791905-krasseurstraat-45/")
        XCTAssertEqual(aanbod?.woonplaats, "Amsterdam")
        XCTAssertEqual(aanbod?.adres, "Krasseurstraat 45")
    }

    func testInitInvalid() {
        
        guard let jsonData = "{\"property\": \"wrong\"}".data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
            XCTFail("Failed to init json data")
            return
        }
        
        let aanbod = Aanbod(json: json)
        XCTAssertNil(aanbod)
    }
    
    func testInitInvalidMissingId() {
        
        guard let jsonData = "{\"MakelaarId\": 1234, \"MakelaarNaam\": \"Makelaar X\", \"URL\": \"http://www.funda.nl/koop/amsterdam/huis-41791905-krasseurstraat-45/\", \"Woonplaats\": \"Amsterdam\", \"Adres\": \"Krasseurstraat 45\"}".data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
            XCTFail("Failed to init json data")
            return
        }
        
        let aanbod = Aanbod(json: json)
        XCTAssertNil(aanbod)
    }
    
    func testInitInvalidMissingMakelaarId() {
        
        guard let jsonData = "{\"Id\": \"abc123\", \"MakelaarNaam\": \"Makelaar X\", \"URL\": \"http://www.funda.nl/koop/amsterdam/huis-41791905-krasseurstraat-45/\", \"Woonplaats\": \"Amsterdam\", \"Adres\": \"Krasseurstraat 45\"}".data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
            XCTFail("Failed to init json data")
            return
        }
        
        let aanbod = Aanbod(json: json)
        XCTAssertNil(aanbod)
    }
    
    func testInitInvalidMissingMakelaarNaam() {
        
        guard let jsonData = "{\"Id\": \"abc123\", \"MakelaarId\": 1234, \"URL\": \"http://www.funda.nl/koop/amsterdam/huis-41791905-krasseurstraat-45/\", \"Woonplaats\": \"Amsterdam\", \"Adres\": \"Krasseurstraat 45\"}".data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
            XCTFail("Failed to init json data")
            return
        }
        
        let aanbod = Aanbod(json: json)
        XCTAssertNil(aanbod)
    }
    
    func testInitInvalidMissingURL() {
        
        guard let jsonData = "{\"MakelaarId\": 1234, \"MakelaarNaam\": \"Makelaar X\", \"Woonplaats\": \"Amsterdam\", \"Adres\": \"Krasseurstraat 45\"}".data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
            XCTFail("Failed to init json data")
            return
        }
        
        let aanbod = Aanbod(json: json)
        XCTAssertNil(aanbod)
    }
    
    func testInitInvalidMissingWoonplaats() {
        
        guard let jsonData = "{\"Id\": \"abc123\", \"MakelaarNaam\": \"Makelaar X\", \"URL\": \"http://www.funda.nl/koop/amsterdam/huis-41791905-krasseurstraat-45/\", \"Adres\": \"Krasseurstraat 45\"}".data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
            XCTFail("Failed to init json data")
            return
        }
        
        let aanbod = Aanbod(json: json)
        XCTAssertNil(aanbod)
    }
    
    func testInitInvalidMissingAdres() {
        
        guard let jsonData = "{\"Id\": \"abc123\", \"MakelaarId\": 1234, \"MakelaarNaam\": \"Makelaar X\", \"URL\": \"http://www.funda.nl/koop/amsterdam/huis-41791905-krasseurstraat-45/\", \"Woonplaats\": \"Amsterdam\"}".data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON else {
            XCTFail("Failed to init json data")
            return
        }
        
        let aanbod = Aanbod(json: json)
        XCTAssertNil(aanbod)
    }
}
