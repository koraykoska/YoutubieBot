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

    static func isParsable(callbackQuery: TelegramCallbackQuery, app: Application) -> EventLoopFuture<Bool> {
        guard let data = callbackQuery.data else {
            return app.db.eventLoop.makeSucceededFuture(false)
        }

        return SearchVideoCallbackData.find(UUID(uuidString: data), on: app.db).map { return $0 != nil && $0?.nextPageToken != nil }
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

        SearchVideoCallbackData.find(UUID(uuidString: data), on: app.db).flatMapThrowing { callbackData in
            guard let callbackData = callbackData else {
                return
            }

            guard let _ = callbackData.nextPageToken else {
                return
            }

            if let message = self.callbackQuery.message {
                let searchVideoCommand = SearchVideoCommand(message: message, app: self.app)
                searchVideoCommand.callbackData = callbackData

                try searchVideoCommand.run()
            }
        }
    }
}
