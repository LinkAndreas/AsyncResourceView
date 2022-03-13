![](assets/logo_light.png#gh-light-mode-only)
![](assets/logo_dark.png#gh-dark-mode-only)
 
<p align="center">
    <a href="https://github.com/LinkAndreas/AsyncResourceView/releases">
        <img src="https://img.shields.io/badge/Version-1.0.0-2C6075.svg"
             alt="Version: 1.0.0">
    </a>
    <img src="https://img.shields.io/badge/Swift-5.5-ECEBE4.svg"
         alt="Swift: 5.5">
    <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-CC998D.svg"
        alt="Platforms: iOS, macOS">
    <a href="https://github.com/LinkAndreas/AsyncResourceView/blob/develop/LICENSE">
        <img src="https://img.shields.io/badge/License-MIT-5D5D8B.svg"
              alt="License: MIT">
    </a>
</p>

<p align="center">
  • <a href="#motivation">Motivation</a>
  • <a href="#examples">Examples</a>
  • <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#license">License</a>
  • <a href="https://github.com/LinkAndreas/AsyncResourceView/issues">Issues</a>
</p>

## Motivation

Modern apps heavily rely on resources that are received over the network, and hence may be affected by connectivity issues or data loss. If, for example, you travel by train within Germany, you may be surprised how often you will experience radio gaps or interruptions due to weak cellular reception. Hence, we as developers have to design our apps to include feedback when an action takes longer than expected and offer the ability to retry the action in case that it failed. This way, we can make our apps stand out, since they can cope with conditions that are far from optimal.

`AsyncResourceView` offers a consistent way to deal with loading as well as error states in SwiftUI applications. This way, developers can focus on features rather than writing repetitive error-prone code.

## Installation

Installation via [SwiftPM](https://swift.org/package-manager/) is supported.

## Usage

![](assets/simple_example_light.gif#gh-light-mode-only) 
![](assets/simple_example_dark.gif#gh-dark-mode-only)

Using `AsyncResourceView` within your project involves the following steps:

1. Add the package to our project and import `AsyncResourceView` wherever it should be used within our component tree. 

```swift
import AsyncResourceView
```

2. Specify the loader that will provide the requested resource.

```swift
private func loader() async throws -> Int {
    try await Task.sleep(nanoseconds: 2_000_000_000)
    return 42
}
```
3. Provide custom *notRequested*, *loading-* or *failure-* views as desired. Note that the default `notRequested` view is not visible and will request the resource from the loader as soon as the view appeared. In addition, the default *loading-* view wraps SwiftUI's spinner. Finally, the default *failure-* view comes with a counterclockwise error such that the user can retry the action in case that it failed. 

```swift
private func notRequestedView(load: @escaping () -> Void) -> AnyView {
    AnyView(
        Button("Load Resource", action: load)
            .buttonStyle(.borderedProminent)
    )
}

private func successView<Resource>(resource: Resource) -> AnyView {
    AnyView(
        Text(String(describing: resource))
    )
}
```

3. Instantiate the store given the loader and pass it to the `AsyncResourceView`.

```swift
AsyncResourceView(
    store: AsyncResourceView.ViewStore(loader: loader),
    notRequestedView: notRequestedView(load:),
    successView: successView(resource:)
)
```

As a result, we obtain the *Simple Example* where users can request an integer by tapping a button:

```swift
import AsyncResourceView
import SwiftUI

@main
struct SimpleExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AsyncResourceView(
                    store: AsyncResourceView.ViewStore(loader: loader),
                    notRequestedView: notRequestedView(load:),
                    successView: successView(resource:)
                )
                .navigationTitle("Async Resource Demo")
            }
        }
    }

    private func notRequestedView(load: @escaping () -> Void) -> AnyView {
        AnyView(
            Button("Load Resource", action: load)
                .buttonStyle(.borderedProminent)
        )
    }

    private func successView<Resource>(resource: Resource) -> AnyView {
        AnyView(
            Text(String(describing: resource))
        )
    }
}

extension SimpleExampleApp {
    private func loader() async throws -> Int {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return 42
    }
}
```

## Gallery Example

![](assets/gallery_example_light.gif#gh-light-mode-only) 
![](assets/gallery_example_dark.gif#gh-dark-mode-only)

In addition to the *Simple Example*, the package also comes with the *Gallery Example* where colors are arranged in a three-column grid. Each item features the `AsyncResourceView` to request its color from the loader that will either return a random color or fail after [0.3, 3.0] seconds. In the latter case, a retry button is shown in case the action failed. 

```swift
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
```

Since we do not specify a custom `notRequested` view, the default view is used that requests the resource as soon as it appeared. By wrapping the items in SwiftUI's `LazyVGrid` they are only created when needed.

```swift
struct GalleryView: View {
    private var store: GalleryStore
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 50), spacing: 50),
        GridItem(.flexible(minimum: 50), spacing: 50),
        GridItem(.flexible(minimum: 50), spacing: 50)
    ]
    private let itemView: (GalleryItem) -> AnyView

    init(store: GalleryStore, itemView: @escaping (GalleryItem) -> AnyView) {
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
```

Each of the items is driven by its own store, i.e., `AsyncResourceViewStore` that transitions between states depending on how long the action takes.

```swift
struct GalleryItemView: View {
    private let store: AsyncResourceViewStore<Color>

    init(store: AsyncResourceViewStore<Color>) {
        self.store = store
    }

    var body: some View {
        AsyncResourceView(store: store) { color in
            AnyView(color)
        }
    }
}
```

Finally, we create a `GalleryStore` that drives the composition and provides a color for each individual loader.

```swift
final class GalleryStore: ObservableObject {
    @Published var items: [GalleryItem] = []

    func onAppear() {
        items = (0 ..< 100)
            .map { _ in Color.random }
            .map { GalleryItem(color: $0 )}
    }
}

struct GalleryItem: Hashable {
    let id: UUID
    let color: Color

    init(id: UUID = .init(), color: Color) {
        self.id = id
        self.color = color
    }
}
```

## License

This library is released under the [MIT License](http://opensource.org/licenses/MIT). See LICENSE for details.
