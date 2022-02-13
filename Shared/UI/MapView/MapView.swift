import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel = .init()
    
    var body: some View {
        Map(coordinateRegion: $viewModel.mapRegion)
            .onAppear {
                viewModel.attemptLocationAccess()
            }
    }
}
