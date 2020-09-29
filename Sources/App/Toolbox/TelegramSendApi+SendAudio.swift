//
//  File.swift
//  
//
//  Created by Koray Koska on 29/9/20.
//

import Foundation
import TelegramBot
import PromiseKit

public final class TelegramSendAudio: Codable {

    // MARK: - Primitive types

    /// Unique identifier for the target chat or
    /// username of the target channel (in the
    /// format @channelusername)
    public var chatId: TelegramSendChatIdentifier

    /// Audio file to send. Pass a file_id as String to send an
    /// audio file that exists on the Telegram servers
    /// (recommended), pass an HTTP URL as a String for
    /// Telegram to get an audio file from the Internet, or
    /// upload a new one using multipart/form-data.
    public var audio: String

    /// Audio caption, 0-1024 characters after entities
    /// parsing
    public var caption: String?

    /// Mode for parsing entities in the audio caption.
    /// See formatting options for more details.
    public var parseMode: TelegramSendMessage.ParseMode?

    /// Duration of the audio in seconds
    public var duration: Int?

    /// Performer
    public var performer: String?

    /// Track name
    public var title: String?

    /// Thumbnail of the file sent; can be ignored if thumbnail
    /// generation for the file is supported server-side. The
    /// thumbnail should be in JPEG format and less than 200
    /// kB in size. A thumbnail's width and height should not
    /// exceed 320. Ignored if the file is not uploaded using
    /// multipart/form-data. Thumbnails can't be reused and
    /// can be only uploaded as a new file, so you can pass
    /// “attach://<file_attach_name>” if the thumbnail was
    /// uploaded using multipart/form-data under
    /// <file_attach_name>.
    public var thumb: String?

    /// Sends the message silently. Users will receive a
    /// notification with no sound.
    public var disableNotification: Bool?

    /// If the message is a reply, ID of the original message
    public var replyToMessageId: Int?

    /// Additional interface options. A JSON-serialized object
    /// for an inline keyboard, custom reply keyboard,
    /// instructions to remove reply keyboard or to force a
    /// reply from the user.
    public var replyMarkup: TelegramSendMessage.ReplyMarkup?

    // MARK: - Initialization

    public init(
        chatId: TelegramSendChatIdentifier,
        audio: String,
        caption: String? = nil,
        parseMode: TelegramSendMessage.ParseMode? = nil,
        duration: Int? = nil,
        performer: String? = nil,
        title: String? = nil,
        thumb: String? = nil,
        disableNotification: Bool? = nil,
        replyToMessageId: Int? = nil,
        replyMarkup: TelegramSendMessage.ReplyMarkup? = nil
    ) {
        self.chatId = chatId
        self.audio = audio
        self.caption = caption
        self.parseMode = parseMode
        self.duration = duration
        self.performer = performer
        self.title = title
        self.thumb = thumb
        self.disableNotification = disableNotification
        self.replyToMessageId = replyToMessageId
        self.replyMarkup = replyMarkup
    }
}

extension TelegramSendApi {

    public func sendAudio(audio: TelegramSendAudio, response: @escaping TelegramResponseCompletion<TelegramMessage>) {
        provider.send(method: "sendAudio", request: audio, response: response)
    }

    public func sendAudio(audio: TelegramSendAudio) -> Promise<TelegramMessage> {
        return Promise { seal in
            self.sendAudio(audio: audio) { response in
                response.sealPromise(seal: seal)
            }
        }
    }
}

fileprivate extension TelegramResponse {

    func sealPromise(seal: Resolver<Result>) {
        seal.resolve(result, error)
    }
}
