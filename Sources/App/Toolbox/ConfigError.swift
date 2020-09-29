//
//  File.swift
//  
//
//  Created by Koray Koska on 24/9/20.
//

import Foundation

enum ConfigError: Error {

    case envVariableNotFound(details: String)
}
