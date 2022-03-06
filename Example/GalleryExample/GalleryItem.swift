//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

struct GalleryItem: Hashable {
    let id: UUID
    let color: Color

    init(id: UUID = .init(), color: Color) {
        self.id = id
        self.color = color
    }
}
