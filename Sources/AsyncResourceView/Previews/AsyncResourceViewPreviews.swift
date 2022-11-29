//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

struct AsyncResourceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AsyncResourceView(
                state: .success("Hello World"),
                successView: { text in
                    Text(text)
                }
            )
            .navigationTitle("Static Preview")
        }

        NavigationView {
            AsyncResourceView(
                loader: loader,
                notRequestedView: { load in
                    Button("Load Resource", action: load)
                        .buttonStyle(.borderedProminent)
                },
                successView: { text in
                    Text(text)
                }
            )
            .navigationTitle("Interactive Preview")
        }
    }
}

private let loader: () async throws -> String = {
    try await Task.sleep(nanoseconds: 2_000_000_000)

    if Bool.random() {
        return "Hello World"
    } else {
        throw NSError(domain: "any domain", code: 42, userInfo: nil)
    }
}
