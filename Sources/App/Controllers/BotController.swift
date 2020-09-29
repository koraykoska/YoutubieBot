//
//  File.swift
//  
//
//  Created by Koray Koska on 24/9/20.
//

import Foundation
import TelegramBot
import Vapor

final class BotController {

    let app: Application

    init(app: Application) {
        self.app = app
    }

    func getMessage(id: Int, message: TelegramMessage) {
        let commands: [BaseCommand.Type] = [StartCommand.self, SearchVideoCommand.self]

        var correctCommands: [BaseCommand] = []
        for command in commands {
            if command.isParsable(message: message, botName: app.customConfigService.botName) {
                correctCommands.append(command.init(message: message, app: app))
            }
        }

        for command in correctCommands {
            try? command.run()
        }
    }

    func getCallback(id: Int, callback: TelegramCallbackQuery) {
        let callbackQueries: [BaseCallbackQuery.Type] = [DownloadMP3CallbackQuery.self, MoreVideosCallback.self]

        var correctCallbackQueries: [BaseCallbackQuery] = []
        for query in callbackQueries {
            if query.isParsable(callbackQuery: callback) {
                correctCallbackQueries.append(query.init(callbackQuery: callback, app: app))
            }
        }

        for query in correctCallbackQueries {
            try? query.run()
        }
    }
}
