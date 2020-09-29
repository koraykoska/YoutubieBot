//
//  File.swift
//  
//
//  Created by Koray Koska on 24/9/20.
//

import Foundation
import TelegramBot
import Vapor

protocol BaseCallbackQuery {

    static func isParsable(callbackQuery: TelegramCallbackQuery) -> Bool

    var callbackQuery: TelegramCallbackQuery { get }

    init(callbackQuery: TelegramCallbackQuery, app: Application)

    func run() throws
}

extension BaseCallbackQuery {

    static func isParsable(callbackQuery: TelegramCallbackQuery) -> Bool {
        guard let data = callbackQuery.data else {
            return false
        }

        return true
    }
}
