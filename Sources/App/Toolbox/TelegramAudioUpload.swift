//
//  File.swift
//  
//
//  Created by Koray Koska on 29/9/20.
//

import Foundation
import Dispatch
import TelegramBot
#if os(Linux)
import FoundationNetworking
#endif
import Vapor
import SwiftyRequest

class TelegramAudioUpload {

    let token: String

    var request: RestRequest?

    init(token: String) {
        self.token = token
    }

    func uploadAudio(audio: TelegramSendAudio, fileName: String, response: @escaping (_ resp: TelegramResponse<TelegramMessage>) -> Void) {
        self.request = RestRequest(method: .post, url: "https://api.telegram.org/bot\(token)/sendAudio")

        let multiPart = MultipartFormData()
        request?.contentType = multiPart.contentType

        let url = URL(fileURLWithPath: audio.audio)
        if let data = try? Data.init(contentsOf: url) {
            multiPart.append(data, withName: "audio", mimeType: mimeType(ext: url.pathExtension), fileName: fileName)
        }

        switch audio.chatId {
        case .int(let id):
            multiPart.append("\(id)", withName: "chat_id")
        case .string(let id):
            multiPart.append(id, withName: "chat_id")
        }

        if let caption = audio.caption {
            multiPart.append("\(caption)", withName: "caption")
        }
        if let parseMode = audio.parseMode {
            multiPart.append("\(parseMode)", withName: "parseMode")
        }
        if let duration = audio.duration {
            multiPart.append("\(duration)", withName: "duration")
        }
        if let performer = audio.performer {
            multiPart.append("\(performer)", withName: "performer")
        }
        if let title = audio.title {
            multiPart.append("\(title)", withName: "title")
        }
        if let thumb = audio.thumb {
            multiPart.append("\(thumb)", withName: "thumb")
        }
        if let disableNotification = audio.disableNotification {
            multiPart.append("\(disableNotification)", withName: "disableNotification")
        }
        if let replyToMessageId = audio.replyToMessageId {
            multiPart.append("\(replyToMessageId)", withName: "replyToMessageId")
        }

        try? request?.messageBody = multiPart.toData()

        let queue = DispatchQueue(label: "MultiPartRequest")

        queue.async {
            let group = DispatchGroup()

            group.enter()
            self.request?.responseData { result in
                switch result {
                case .success(let telegramResponse):
                    let status = telegramResponse.status.code
                    guard status >= 200 && status < 300 else {
                        // This is a non typical error response and should be considered a server error.
                        let err = TelegramResponse<TelegramMessage>(error: .serverError(nil))
                        response(err)
                        return
                    }

                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let decoded = try decoder.decode(TelegramApiResponse<TelegramMessage>.self, from: telegramResponse.body)
                        // We got the Result object
                        let res = TelegramResponse(response: decoded)
                        response(res)
                    } catch {
                        // We don't have the response we expected...
                        let err = TelegramResponse<TelegramMessage>(error: .decodingError(error))
                        response(err)
                    }
                case .failure(let error):
                    let err = TelegramResponse<TelegramMessage>(error: .serverError(error))
                    response(err)
                }

                group.leave()
            }

            group.wait()
        }
    }
}
