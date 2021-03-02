
import Combine
import Compression
import Foundation

protocol ResponseDecoding {
    func decode<Request: Requestable>(
        request: Request, data: Data) ->
    AnyPublisher<Request.Response, Error>
}

final class JSONResponseDecoder: ResponseDecoding {
    let decoder: JSONDecoder

    init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }

    func decode<Request>(request: Request, data: Data) -> AnyPublisher<Request.Response, Error> where Request : Requestable {
        Just(data)
            .decode(type: Request.Response.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
