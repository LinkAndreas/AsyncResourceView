//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

public struct AsyncResourceView<
    Resource,
    NotRequestedView: View,
    LoadingView: View,
    FailureView: View,
    SuccessView: View
>: View {
    public typealias Loader = () async throws -> Resource
    public typealias NotRequestedViewProvider = (@escaping () -> Void) -> NotRequestedView
    public typealias LoadingViewProvider = () -> LoadingView
    public typealias FailureViewProvider = (Error, @escaping () -> Void) -> FailureView
    public typealias SuccessViewProvider = (Resource) -> SuccessView

    public enum LoadingState {
        case notRequested
        case loading
        case success(Resource)
        case failure(Error)
    }

    @State private var state: LoadingState
    @State private var currentTask: Task<Void, Never>?

    private var loader: Loader?
    private var notRequestedView: NotRequestedViewProvider
    private var loadingView: LoadingViewProvider
    private var failureView: FailureViewProvider
    private var successView: SuccessViewProvider

    public init(
        state: LoadingState = .notRequested,
        loader: Loader? = nil,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider,
        @ViewBuilder loadingView: @escaping LoadingViewProvider,
        @ViewBuilder failureView: @escaping FailureViewProvider,
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) {
        self._state = State(initialValue: state)
        self.loader = loader
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    @ViewBuilder
    public var body: some View {
        switch state {
        case .notRequested:
            notRequestedView(loadResource)

        case .loading:
            loadingView()

        case let .success(resource):
            successView(resource)

        case let .failure(error):
            failureView(error, loadResource)
        }
    }

    private func loadResource() {
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

extension AsyncResourceView {
    public init(
        state: LoadingState = .notRequested,
        loader: Loader? = nil,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider = { DefaultNotRequestedView(load: $0) },
        @ViewBuilder loadingView: @escaping LoadingViewProvider = { DefaultLoadingView() },
        @ViewBuilder failureView: @escaping FailureViewProvider = { DefaultFailureView(error: $0, retry: $1) },
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where NotRequestedView == DefaultNotRequestedView, LoadingView == DefaultLoadingView, FailureView == DefaultFailureView {
        self._state = State(initialValue: state)
        self.loader = loader
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        state: LoadingState = .notRequested,
        loader: Loader? = nil,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider,
        @ViewBuilder loadingView: @escaping LoadingViewProvider = { DefaultLoadingView() },
        @ViewBuilder failureView: @escaping FailureViewProvider = { DefaultFailureView(error: $0, retry: $1) },
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where LoadingView == DefaultLoadingView, FailureView == DefaultFailureView {
        self._state = State(initialValue: state)
        self.loader = loader
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        state: LoadingState = .notRequested,
        loader: Loader? = nil,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider = { DefaultNotRequestedView(load: $0) },
        @ViewBuilder loadingView: @escaping LoadingViewProvider,
        @ViewBuilder failureView: @escaping FailureViewProvider = { DefaultFailureView(error: $0, retry: $1) },
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where NotRequestedView == DefaultNotRequestedView, FailureView == DefaultFailureView {
        self._state = State(initialValue: state)
        self.loader = loader
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        state: LoadingState = .notRequested,
        loader: Loader? = nil,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider = { DefaultNotRequestedView(load: $0) },
        @ViewBuilder loadingView: @escaping LoadingViewProvider = { DefaultLoadingView() },
        @ViewBuilder failureView: @escaping FailureViewProvider,
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where NotRequestedView == DefaultNotRequestedView, LoadingView == DefaultLoadingView {
        self._state = State(initialValue: state)
        self.loader = loader
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        state: LoadingState = .notRequested,
        loader: Loader? = nil,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider,
        @ViewBuilder loadingView: @escaping LoadingViewProvider,
        @ViewBuilder failureView: @escaping FailureViewProvider = { DefaultFailureView(error: $0, retry: $1) },
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where FailureView == DefaultFailureView {
        self._state = State(initialValue: state)
        self.loader = loader
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        state: LoadingState = .notRequested,
        loader: Loader? = nil,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider,
        @ViewBuilder loadingView: @escaping LoadingViewProvider = { DefaultLoadingView() },
        @ViewBuilder failureView: @escaping FailureViewProvider,
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where LoadingView == DefaultLoadingView {
        self._state = State(initialValue: state)
        self.loader = loader
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        state: LoadingState = .notRequested,
        loader: Loader? = nil,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider = { DefaultNotRequestedView(load: $0) },
        @ViewBuilder loadingView: @escaping LoadingViewProvider,
        @ViewBuilder failureView: @escaping FailureViewProvider,
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where NotRequestedView == DefaultNotRequestedView {
        self._state = State(initialValue: state)
        self.loader = loader
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }
}
