
import Foundation
import Combine

public protocol DataProviding {
    typealias Output = (data: Data, response: URLResponse)
    func publisher<R: Request>(for request: R, baseURL: URL) -> AnyPublisher<Output, Error>
}

public final class URLSessionDataProvider: DataProviding {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func publisher<R: Request>(for request: R, baseURL: URL) -> AnyPublisher<Output, Error> {
        Just(baseURL)
            .setFailureType(to: Error.self)
            .tryMap { try request.urlRequest(baseURL: $0) }
            .flatMap { self.session.dataTaskPublisher(for: $0).mapError({ $0 as Error }) }
            .eraseToAnyPublisher()
    }
}

public final class MockSession: DataProviding {
    private let session: [URLRequest: Result<Output, URLError>]

    public init(responses: [URLRequest: Result<Output, URLError>]) {
        session = responses
    }

    public func publisher<R: Request>(for request: R, baseURL: URL) -> AnyPublisher<Output, Error> {
        let request = try! request.urlRequest(baseURL: baseURL)
        guard let response = session[request] else { fatalError() }
        switch response {
        case .success(let output):
            return Just(output)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: Output.self, failure: error)
                .eraseToAnyPublisher()
        }
    }
}
