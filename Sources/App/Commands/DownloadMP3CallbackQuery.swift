//
//  File.swift
//  
//
//  Created by Koray Koska on 29/9/20.
//

import Foundation
import Vapor
import TelegramBot

class DownloadMP3CallbackQuery: BaseCallbackQuery {

    static func isParsable(callbackQuery: TelegramCallbackQuery) -> Bool {
        guard let data = callbackQuery.data else {
            return false
        }

        let decoder = JSONDecoder()

        guard let decoded = try? decoder.decode(SearchVideoCallbackData.self, from: data.data(using: .utf8)!) else {
            return false
        }

        return decoded.videoId != nil
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

        // Remove Download Button
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

        guard let videoId = decoded.videoId else {
            return
        }

        // Get YT Video Details
        let youtubeApi = YoutubeApi(token: app.customConfigService.youtubeApiKey, client: app.client)

        youtubeApi.getVideoById(id: videoId).whenSuccess { item in
            guard let item = item else {
                return
            }

            let name = item.snippet.title.decodingHTMLEntities()

            // Informing the User about the Download
            sendApi.sendMessage(
                message: TelegramSendMessage(
                    chatId: chatId,
                    text: "Downloading \(name) from \(item.snippet.channelTitle)"
                )
            )

            // Download file
            let youtubeDL = YoutubeDL()

            guard let mp3Path = youtubeDL.downloadMP3(item: item) else {
                return
            }
            defer {
                youtubeDL.deleteMP3(filePath: mp3Path)
            }

            // Send file to user
            let audio = TelegramSendAudio(
                chatId: .int(id: chatId),
                audio: mp3Path,
                caption: name,
                performer: item.snippet.channelTitle,
                title: name
            )

            TelegramAudioUpload.uploadAudio(
                token: self.app.customConfigService.telegramToken,
                audio: audio,
                fileName: "\(name).mp3"
            ) { response in
                // TODO: Handle Error
                print(response)
            }
        }
    }
}
