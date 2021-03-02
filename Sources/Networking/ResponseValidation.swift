
import Combine
import Foundation

protocol ResponseValidation {
    func validate<Request: Requestable>(
        request: Request, response: URLResponse, data: Data) ->
    AnyPublisher<Data, Error>
}

final class HTTPResponseValidator: ResponseValidation {
    func validate<Request: Requestable>(
        request: Request, response: URLResponse, data: Data) ->
    AnyPublisher<Data, Error>
    {
        Just((request: request, response: response, data: data))
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw URLError(URLError.Code.badServerResponse)
                }
                guard !httpResponse.isCustomRequestError else {
                    throw output.request.error(for: output.data, statusCode: httpResponse.statusCode)
                }
                guard httpResponse.isSuccesfulResponse else {
                    throw HTTPValidationError(response: httpResponse, data: output.data)
                }

                return data
            }
            .eraseToAnyPublisher()
    }
}

struct HTTPValidationError: Error, CustomDebugStringConvertible {
    let response: HTTPURLResponse
    let data: Data

    var debugDescription: String {
        "Request failed on validation with response: \(response) and data in base64: \(data.base64EncodedString())"
    }
}

private extension HTTPURLResponse {
    var isCustomRequestError: Bool {
        return statusCode == 400
    }

    var isSuccesfulResponse: Bool {
        (200..<300).contains(statusCode)
    }
}
