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
    var callbackData: SearchVideoCallbackData?

    required init(message: TelegramMessage, app: Application) {
        self.message = message
        self.app = app
    }

    func run() throws {
        let chat = message.chat
        let chatId = chat.id

        // Telegram Send API
        let sendApi = TelegramSendApi(token: app.customConfigService.telegramToken, sleep: 500000)

        // Search YT Videos
        let messageText = message.text?.deletingPrefix(app.customConfigService.botName)
        let query = (callbackData?.originalQuery ?? messageText ?? "").deletingPrefix(app.customConfigService.botName)

        let youtubeApi = YoutubeApi(token: app.customConfigService.youtubeApiKey, client: app.client)
        youtubeApi.getVideos(query: query, pageToken: callbackData?.nextPageToken).whenSuccess { response in
            var callbacks = [EventLoopFuture<(item: YoutubeApi.Response.Item, callback: SearchVideoCallbackData)>]()
            for i in response.items {
                let callback = SearchVideoCallbackData(videoId: i.id.videoId ?? "")
                callbacks.append(callback.save(on: self.app.db).map { return (item: i, callback: callback) })
            }

            EventLoopFuture<(item: YoutubeApi.Response.Item, callback: SearchVideoCallbackData)>.whenAllSucceed(callbacks, on: self.app.eventLoopGroup.next()).whenSuccess { items in
                for (item, callback) in items {
                    let ytLink = "https://www.youtube.com/watch?v=\(item.id.videoId ?? "")"

                    let keyboard = TelegramInlineKeyboardMarkup(inlineKeyboard: [[
                        TelegramInlineKeyboardButton(text: "Download ⬇️", callbackData: callback.id?.uuidString ?? "")
                    ]])
                    let replyMarkup = TelegramSendMessage.ReplyMarkup.inlineKeyboardMarkup(keyboard: keyboard)

                    let message = TelegramSendMessage(chatId: chatId, text: ytLink, replyMarkup: replyMarkup)
                    sendApi.sendMessage(message: message)
                }

                // More Button

                let callback = SearchVideoCallbackData(
                    nextPageToken: response.nextPageToken ?? "",
                    originalQuery: query,
                    maxResults: 5
                )
                callback.save(on: self.app.db).whenSuccess {
                    let keyboard = TelegramInlineKeyboardMarkup(inlineKeyboard: [[
                        TelegramInlineKeyboardButton(text: "Yes, Please 😬", callbackData: callback.id?.uuidString ?? "")
                    ]])
                    let replyMarkup = TelegramSendMessage.ReplyMarkup.inlineKeyboardMarkup(keyboard: keyboard)

                    let message = TelegramSendMessage(chatId: chatId, text: "More?", replyMarkup: replyMarkup)
                    sendApi.sendMessage(message: message)
                }
            }
        }
    }
}
