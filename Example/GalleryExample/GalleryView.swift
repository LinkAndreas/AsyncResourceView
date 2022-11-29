//  Copyright © 2022 Andreas Link. All rights reserved.

import AsyncResourceView
import SwiftUI

struct GalleryView<ItemView: View>: View {
    private var store: GalleryStore
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 50), spacing: 50),
        GridItem(.flexible(minimum: 50), spacing: 50),
        GridItem(.flexible(minimum: 50), spacing: 50)
    ]
    private let itemView: (GalleryItem) -> ItemView

    init(store: GalleryStore, itemView: @escaping (GalleryItem) -> ItemView) {
        self.store = store
        self.itemView = itemView
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 50) {
                ForEach(store.items, id: \.self) { item in
                    itemView(item)
                        .frame(width: 100, height: 100)
                }
            }
            .padding()
        }
    }
}
