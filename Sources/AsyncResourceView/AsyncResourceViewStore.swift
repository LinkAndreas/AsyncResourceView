//  Copyright © 2022 Andreas Link. All rights reserved.

import Foundation

public final class AsyncResourceViewStore<Resource>: ObservableObject {
    public typealias Loader = () async throws -> Resource

    public enum State {
        case notRequested
        case loading
        case success(Resource)
        case failure(Error)
    }

    @Published public var state: State

    private var loader: Loader?

    public init(state: State = .notRequested, loader: Loader? = nil) {
        self.state = state
        self.loader = loader
    }

    @MainActor
    public func loadResource() async {
        guard let loader = loader else { return }

        state = .loading

        do {
            let resource = try await loader()
            state = .success(resource)
        } catch {
            state = .failure(error)
        }
    }
}
