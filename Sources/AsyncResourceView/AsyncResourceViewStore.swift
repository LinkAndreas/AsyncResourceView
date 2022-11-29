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
    private var currentTask: Task<Void, Never>?

    public init(state: State = .notRequested, loader: Loader? = nil) {
        self.state = state
        self.loader = loader
    }

    public func loadResource() {
        guard let loader = loader else { return }

        state = .loading
        currentTask = Task { @MainActor in
            do {
                let resource = try await loader()
                state = .success(resource)
            } catch {
                state = .failure(error)
            }
        }
    }
}
