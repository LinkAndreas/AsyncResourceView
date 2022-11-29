//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

public struct DefaultNotRequestedView: View {
    private let load: () -> Void

    public init(load: @escaping () -> Void) {
        self.load = load
    }

    public var body: some View {
        Color.clear
            .onAppear(perform: load)
    }
}
