import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    let baseURL = URL(string: "http://test.com")!
    
    lazy var session = SessionService(
        baseURL: self.baseURL,
        dataProvider: MockSession.testSession(baseURL: self.baseURL),
        validation: HTTPResponseValidator(),
        decoder: JSONResponseDecoder()
    )

    func testNoConnectionFailure() throws {
        let request = TestRequest(responseType: .noConnection)

        let publisher = session.send(request: request)
        let error = try expectError(publisher)
        
        XCTAssertEqual((error as? URLError), URLError(.notConnectedToInternet))
    }

    func testServerErrorRequest() throws {
        let request = TestRequest(responseType: .statusCodeError)

        let publisher = session.send(request: request)
        let error = try expectError(publisher)
        
        XCTAssert(error is HTTPValidationError)
    }

    func testRequestErrorRequest() throws {
        let request = TestRequest(responseType: .requestCustomError)

        let publisher = session.send(request: request)
        let error = try expectError(publisher)
        
        XCTAssert(error is TestRequest.ResponseError)
    }

    func testInvalidDecodingRequest() throws {
        let request = TestRequest(responseType: .invalidData)
        
        let publisher = session.send(request: request)
        let error = try expectError(publisher)
        
        XCTAssert(error is DecodingError)
    }

    func testSuccessRequest() throws {
        let request = TestRequest(responseType: .success)

        let publisher = session.send(request: request)
        let output = try expectValue(publisher)
            
        XCTAssertEqual(output.text, "success")
    }
}
