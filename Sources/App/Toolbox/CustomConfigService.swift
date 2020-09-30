//
//  File.swift
//  
//
//  Created by Koray Koska on 24/9/20.
//

import Foundation
import Vapor

public struct CustomConfigService {

    init(env: Environment.Type) {
        self.telegramToken = env.get("TELEGRAM_TOKEN")!
        self.botName = env.get("BOT_NAME")!
        self.youtubeApiKey = env.get("YOUTUBE_API_KEY")!
        self.youtubeCookies = env.get("YOUTUBE_COOKIES")!
    }

    public let telegramToken: String

    public let botName: String

    public let youtubeApiKey: String

    public let youtubeCookies: String
}

extension Application {

    var customConfigService: CustomConfigService {
        .init(env: Environment.self)
    }
}
