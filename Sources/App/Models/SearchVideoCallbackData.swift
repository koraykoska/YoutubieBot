import Fluent
import Vapor

final class SearchVideoCallbackData: Model, Content {
    static let schema = "search_video_callback_data"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "videoId")
    var videoId: String?

    @Field(key: "nextPageToken")
    var nextPageToken: String?

    @Field(key: "originalQuery")
    var originalQuery: String?

    @Field(key: "maxResults")
    var maxResults: Int?

    init() { }

    init(id: UUID? = nil, videoId: String) {
        self.id = id
        self.videoId = videoId
    }

    init(id: UUID? = nil, nextPageToken: String, originalQuery: String, maxResults: Int) {
        self.id = id
        self.nextPageToken = nextPageToken
        self.originalQuery = originalQuery
        self.maxResults = maxResults
    }
}
