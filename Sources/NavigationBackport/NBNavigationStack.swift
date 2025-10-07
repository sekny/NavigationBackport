import Foundation
import SwiftUI
import SwiftUIBackports

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
public struct NBNavigationStack<Root: View, Data: Hashable>: View {
	var unownedPath: Binding<[Data]>?
	@State var ownedPath: [Data] = []
	@Backport.StateObject var destinationBuilder = DestinationBuilderHolder()
	@Backport.StateObject var navigator: Navigator<Data> = .init(.constant([]))
	
	var root: Root
	
	var path: Binding<[Data]> {
		unownedPath ?? $ownedPath
	}
	
	var erasedPath: Binding<[AnyHashable]> {
		return Binding(
			get: { path.wrappedValue.map(AnyHashable.init) },
			set: { newValue in
				path.wrappedValue = newValue.map { anyHashable in
					guard let data = anyHashable.base as? Data else {
						fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
					}
					return data
				}
			}
		)
	}
	
	public var body: some View {
		NavigationView {
			Router(rootView: root, screens: path)
				.environmentObject(NavigationPathHolder(erasedPath))
				.environmentObject(destinationBuilder)
				
				.onFirstAppear {
					// We can only access the StateObject once the view has been added to the view tree.
					navigator.pathBinding = path
				}
		}.navigationViewStyle(supportedNavigationViewStyle)
			.environmentObject(navigator)
			
	}
	
	public init(path: Binding<[Data]>?, @ViewBuilder root: () -> Root) {
		self.unownedPath = path
		self.root = root()
		
		self.navigator.pathBinding = self.path
	}
}

public extension NBNavigationStack where Data == AnyHashable {
	init(@ViewBuilder root: () -> Root) {
		self.init(path: nil, root: root)
	}
}

public extension NBNavigationStack where Data == AnyHashable {
	init(path: Binding<NBNavigationPath>, @ViewBuilder root: () -> Root) {
		let path = Binding(
			get: { path.wrappedValue.elements },
			set: { path.wrappedValue.elements = $0 }
		)
		self.init(path: path, root: root)
	}
}

private var supportedNavigationViewStyle: some NavigationViewStyle {
#if os(macOS)
	.automatic
#else
	.stack
#endif
}
