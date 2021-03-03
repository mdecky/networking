
import Foundation
import Combine

public protocol DataProviding {
    typealias Output = (data: Data, response: URLResponse)
    func publisher(for request: URLRequest) -> AnyPublisher<Output, URLError>
}

public final class URLSessionDataProvider: DataProviding {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func publisher(for request: URLRequest) -> AnyPublisher<Output, URLError> {
        session.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

public final class MockSession: DataProviding {
    private let session: [URLRequest: Result<Output, URLError>]

    public init(responses: [URLRequest: Result<Output, URLError>]) {
        session = responses
    }

    public func publisher(for request: URLRequest) -> AnyPublisher<Output, URLError> {
        guard let response = session[request] else { fatalError() }
        switch response {
        case .success(let output):
            return Just(output)
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: Output.self, failure: error)
                .eraseToAnyPublisher()
        }
    }
}
