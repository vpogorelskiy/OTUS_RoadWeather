import Foundation
import SwiftUI

struct RoutesView: View {
    @ObservedObject var viewModel: RoutesViewModel = .init()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.routes.count > 0 {
                    List {
                        ForEach(viewModel.routes) { route in
                            Text(route.title)
                        }
                    }
                } else {
                    Text("No saved routes")
                }
            }.navigationTitle("Saved routes")
        }
    }
}
