import Combine
import Foundation

final class SessionService {
    let dataProvider: DataProviding
    let validation: ResponseValidation
    let decoder: ResponseDecoding

    let baseURL: URL

    init(baseURL: URL, dataProvider: DataProviding, validation: ResponseValidation, decoder: ResponseDecoding) {
        self.dataProvider = dataProvider
        self.validation = validation
        self.decoder = decoder

        self.baseURL = baseURL
    }

    func publisher<R: Request>(for request: R) -> AnyPublisher<R.Response, Error> {
        let requestURL = try! request.urlRequest(baseURL: baseURL)
        return dataProvider.publisher(for: requestURL)
            .map { (request: request, response: $0.response, data: $0.data) }
            .mapError { $0 as Error }
            .flatMap { self.validation.validate(request: $0.request, response: $0.response, data: $0.data) }
            .flatMap { self.decoder.decode(request: request, data: $0) }
            .eraseToAnyPublisher()
    }
}
