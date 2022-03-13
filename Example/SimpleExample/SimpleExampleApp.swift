//  Copyright © 2022 Andreas Link. All rights reserved.

import AsyncResourceView
import SwiftUI

@main
struct SimpleExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AsyncResourceView(
                    store: AsyncResourceView.ViewStore(loader: loader),
                    notRequestedView: notRequestedView(load:),
                    successView: successView(resource:)
                )
                .navigationTitle("Async Resource Demo")
            }
        }
    }

    private func notRequestedView(load: @escaping () -> Void) -> AnyView {
        AnyView(
            Button("Load Resource", action: load)
                .buttonStyle(.borderedProminent)
        )
    }

    private func successView<Resource>(resource: Resource) -> AnyView {
        AnyView(
            Text(String(describing: resource))
        )
    }
}

extension SimpleExampleApp {
    private func loader() async throws -> Int {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return 42
    }
}
