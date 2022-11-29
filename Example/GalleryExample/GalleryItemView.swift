//  Copyright © 2022 Andreas Link. All rights reserved.

import AsyncResourceView
import SwiftUI

struct GalleryItemView: View {
    private let store: AsyncResourceViewStore<Color>

    init(store: AsyncResourceViewStore<Color>) {
        self.store = store
    }

    var body: some View {
        AsyncResourceView(store: store) { color in
            color
        }
    }
}
