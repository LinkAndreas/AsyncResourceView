//  Copyright © 2022 Andreas Link. All rights reserved.

import AsyncResourceView
import SwiftUI

@main
struct SimpleExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AsyncResourceView(
                    store: AsyncResourceViewStore(loader: loader),
                    notRequestedView: notRequestedView(load:),
                    successView: successView(resource:)
                )
                .navigationTitle("Simple Example")
            }
        }
    }

    private func notRequestedView(load: @escaping () -> Void) -> some View {
        Button("Load Resource", action: load)
            .buttonStyle(.borderedProminent)
    }

    private func successView<Resource>(resource: Resource) -> some View {
        Text(String(describing: resource))
    }
}

extension SimpleExampleApp {
    private func loader() async throws -> Int {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return 42
    }
}
