import Foundation
import SwiftUI

struct SavedRoutesView: View {
    @ObservedObject var viewModel: SavedRoutesViewModel = .init()
    
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
