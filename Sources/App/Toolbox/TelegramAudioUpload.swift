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

class TelegramAudioUpload {

    static func uploadAudio(token: String, audio: TelegramSendAudio, fileName: String, response: @escaping (_ resp: TelegramResponse<TelegramMessage>) -> Void) {
        let queue = DispatchQueue(label: "TelegramSendAudio")

        queue.async {
            let multiPart = URLRequest(multipartFormData: { formData in
                try? formData.append(filePath: audio.audio, name: "audio", fileName: fileName)

                switch audio.chatId {
                case .int(let id):
                    formData.append(value: "\(id)", name: "chat_id")
                case .string(let id):
                    formData.append(value: id, name: "chat_id")
                }

                if let caption = audio.caption {
                    formData.append(value: "\(caption)", name: "caption")
                }
                if let parseMode = audio.parseMode {
                    formData.append(value: "\(parseMode)", name: "parseMode")
                }
                if let duration = audio.duration {
                    formData.append(value: "\(duration)", name: "duration")
                }
                if let performer = audio.performer {
                    formData.append(value: "\(performer)", name: "performer")
                }
                if let title = audio.title {
                    formData.append(value: "\(title)", name: "title")
                }
                if let thumb = audio.thumb {
                    formData.append(value: "\(thumb)", name: "thumb")
                }
                if let disableNotification = audio.disableNotification {
                    formData.append(value: "\(disableNotification)", name: "disableNotification")
                }
                if let replyToMessageId = audio.replyToMessageId {
                    formData.append(value: "\(replyToMessageId)", name: "replyToMessageId")
                }
                if let disableNotification = audio.disableNotification {
                    formData.append(value: "\(disableNotification)", name: "disableNotification")
                }
            }, url: URL(string: "https://api.telegram.org/bot\(token)/sendAudio")!)

            let session = URLSession(configuration: .default)

            let task = session.dataTask(with: multiPart) { data, urlResponse, error in
                guard let urlResponse = urlResponse as? HTTPURLResponse, let data = data, error == nil else {
                    let err = TelegramResponse<TelegramMessage>(error: .serverError(error))
                    response(err)
                    return
                }

                let status = urlResponse.statusCode
                guard status >= 200 && status < 300 else {
                    // This is a non typical error response and should be considered a server error.
                    let err = TelegramResponse<TelegramMessage>(error: .serverError(nil))
                    response(err)
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(TelegramApiResponse<TelegramMessage>.self, from: data)
                    // We got the Result object
                    let res = TelegramResponse(response: decoded)
                    response(res)
                } catch {
                    // We don't have the response we expected...
                    let err = TelegramResponse<TelegramMessage>(error: .decodingError(error))
                    response(err)
                }
            }
            task.resume()
        }
    }
}
