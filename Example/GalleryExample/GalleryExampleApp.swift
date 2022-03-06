//  Copyright © 2022 Andreas Link. All rights reserved.

import AsyncResourceView
import SwiftUI

@main
struct AsyncResourceGalleryApp: App {
    @StateObject
    private var store: GalleryStore = .init()

    var body: some Scene {
        WindowGroup {
            GalleryView(
                store: store,
                itemView: { item -> AnyView in
                    let store = AsyncResourceViewStore<Color>(loader: loader(item))
                    return AnyView(GalleryItemView(store: store))
                }
            )
            .onAppear(perform: store.onAppear)
        }
    }
}

extension AsyncResourceGalleryApp {
    private func loader(_ item: GalleryItem) -> (() async throws -> Color) {
        return {
            let duration = UInt64.random(in: 300_000_000 ... 3_000_000_000)
            try await Task.sleep(nanoseconds: duration)
            if Int.random(in: 0...5) == 4 {
                throw NSError(domain: "", code: 42, userInfo: nil)
            } else {
                return item.color
            }
        }
    }
}
