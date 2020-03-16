//
//  Aanbod.swift
//  Funda
//
//  Created by Adam Lovastyik on 15/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import Foundation

/// Simple structure to implement a property
struct Aanbod: JSONDeserializable {
    
    /// Identifer, required
    let id: String
    /// Agency, required
    let makelaar: Makelaar
    /// URL, required
    let url: String
    /// Location, required
    let woonplaats: String
    /// Address, required
    let adres: String
    
    /// Initializes object witj JSON - fails if not all required propertes are present
    init?(json: JSON) {
        
        // Init fails if these properties are not present in json
        guard let __id = json[JSONKeys.id] as? String, let _id = __id.nilIfEmpty else {return nil}
        guard let _makelaarId = json[JSONKeys.makelaarId] as? Int else {return nil}
        guard let __makelaarNaam = json[JSONKeys.makelaarNaam] as? String, let _makelaarNaam = __makelaarNaam.nilIfEmpty else {return nil}
        guard let __url = json[JSONKeys.url] as? String, let _url = __url.nilIfEmpty else {return nil}
        guard let __woonplaats = json[JSONKeys.woonplaats] as? String, let _woonplaats = __woonplaats.nilIfEmpty else {return nil}
        guard let __adres = json[JSONKeys.adres] as? String, let _adres = __adres.nilIfEmpty else {return nil}
        
        self.id = _id
        self.makelaar = Makelaar(id: _makelaarId, name: _makelaarNaam)
        self.url = _url
        self.woonplaats = _woonplaats
        self.adres = _adres
    }
    
    /// Convenience initializer - used for testing
    init(id: String, makelaar: Makelaar, url: String, woonplaats: String, adres: String) {
        
        self.id = id
        self.makelaar = makelaar
        self.url = url
        self.woonplaats = woonplaats
        self.adres = adres
    }
    
    /// JSON keys
    private struct JSONKeys {
        static let id           = "Id"
        static let makelaarId   = "MakelaarId"
        static let makelaarNaam = "MakelaarNaam"
        static let url          = "URL"
        static let woonplaats   = "Woonplaats"
        static let adres        = "Adres"
    }
}
