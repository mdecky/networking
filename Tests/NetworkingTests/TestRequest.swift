//
//  Created by Matěj Děcký on 02.03.2021.
//

import Foundation
import Networking

struct TestRequest: Requestable, CustomResponseErrorProvider {
    let path: String = "/test"
    let method: HTTPMethod? = .get
    let parameters: ParametersEncoding?

    struct Response: Decodable {
        let text: String
    }

    init(responseType: ResponseType) {
        parameters = URLQueryParameters(["response": responseType.rawValue])
    }
    
    func error(for data: Data?, response: URLResponse) -> Error {
        guard let data = data,
              let error = try? JSONDecoder().decode(ResponseError.self, from: data)
        else {
            return URLError(.badURL)
        }
        return error
    }

    struct ResponseError: Error, Decodable {
        let message: String

        enum CodingKeys: String, CodingKey {
            case message = "error"
        }
    }
}

extension TestRequest {
    enum ResponseType: String, CaseIterable {
        case noConnection, invalidData, requestCustomError, statusCodeError, success
    }
}
