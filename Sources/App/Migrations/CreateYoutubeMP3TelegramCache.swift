//
//  File.swift
//  
//
//  Created by Koray Koska on 29/9/20.
//

import Fluent

struct CreateYoutubeMP3TelegramCache: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(YoutubeMP3TelegramCache.schema)
            .id()
            .field("telegramId", .string, .required)
            .field("youtubeId", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(YoutubeMP3TelegramCache.schema).delete()
    }
}
