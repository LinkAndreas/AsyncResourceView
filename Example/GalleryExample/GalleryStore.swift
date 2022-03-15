//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

final class GalleryStore: ObservableObject {
    @Published var items: [GalleryItem] = []

    func onAppear() {
        items = (0 ..< 100)
            .map { _ in Color.random }
            .map { GalleryItem(color: $0 )}
    }
}

private extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
