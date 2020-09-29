//
//  File.swift
//  
//
//  Created by Koray Koska on 29/9/20.
//

import Foundation
import Vapor
import TelegramBot

class MoreVideosCallback: BaseCallbackQuery {

    static func isParsable(callbackQuery: TelegramCallbackQuery) -> Bool {
        guard let data = callbackQuery.data else {
            return false
        }

        let decoder = JSONDecoder()

        guard let decoded = try? decoder.decode(SearchVideoCallbackData.self, from: data.data(using: .utf8)!) else {
            return false
        }

        return decoded.nextPage != nil
    }

    let callbackQuery: TelegramCallbackQuery

    let app: Application

    required init(callbackQuery: TelegramCallbackQuery, app: Application) {
        self.callbackQuery = callbackQuery
        self.app = app
    }

    func run() throws {
        let sendApi = TelegramSendApi(token: app.customConfigService.telegramToken)

        // Respond to callback immediately
        let answer = TelegramSendAnswerCallbackQuery(callbackQueryId: callbackQuery.id)
        sendApi.answerCallbackQuery(answerCallbackQuery: answer)

        guard let chatId = callbackQuery.message?.chat.id else {
            return
        }

        // Remove Yes Button
        if let messageId = callbackQuery.message?.messageId {
            let editMessage = TelegramSendEditMessageReplyMarkup(
                chatId: .int(id: chatId),
                messageId: messageId,
                replyMarkup: TelegramInlineKeyboardMarkup(inlineKeyboard: [])
            )
            sendApi.editMessageReplyMarkup(editMessageReplyMarkup: editMessage)
        }

        // Decode the Callback Data
        guard let data = callbackQuery.data else {
            return
        }

        let decoder = JSONDecoder()

        guard let decoded = try? decoder.decode(SearchVideoCallbackData.self, from: data.data(using: .utf8)!) else {
            return
        }

        guard let nextPage = decoded.nextPage else {
            return
        }

        if let message = callbackQuery.message {
            let searchVideoCommand = SearchVideoCommand(message: message, app: app)
            searchVideoCommand.nextPage = nextPage
        }
    }
}
