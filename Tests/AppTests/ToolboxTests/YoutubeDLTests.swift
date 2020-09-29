@testable import App
import XCTVapor

final class YoutubeDLTests: XCTestCase {

    func testDownloadMP3() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let youtubeDL = YoutubeDL()

        // print(youtubeDL.downloadMP3(videoId: "TZXcVNb0Mmw"))
    }
}
