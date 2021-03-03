//
// Created by Matěj Děcký. 
//  

import Combine
import Foundation
import XCTest

extension XCTestCase {
    func expectValue<T: Publisher>(
        _ publisher: T,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }
            },
            receiveValue: { value in
                result = .success(value)
            }
        )
        cancellable.cancel()

        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }
    
    func expectError<T: Publisher>(
        _ publisher: T,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Failure {
        var result: Result<T.Output, T.Failure>?

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }
            },
            receiveValue: { value in
                result = .success(value)
            }
        )
        cancellable.cancel()

        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        switch unwrappedResult {
        case .failure(let error):
            return error
        case .success:
            XCTFail("Expected error but get value")
            fatalError()
        }
    }
}
