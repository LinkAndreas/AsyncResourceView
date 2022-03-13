# AsyncResourceView - Simplified Resource Loading

## Motivation

Today we are going to take a look at how we can deal with asynchronous data in SwiftUI applications. Modern apps heavily rely on resources that are received over the network, and hence may be affected by connectivity issues or data loss. If, for example, you travel by train within Germany, you may be surprised how often you will experience radio gaps or interruptions due to weak cellular reception. Hence, we as developers have to design our apps to include feedback when an action takes longer than expected and offer the ability to retry the action in case that it failed. This way, we can make our apps stand out, since they can cope with conditions that are far from optimal.

This article introduces the reusable component `AsyncResourceView` that abstracts loading as well as failure states when fetching asynchronous data, such that we can focus on features rather than writing repetitive error-prone code.

## View Store

First, let's implement the `AsyncResourceViewStore<Resource>` that is responsible for driving the UI. Given the loader, the store initially remains in the `notRequested` state until `loadResource` is called and the `loading` state is entered. Finally, depending on the result of the operation, either the `success` or `failure` state is entered.

Note that the store is independent of SwiftUI and may be used with an alternative UI framework in the future. In addition, we ensure that state changes only occur on the main thread using the `@MainActor` annotation:

```swift
public final class AsyncResourceViewStore<Resource>: ObservableObject {
    public typealias Loader = () async throws -> Resource

    public enum State {
        case notRequested
        case loading
        case success(Resource)
        case failure(Error)
    }

    @Published public var state: State

    private var loader: Loader?

    public init(state: State = .notRequested, loader: Loader? = nil) {
        self.state = state
        self.loader = loader
    }

    @MainActor
    public func loadResource() async {
        guard let loader = loader else { return }

        state = .loading

        do {
            let resource = try await loader()
            state = .success(resource)
        } catch {
            state = .failure(error)
        }
    }
}
```

## Testing

Even though its implementation looks simple, let's include unit tests to ensure that we are free to refactor the store in the future without changing its behavior. 

First, the store should be in the `notRequested` state. The `makeSUT` helper instantiates the `AsyncResourceViewStore` with a loader stub, such that we have control over its outcome when making assertions about the expected behavior.

Second, we expect the store to enter the `success` state when the resource loading succeeded. Similarly, we expect the store to enter the `failure` state in case that the resource loading failed.

Finally, we also expect the store to enter the `success` state after the resource loading initially failed but later succeeded. This way, we ensure that the user will have the option to retry the action in case that it failed.

```swift
final class AsyncResourceViewStoreTests: XCTestCase {
    func test_store_entersNotRequestedStateOnInit() {
        let (sut, _) = makeSUT()

        expectState(of: sut, toEqual: .notRequested)
    }

    func test_store_entersSuccessStateWhenResourceLoadingSucceeded() async throws {
        let anyText = "any Text"
        let (sut, loaderStub) = makeSUT()

        loaderStub.loadResult = .success(anyText)
        await sut.loadResource()

        expectState(of: sut, toEqual: .success(anyText))
    }

    func test_store_entersFailureStateWhenResourceLoadingFailed() async throws {
        let error = anyNSError()
        let (sut, loaderStub) = makeSUT()

        loaderStub.loadResult = .failure(error)
        await sut.loadResource()

        expectState(of: sut, toEqual: .failure(error))
    }

    func test_store_entersSuccessStateAfterResourceLoadingInitiallyFailed() async throws {
        let anyText = "any Text"
        let error = anyNSError()
        let (sut, loaderStub) = makeSUT()

        loaderStub.loadResult = .failure(error)
        await sut.loadResource()

        expectState(of: sut, toEqual: .failure(error))

        loaderStub.loadResult = .success(anyText)
        await sut.loadResource()

        expectState(of: sut, toEqual: .success(anyText))
    }
}

extension AsyncResourceViewStoreTests {
    typealias SUT = AsyncResourceViewStore<String>

    private func makeSUT(expectedResult: Result<String, Error> = .success("")) -> (SUT, LoaderStub) {
        let stub = LoaderStub()
        let sut = SUT(loader: stub.load)
        return (sut, stub)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any domain", code: 42, userInfo: nil)
    }

    private func expectState(
        of sut: SUT,
        toEqual expectedState: SUT.State,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch (sut.state, expectedState) {
        case (.notRequested, .notRequested), (.loading, .loading), (.success, .success):
            break

        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)

        default:
            XCTFail("State \(sut.state), does not match \(expectedState)", file: file, line: line)
        }
    }

    private class LoaderStub {
        var loadResult: Result<String, Error>!

        func load() async throws -> String {
            switch loadResult! {
            case let .success(text):
                return text

            case let .failure(error):
                throw error
            }
        }
    }
}
```

## View

As we completed the store, let's continue with the `AsyncResourceView` that renders its children using the state-specific closures. While the `notRequested-`, `failure-` and `loading-` views are optional, we are required to specify the `success` view given the resource. This way, we can break down complexity and only have to deal with a single instead of multiple states at once.

```swift
public struct AsyncResourceView<Resource>: View {
    public typealias ViewStore = AsyncResourceViewStore<Resource>
    public typealias NotRequestedView = (@escaping () -> Void) -> AnyView
    public typealias LoadingView = () -> AnyView
    public typealias FailureView = (Error, @escaping () -> Void) -> AnyView
    public typealias SuccessView = (Resource) -> AnyView

    @ObservedObject private var store: ViewStore

    private var notRequestedView: NotRequestedView
    private var loadingView: LoadingView
    private var failureView: FailureView
    private var successView: SuccessView

    public init(
        store: ViewStore,
        notRequestedView: @escaping NotRequestedView = { AnyView(AsyncResourceDefaultNotRequestedView(load: $0)) },
        loadingView: @escaping LoadingView = { AnyView(AsyncResourceDefaultLoadingView()) },
        failureView: @escaping FailureView = { AnyView(AsyncResourceDefaultFailureView(error: $0, retry: $1)) },
        successView: @escaping SuccessView
    ) {
        self.store = store
        self.notRequestedView = notRequestedView
        self.loadingView = loadingView
        self.failureView = failureView
        self.successView = successView
    }

    public var body: some View {
        switch store.state {
        case .notRequested:
            return notRequestedView(loadResource)

        case .loading:
            return loadingView()

        case let .success(resource):
            return successView(resource)

        case let .failure(error):
            return failureView(error, loadResource)
        }
    }

    private func loadResource() {
        Task { await store.loadResource() }
    }
}
```

### Default Views

#### AsyncResourceDefaultNotRequestedView

For example, using the `notRequested` view, we can specify how the UI should look like until the resource is requested. Note that the default representation is not visible and is only used to trigger the callback as soon as it appeared. Instead, one can also think of a visual representation that features a button to let the user decide when the action is run.

```swift
public struct AsyncResourceDefaultNotRequestedView: View {
    private let load: () -> Void

    public init(load: @escaping () -> Void) {
        self.load = load
    }

    public var body: some View {
        Color.clear
            .onAppear(perform: load)
    }
}
```

#### AsyncResourceDefaultLoadingView

In contrast, the default `loading` view is visible and will indicate progress until either the *success* or *failure-* state is entered. 

```swift
public struct AsyncResourceDefaultLoadingView: View {
    private let title: String

    public init(title: String = "Loading") {
        self.title = title
    }

    public var body: some View {
        ProgressView(title)
    }
}
```

#### AsyncResourceDefaultFailureView

Finally, in case no `failure` closure exists, the `AsyncResourceDefaultFailureView` renders a counterclockwise arrow to retry the action in case that it failed. Note that custom views may also consider the error to provide additional information about why the action did not work as intended.

```swift
public struct AsyncResourceDefaultFailureView: View {
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
```

## Previews

Undoubtedly, one of the great advantages of SwiftUI over UI Kit is that we can get real-time feedback about how the rendering is composed. This is especially true when dealing with interactive previews that offer great insights into the look and feel of a component. Subsequently, you can find examples for a static as well as interactive preview:

```swift
struct AsyncResourceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AsyncResourceView(
                store: AsyncResourceViewStore(state: .success("Hello World")),
                successView: { text in
                    AnyView(Text(text))
                }
            )
            .navigationTitle("Static Preview")
        }

        NavigationView {
            AsyncResourceView(
                store: AsyncResourceViewStore(loader: loader),
                notRequestedView: { load in
                    AnyView(
                        Button("Load Resource", action: load)
                            .buttonStyle(.borderedProminent)
                    )
                },
                successView: { text in
                    AnyView(Text(text))
                }
            )
            .navigationTitle("Interactive Preview")
        }
    }
}

private let loader: () async throws -> String = {
    try await Task.sleep(nanoseconds: 2_000_000_000)

    if Bool.random() {
        return "Hello World"
    } else {
        throw NSError(domain: "any domain", code: 42, userInfo: nil)
    }
}
```

While the static preview renders itself based on the predefined state of the store, the interactive preview explicitly communicates with the loader and waits until the result is made. Since, the loader may fail, we throw a dice and either return the resource (i.e., “Hello World”) or an error. The latter will result in the failure state, where we can retry the action without leaving the preview.

## Use Case Example: "Color Gallery"

To visualize how the component is used, let's implement a color gallery where items are arranged in a three-column grid. Each item features the `AsyncResourceView` to request its color from the loader that will either return a random color or fail after [0.3, 3.0] seconds. As stated above, a retry button is shown in case the action failed. 

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

## Conclusion

In this article, I presented the `AsyncResourceView`, a consistent way to deal with asynchronous resources in SwiftUI applications. Using the component, we can avoid repetitive code and spend more time on implementing features rather than writing the same loading- or error handling code throughout the App.



