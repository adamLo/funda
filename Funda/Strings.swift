//
//  Strings.swift
//  Funda
//
//  Created by Adam Lovastyik on 15/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import Foundation

/// helper extension for strings
extension String {

    /// Trims white spaces and new lines from beginning and end of string
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns nil if string is empty after trimming
    var nilIfEmpty: String? {
        let _trimmed = self.trimmed
        return _trimmed.isEmpty ? nil : _trimmed
    }

}
