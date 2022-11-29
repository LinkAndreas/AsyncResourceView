//  Copyright © 2022 Andreas Link. All rights reserved.

import SwiftUI

public struct DefaultFailureView: View {
    private let error: Error
    private let retry: () -> Void

    public init(error: Error, retry: @escaping () -> Void) {
        self.error = error
        self.retry = retry
    }

    public var body: some View {
        VStack(spacing: 16) {
            Button(action: retry) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 25))
                    .tint(.accentColor)
            }
        }
    }
}

struct DefaultFailureView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: "any Domain", code: 42, userInfo: nil)
        DefaultFailureView(error: error, retry: {})
            .previewLayout(.sizeThatFits)
    }
}
