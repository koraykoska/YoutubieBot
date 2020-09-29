//
//  File.swift
//  
//
//  Created by Koray Koska on 28/9/20.
//

import Foundation

extension String {

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
