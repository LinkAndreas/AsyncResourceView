//  Copyright © 2022 Andreas Link. All rights reserved.

import AsyncResourceView
import SwiftUI

struct GalleryItemView: View {
    private let loader: () async throws -> Color

    init(loader: @escaping () async throws -> Color) {
        self.loader = loader
    }

    var body: some View {
        AsyncResourceView(loader: loader) { color in
            color
        }
    }
}
