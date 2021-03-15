//
// Created by Matěj Děcký. 
//  

import Foundation
import Networking

extension URLResponse {
    static let success = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    static let requestFailure = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
    static let failure = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
}

extension HTTPURLResponse {
    convenience init(url: URL, statusCode: Int) {
        self.init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension TestRequest.ResponseType {
    var response: Result<MockSession.Output, URLError> {
        switch self {
        case .success:
            return .success((data: #"{"text":"success"}"#.data(using: .utf8)!, response: .success))
        case .emptySuccess:
            return .success((data: Data(), response: .success))
        case .noConnection:
            return .failure(URLError(.notConnectedToInternet))
        case .invalidData:
            return .success((data: #"{"text2":"success""#.data(using: .utf8)!, response: .success))
        case .statusCodeError:
            return .success((data: "".data(using: .utf8)!, response: .failure))
        case .requestCustomError:
            return .success((data: #"{"error":"error message"}"#.data(using: .utf8)!, response: .requestFailure))
        }
    }
}

extension MockSession {
    static func testSession(baseURL: URL) -> MockSession {
        let responses = TestRequest.ResponseType.allCases.map {
            (request: try! TestRequest(responseType: $0).urlRequest(baseURL: baseURL),
             response: $0.response)
        }
        return MockSession(responses: Dictionary(uniqueKeysWithValues: responses))
    }
}
