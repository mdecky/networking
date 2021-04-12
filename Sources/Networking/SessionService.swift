import Combine
import Foundation

public class SessionService {
    let dataProvider: DataProviding
    let validation: ResponseValidation
    let decoder: ResponseDecoding

    let baseURL: URL

    public init(baseURL: URL, dataProvider: DataProviding, validation: ResponseValidation, decoder: ResponseDecoding) {
        self.dataProvider = dataProvider
        self.validation = validation
        self.decoder = decoder

        self.baseURL = baseURL
    }

    public func publisher<R: Request>(for request: R) -> AnyPublisher<R.Response, Error> {
        return dataProvider.publisher(for: request, baseURL: baseURL)
            .map { (request: request, response: $0.response, data: $0.data) }
            .flatMap { self.validation.validate(request: $0.request, response: $0.response, data: $0.data) }
            .flatMap { self.decoder.decode(request: request, data: $0) }
            .eraseToAnyPublisher()
    }
}
