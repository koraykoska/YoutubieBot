//
//  File.swift
//  
//
//  Created by Koray Koska on 28/9/20.
//

import Foundation
import Vapor

struct YoutubeApi {

    enum Error: Swift.Error {

        case httpError(httpStatus: HTTPStatus)
    }

    struct Response: Codable {

        let kind: String
        let etag: String
        let nextPageToken: String?
        let regionCode: String
        let pageInfo: PageInfo
        let items: [Item]

        struct PageInfo: Codable {

            let totalResults: Int
            let resultsPerPage: Int
        }

        struct Item: Codable {

            let kind: String
            let etag: String
            let id: Id
            let snippet: Snippet

            struct Id: Codable {

                let kind: String
                let videoId: String?
            }

            struct Snippet: Codable {

                let publishedAt: String
                let channelId: String
                let title: String
                let description: String
                let thumbnails: Thumbnails
                let channelTitle: String
                let liveBroadcastContent: String
                let publishTime: String

                struct Thumbnails: Codable {

                    private enum CodingKeys: String, CodingKey {
                        case defaultThumbnail = "default"
                        case mediumThumbnail = "medium"
                        case highThumbnail = "high"
                    }

                    let defaultThumbnail: Thumbnail
                    let mediumThumbnail: Thumbnail
                    let highThumbnail: Thumbnail

                    struct Thumbnail: Codable {

                        let url: String
                        let width: Int
                        let height: Int
                    }
                }
            }
        }
    }

    let token: String

    let client: Client

    init(token: String, client: Client) {
        self.token = token
        self.client = client
    }

    func getVideos(query: String, maxResults: Int = 5, pageToken: String? = nil) -> EventLoopFuture<Response> {
        var uriQuery = "part=snippet"
        uriQuery += "&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        uriQuery += "&type=video"
        uriQuery += "&maxResults=\(maxResults)"
        uriQuery += "&key=\(token)"
        if let pageToken = pageToken {
            uriQuery += "&pageToken=\(pageToken)"
        }
        let uri = URI(string: "https://www.googleapis.com/youtube/v3/search?\(uriQuery)")

        let req = ClientRequest(
            method: .GET,
            url: uri,
            headers: HTTPHeaders([("Accept", "application/json")]),
            body: nil
        )

        return client.send(req).flatMapThrowing { clientResponse -> Response in
            if clientResponse.status == .ok {
                return try clientResponse.content.decode(Response.self)
            } else {
                throw Error.httpError(httpStatus: clientResponse.status)
            }
        }
    }

    func getVideoById(id: String) -> EventLoopFuture<Response.Item?> {
        let videoUrl = "https://www.youtube.com/watch?v=\(id)"

        var uriQuery = "part=snippet"
        uriQuery += "&q=\(videoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        uriQuery += "&type=video"
        uriQuery += "&key=\(token)"
        let uri = URI(string: "https://www.googleapis.com/youtube/v3/search?\(uriQuery)")

        let req = ClientRequest(
            method: .GET,
            url: uri,
            headers: HTTPHeaders([("Accept", "application/json")]),
            body: nil
        )

        return client.send(req).flatMapThrowing { clientResponse -> Response.Item? in
            if clientResponse.status == .ok {
                let response = try clientResponse.content.decode(Response.self)

                if response.items.count > 0 {
                    return response.items[0]
                } else {
                    return nil
                }
            } else {
                throw Error.httpError(httpStatus: clientResponse.status)
            }
        }
    }
}
