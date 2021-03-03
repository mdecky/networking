
import Combine
import Foundation

public protocol ResponseDecoding {
    func decode<Request: Requestable>(request: Request, data: Data) ->
        AnyPublisher<Request.Response, Error>
}

public final class JSONResponseDecoder: ResponseDecoding {
    let decoder: JSONDecoder

    public init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }

    public func decode<Request>(request: Request, data: Data) -> AnyPublisher<Request.Response, Error> where Request : Requestable {
        Just(data)
            .decode(type: Request.Response.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
