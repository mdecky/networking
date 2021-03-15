
import Combine
import Foundation

public protocol ResponseDecoding {
    func decode<R: Request>(request: R, data: Data) ->
        AnyPublisher<R.Response, Error>
}

public final class JSONResponseDecoder: ResponseDecoding {
    let decoder: JSONDecoder

    public init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }

    public func decode<R>(request: R, data: Data) -> AnyPublisher<R.Response, Error> where R : Request {
        Just(data)
            .map { (R.Response.self is EmptyResponse.Type) && data.isEmpty ? "{}".data(using: .utf8)! : $0 }
            .decode(type: R.Response.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
