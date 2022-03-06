//  Copyright © 2022 Andreas Link. All rights reserved.

import AsyncResourceView
import SwiftUI

@main
struct SimpleExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AsyncResourceView(
                    store: AsyncResourceView.ViewStore(loader: { () -> Int in
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        return 42
                    }),
                    notRequestedView: { load in
                        AnyView(
                            Button("Load Resource", action: load)
                                .buttonStyle(.borderedProminent)
                        )
                    },
                    successView: { resource in
                        AnyView(
                            Text(String(describing: resource))
                        )
                    }
                )
                .navigationTitle("Async Resource Demo")
            }
        }
    }
}
