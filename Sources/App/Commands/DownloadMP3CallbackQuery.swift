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

    static func isParsable(callbackQuery: TelegramCallbackQuery, app: Application) -> EventLoopFuture<Bool> {
        guard let data = callbackQuery.data else {
            return app.db.eventLoop.makeSucceededFuture(false)
        }

        return SearchVideoCallbackData.find(UUID(uuidString: data), on: app.db).map { return $0 != nil && $0?.videoId != nil }
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

        SearchVideoCallbackData.find(UUID(uuidString: data), on: app.db).whenSuccess { callbackData in
            guard let callbackData = callbackData else {
                return
            }

            guard let videoId = callbackData.videoId else {
                return
            }

            // Get YT Video Details
            let youtubeApi = YoutubeApi(token: self.app.customConfigService.youtubeApiKey, client: self.app.client)

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

                // Check Cache
                YoutubeMP3TelegramCache.query(on: self.app.db).filter(\.$youtubeId, .equal, videoId).first().map { cache in
                    if let cache = cache {
                        // Telegram already has a cache copy of this file
                        let audio = TelegramSendAudio(
                            chatId: .int(id: chatId),
                            audio: cache.telegramId,
                            caption: name,
                            performer: item.snippet.channelTitle,
                            title: name
                        )

                        sendApi.sendAudio(audio: audio)
                    } else {
                        // Download file
                        let youtubeDL = YoutubeDL()

                        // let queue = DispatchQueue(label: "DownloadYoutubeFile")

                        guard let mp3Path = youtubeDL.downloadMP3(item: item, cookies: self.app.customConfigService.youtubeCookies) else {
                            return
                        }
                        defer {
                            youtubeDL.deleteMP3(filePath: mp3Path)
                        }

                        // Download the file from YT
                        let audio = TelegramSendAudio(
                            chatId: .int(id: chatId),
                            audio: mp3Path,
                            caption: name,
                            performer: item.snippet.channelTitle,
                            title: name
                        )

                        let audioUpload = TelegramAudioUpload(token: self.app.customConfigService.telegramToken)
                        audioUpload.uploadAudio(
                            audio: audio,
                            fileName: "\(name).mp3"
                        ) { response in
                            if let message = response.result {
                                if let fileId = message.audio?.fileId {
                                    // Cache it now
                                    let cache = YoutubeMP3TelegramCache(telegramId: fileId, youtubeId: videoId)
                                    cache.save(on: self.app.db)
                                }
                            }

                            // TODO: Handle Error
                            print(response)
                        }
                    }
                }
            }
        }
    }
}
