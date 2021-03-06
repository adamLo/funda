//
//  Alerts.swift
//  Funda
//
//  Created by Adam Lovastyik on 16/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import Foundation
import UIKit

/// Helper extension to display dialogs
extension UIAlertController {
    
    /// Shows a simple alert with an OK button - used to display errors
    static func alertWithOKButton(title: String? = nil, message: String? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button title"), style: .default, handler: nil))
        return alert
    }
}
