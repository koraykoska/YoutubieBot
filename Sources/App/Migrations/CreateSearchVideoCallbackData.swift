//
//  File.swift
//  
//
//  Created by Koray Koska on 29/9/20.
//

import Fluent

struct CreateSearchVideoCallbackData: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SearchVideoCallbackData.schema)
            .id()
            .field("videoId", .string)
            .field("nextPageToken", .string)
            .field("originalQuery", .string)
            .field("maxResults", .int)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(SearchVideoCallbackData.schema).delete()
    }
}
