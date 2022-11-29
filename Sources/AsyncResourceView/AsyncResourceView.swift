//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

public struct AsyncResourceView<
    Resource,
    NotRequestedView: View,
    LoadingView: View,
    FailureView: View,
    SuccessView: View
>: View {
    public typealias ViewStore = AsyncResourceViewStore<Resource>
    public typealias NotRequestedViewProvider = (@escaping () -> Void) -> NotRequestedView
    public typealias LoadingViewProvider = () -> LoadingView
    public typealias FailureViewProvider = (Error, @escaping () -> Void) -> FailureView
    public typealias SuccessViewProvider = (Resource) -> SuccessView

    @ObservedObject private var store: ViewStore

    private var notRequestedView: NotRequestedViewProvider
    private var loadingView: LoadingViewProvider
    private var failureView: FailureViewProvider
    private var successView: SuccessViewProvider

    public init(
        store: ViewStore,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider,
        @ViewBuilder loadingView: @escaping LoadingViewProvider,
        @ViewBuilder failureView: @escaping FailureViewProvider,
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    @ViewBuilder
    public var body: some View {
        switch store.state {
        case .notRequested:
            notRequestedView(store.loadResource)

        case .loading:
            loadingView()

        case let .success(resource):
            successView(resource)

        case let .failure(error):
            failureView(error, store.loadResource)
        }
    }
}

extension AsyncResourceView {
    public init(
        store: ViewStore,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider = { DefaultNotRequestedView(load: $0) },
        @ViewBuilder loadingView: @escaping LoadingViewProvider = { DefaultLoadingView() },
        @ViewBuilder failureView: @escaping FailureViewProvider = { DefaultFailureView(error: $0, retry: $1) },
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where NotRequestedView == DefaultNotRequestedView, LoadingView == DefaultLoadingView, FailureView == DefaultFailureView {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        store: ViewStore,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider,
        @ViewBuilder loadingView: @escaping LoadingViewProvider = { DefaultLoadingView() },
        @ViewBuilder failureView: @escaping FailureViewProvider = { DefaultFailureView(error: $0, retry: $1) },
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where LoadingView == DefaultLoadingView, FailureView == DefaultFailureView {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        store: ViewStore,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider = { DefaultNotRequestedView(load: $0) },
        @ViewBuilder loadingView: @escaping LoadingViewProvider,
        @ViewBuilder failureView: @escaping FailureViewProvider = { DefaultFailureView(error: $0, retry: $1) },
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where NotRequestedView == DefaultNotRequestedView, FailureView == DefaultFailureView {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        store: ViewStore,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider = { DefaultNotRequestedView(load: $0) },
        @ViewBuilder loadingView: @escaping LoadingViewProvider = { DefaultLoadingView() },
        @ViewBuilder failureView: @escaping FailureViewProvider,
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where NotRequestedView == DefaultNotRequestedView, LoadingView == DefaultLoadingView {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        store: ViewStore,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider,
        @ViewBuilder loadingView: @escaping LoadingViewProvider,
        @ViewBuilder failureView: @escaping FailureViewProvider = { DefaultFailureView(error: $0, retry: $1) },
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where FailureView == DefaultFailureView {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        store: ViewStore,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider,
        @ViewBuilder loadingView: @escaping LoadingViewProvider = { DefaultLoadingView() },
        @ViewBuilder failureView: @escaping FailureViewProvider,
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where LoadingView == DefaultLoadingView {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public init(
        store: ViewStore,
        @ViewBuilder notRequestedView: @escaping NotRequestedViewProvider = { DefaultNotRequestedView(load: $0) },
        @ViewBuilder loadingView: @escaping LoadingViewProvider,
        @ViewBuilder failureView: @escaping FailureViewProvider,
        @ViewBuilder successView: @escaping SuccessViewProvider
    ) where NotRequestedView == DefaultNotRequestedView {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }
}
