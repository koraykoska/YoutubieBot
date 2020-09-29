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
    }

    public let telegramToken: String

    public let botName: String

    public let youtubeApiKey: String
}

extension Application {

    var customConfigService: CustomConfigService {
        .init(env: Environment.self)
    }
}
