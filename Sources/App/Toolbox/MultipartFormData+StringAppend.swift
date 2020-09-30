//
//  File.swift
//  
//
//  Created by Koray Koska on 30/9/20.
//

import Foundation
import SwiftyRequest

extension MultipartFormData {

    public func append(_ string: String, withName: String, mimeType: String? = nil, fileName: String? = nil) {
        let data = string.data(using: .utf8)!
        append(data, withName: withName, mimeType: mimeType, fileName: fileName)
    }
}
