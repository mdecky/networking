import Foundation
import Networking
import XCTest

final class ParameterEncodingTests: XCTestCase {
    func testJSONParametersEncoding() throws {
        struct TestBody: Encodable {
            let test: String
        }
        
        let encoder = JSONBodyParameters(TestBody(test: "test"))
        let request = URLRequest(url: URL(string: "https://test.com/test")!)
        let encodedRequest = try encoder.encodeParameters(into: request)
        XCTAssertEqual(encodedRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(encodedRequest.httpBody)
    }
    
    func testURLParametersEncoding() throws {
        let encoder = URLQueryParameters(["test":"test"])
        let request = URLRequest(url: URL(string: "https://test.com/test")!)
        let encodedRequest = try encoder.encodeParameters(into: request)
        XCTAssertEqual(encodedRequest.url?.query, "test=test")
        XCTAssertNil(encodedRequest.httpBody)
    }
}
