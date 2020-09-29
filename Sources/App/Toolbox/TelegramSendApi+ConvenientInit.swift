//
//  File.swift
//  
//
//  Created by Koray Koska on 28/9/20.
//

import Foundation
import TelegramBot
import Dispatch
#if os(Linux)
import FoundationNetworking
#endif

extension TelegramSendApi {

    convenience init(token: String, sleep: UInt32 = 1) {
        self.init(token: token, provider: TelegramApiSequentialHttpProvider(url: "https://api.telegram.org/bot\(token)", sleep: sleep))
    }
}

public struct TelegramApiSequentialHttpProvider: TelegramApiProvider {

    let encoder: JSONEncoder
    let decoder: JSONDecoder

    let queue: DispatchQueue

    let session: URLSession

    static let headers = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]

    public let url: String

    public let sleep: UInt32

    public init(url: String, sleep: UInt32 = 1, session: URLSession = URLSession(configuration: .default)) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder

        self.url = url
        self.session = session

        self.sleep = sleep

        self.queue = DispatchQueue(label: "TelegramApiHttpProvider")
    }

    public func send<Params: Codable, Result>(method: String, request: Params, response: @escaping TelegramApiResponseCompletion<Result>) {
        queue.async {

            let body: Data
            do {
                body = try self.encoder.encode(request)
            } catch {
                let err = TelegramResponse<Result>(error: .requestFailed(error))
                response(err)
                return
            }

            guard let url = URL(string: "\(self.url)/\(method)") else {
                let err = TelegramResponse<Result>(error: .requestFailed(nil))
                response(err)
                return
            }

            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.httpBody = body
            for (k, v) in type(of: self).headers {
                req.addValue(v, forHTTPHeaderField: k)
            }

            let task = self.session.dataTask(with: req) { data, urlResponse, error in
                guard let urlResponse = urlResponse as? HTTPURLResponse, let data = data, error == nil else {
                    let err = TelegramResponse<Result>(error: .serverError(error))
                    response(err)
                    return
                }

                let status = urlResponse.statusCode
                guard status >= 200 && status < 300 else {
                    // This is a non typical error response and should be considered a server error.
                    let err = TelegramResponse<Result>(error: .serverError(nil))
                    response(err)
                    return
                }

                do {
                    let decoded = try self.decoder.decode(TelegramApiResponse<Result>.self, from: data)
                    // We got the Result object
                    let res = TelegramResponse(response: decoded)
                    response(res)
                } catch {
                    // We don't have the response we expected...
                    let err = TelegramResponse<Result>(error: .decodingError(error))
                    response(err)
                }
            }
            task.resume()

            usleep(self.sleep)
        }
    }
}
