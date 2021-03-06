//  Copyright © 2022 Andreas Link. All rights reserved.

import XCTest
import AsyncResourceView

final class AsyncResourceViewStoreTests: XCTestCase {
    func test_store_entersNotRequestedStateOnInit() {
        let (sut, _) = makeSUT()

        expectState(of: sut, toEqual: .notRequested)
    }

    func test_store_entersSuccessStateWhenResourceLoadingSucceeded() async throws {
        let anyText = "any Text"
        let (sut, loaderStub) = makeSUT()

        loaderStub.loadResult = .success(anyText)
        await sut.loadResource()

        expectState(of: sut, toEqual: .success(anyText))
    }

    func test_store_entersFailureStateWhenResourceLoadingFailed() async throws {
        let error = anyNSError()
        let (sut, loaderStub) = makeSUT()

        loaderStub.loadResult = .failure(error)
        await sut.loadResource()

        expectState(of: sut, toEqual: .failure(error))
    }

    func test_store_entersSuccessStateAfterResourceLoadingInitiallyFailed() async throws {
        let anyText = "any Text"
        let error = anyNSError()
        let (sut, loaderStub) = makeSUT()

        loaderStub.loadResult = .failure(error)
        await sut.loadResource()

        expectState(of: sut, toEqual: .failure(error))

        loaderStub.loadResult = .success(anyText)
        await sut.loadResource()

        expectState(of: sut, toEqual: .success(anyText))
    }
}

extension AsyncResourceViewStoreTests {
    typealias SUT = AsyncResourceViewStore<String>

    private func makeSUT(expectedResult: Result<String, Error> = .success("")) -> (SUT, LoaderStub) {
        let stub = LoaderStub()
        let sut = SUT(loader: stub.load)
        return (sut, stub)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any domain", code: 42, userInfo: nil)
    }

    private func expectState(
        of sut: SUT,
        toEqual expectedState: SUT.State,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch (sut.state, expectedState) {
        case (.notRequested, .notRequested), (.loading, .loading), (.success, .success):
            break

        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)

        default:
            XCTFail("State \(sut.state), does not match \(expectedState)", file: file, line: line)
        }
    }

    private class LoaderStub {
        var loadResult: Result<String, Error>!

        func load() async throws -> String {
            switch loadResult! {
            case let .success(text):
                return text

            case let .failure(error):
                throw error
            }
        }
    }
}
