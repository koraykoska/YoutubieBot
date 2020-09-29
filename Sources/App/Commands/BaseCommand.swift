//
//  File.swift
//  
//
//  Created by Koray Koska on 24/9/20.
//

import Foundation
import TelegramBot
import Vapor

protocol BaseCommand {

    static var command: String { get }

    static func isParsable(message: TelegramMessage, botName: String) -> Bool

    var message: TelegramMessage { get }

    init(message: TelegramMessage, app: Application)

    func run() throws
}

extension BaseCommand {

    static func isParsable(message: TelegramMessage, botName: String) -> Bool {
        guard let text = message.text else {
            return false
        }

        return text == command || text == "\(command)\(botName)"
    }
}
