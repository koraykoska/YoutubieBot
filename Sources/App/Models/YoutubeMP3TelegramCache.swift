import Fluent
import Vapor

final class YoutubeMP3TelegramCache: Model, Content {
    static let schema = "youtube_mp3_telegram_cache"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "telegramId")
    var telegramId: String

    @Field(key: "youtubeId")
    var youtubeId: String

    init() { }

    init(id: UUID? = nil, telegramId: String, youtubeId: String) {
        self.id = id
        self.telegramId = telegramId
        self.youtubeId = youtubeId
    }
}
