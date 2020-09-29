//
//  File.swift
//  
//
//  Created by Koray Koska on 24/9/20.
//

import Vapor
import TelegramBot
import TelegramBotPromiseKit
import PromiseKit

class StartCommand: BaseCommand {

    static let command: String = "/start"

    let message: TelegramMessage

    let app: Application

    required init(message: TelegramMessage, app: Application) {
        self.message = message
        self.app = app
    }

    func run() throws {
        let chat = message.chat
        let chatId = chat.id
        let chatTitle = chat.title
        let chatFirstName = chat.firstName

        let chatName = chatTitle ?? chatFirstName ?? "1 Larry"

        let text = "Hi \(chatName)! I am Youtubie. I am here to help you download Youtube Videos and Songs. Go ahead and search for some videos!"

        let sendApi = TelegramSendApi(token: app.customConfigService.telegramToken)

        sendApi.sendMessage(message: TelegramSendMessage(chatId: chatId, text: text))
    }
}
