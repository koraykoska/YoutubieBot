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
import Dispatch

class SearchVideoCommand: BaseCommand {

    static func isParsable(message: TelegramMessage, botName: String) -> Bool {
        guard let text = message.text, !text.hasPrefix("/") else {
            return false
        }

        return true
    }

    static let command: String = ""

    let message: TelegramMessage

    let app: Application

    // If set, take values from this variable and not message (TelegramMessage)
    var nextPage: SearchVideoCallbackData.NextPage?

    required init(message: TelegramMessage, app: Application) {
        self.message = message
        self.app = app
    }

    func run() throws {
        let chat = message.chat
        let chatId = chat.id

        // Telegram Send API
        let sendApi = TelegramSendApi(token: app.customConfigService.telegramToken, sleep: 500000)

        // JSONEncoder
        let encoder = JSONEncoder()

        // Search YT Videos
        let query = (nextPage?.originalQuery ?? message.text ?? "").deletingPrefix(app.customConfigService.botName)

        let youtubeApi = YoutubeApi(token: app.customConfigService.youtubeApiKey, client: app.client)
        youtubeApi.getVideos(query: query, pageToken: nextPage?.nextPageToken).whenSuccess { response in
            for i in response.items {
                let callback = SearchVideoCallbackData(videoId: i.id.videoId, nextPage: nil)
                let ytLink = "https://www.youtube.com/watch?v=\(i.id.videoId ?? "")"

                let keyboard = TelegramInlineKeyboardMarkup(inlineKeyboard: [[
                    TelegramInlineKeyboardButton(text: "Download ⬇️", callbackData: try! String(data: encoder.encode(callback), encoding: .utf8)!)
                ]])
                let replyMarkup = TelegramSendMessage.ReplyMarkup.inlineKeyboardMarkup(keyboard: keyboard)

                let message = TelegramSendMessage(chatId: chatId, text: ytLink, replyMarkup: replyMarkup)
                sendApi.sendMessage(message: message)
            }

            let callback = SearchVideoCallbackData(
                videoId: nil,
                nextPage: .init(nextPageToken: response.nextPageToken ?? "", originalQuery: query, maxResults: 5)
            )
            let keyboard = TelegramInlineKeyboardMarkup(inlineKeyboard: [[
                TelegramInlineKeyboardButton(text: "Yes, Please 😬", callbackData: try! String(data: encoder.encode(callback), encoding: .utf8)!)
            ]])
            let replyMarkup = TelegramSendMessage.ReplyMarkup.inlineKeyboardMarkup(keyboard: keyboard)

            let message = TelegramSendMessage(chatId: chatId, text: "More?", replyMarkup: replyMarkup)
            sendApi.sendMessage(message: message)
        }
    }
}

struct SearchVideoCallbackData: Codable {

    let videoId: String?

    let nextPage: NextPage?

    struct NextPage: Codable {

        let nextPageToken: String

        let originalQuery: String

        let maxResults: Int
    }
}
