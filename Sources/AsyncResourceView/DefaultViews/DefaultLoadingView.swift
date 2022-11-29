//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

public struct DefaultLoadingView: View {
    private let title: String

    public init(title: String = "Loading") {
        self.title = title
    }

    public var body: some View {
        ProgressView(title)
    }
}

struct DefaultLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultLoadingView()
            .preferredColorScheme(.dark)
    }
}
