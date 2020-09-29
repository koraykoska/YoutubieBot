@testable import App
import XCTVapor

final class YoutubeApiTests: XCTestCase {

    func testGetVideos() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let youtubeApi = YoutubeApi(token: "AIzaSyAE7hUEor89nZEfa_H_yjQittVg30ptq5c", client: app.client)

        let getVideos = youtubeApi.getVideos(query: "bad guy")

        let expectation = self.expectation(description: "Response")
        var response: YoutubeApi.Response?
        var error: Error?

        getVideos.whenSuccess { r in
            response = r
            expectation.fulfill()
        }
        getVideos.whenFailure { e in
            error = e
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(response, "HTTPError: \(String(describing: error))")
    }
}
