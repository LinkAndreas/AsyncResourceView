//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

public struct AsyncResourceView<Resource>: View {
    public typealias ViewStore = AsyncResourceViewStore<Resource>
    public typealias NotRequestedView = (@escaping () -> Void) -> AnyView
    public typealias LoadingView = () -> AnyView
    public typealias FailureView = (Error, @escaping () -> Void) -> AnyView
    public typealias SuccessView = (Resource) -> AnyView

    @ObservedObject private var store: ViewStore

    private var notRequestedView: NotRequestedView
    private var loadingView: LoadingView
    private var failureView: FailureView
    private var successView: SuccessView

    public init(
        store: ViewStore,
        notRequestedView: @escaping NotRequestedView = { AnyView(AsyncResourceDefaultNotRequestedView(load: $0)) },
        loadingView: @escaping LoadingView = { AnyView(AsyncResourceDefaultLoadingView()) },
        failureView: @escaping FailureView = { AnyView(AsyncResourceDefaultFailureView(error: $0, retry: $1)) },
        successView: @escaping SuccessView
    ) {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public var body: some View {
        switch store.state {
        case .notRequested:
            return notRequestedView(loadResource)

        case .loading:
            return loadingView()

        case let .success(resource):
            return successView(resource)

        case let .failure(error):
            return failureView(error, loadResource)
        }
    }

    private func loadResource() {
        Task { await store.loadResource() }
    }
}
