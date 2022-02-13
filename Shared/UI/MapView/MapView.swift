import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel = .init()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.mapRegion, showsUserLocation: true)
                .onAppear {
                    viewModel.attemptLocationAccess()
                }
            MapOverlayView {
                viewModel.attemptLocationAccess()
            }
        }
    }
}

struct MapOverlayView: View {
    private let buttonsSize: CGFloat = 40
    
    var onLocationTapped: () -> ()
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                    .frame(height: 20)
                
                Button {
                    print("Find tapped")
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .frame(width: buttonsSize, height: buttonsSize)
                .background(.white)
                .cornerRadius(buttonsSize / 4)
                
                Spacer()
                
                Button {
                    print("Location tapped")
                    onLocationTapped()
                } label: {
                    Image(systemName: "location")
                }
                .frame(width: buttonsSize, height: buttonsSize)
                .background(.white)
                .cornerRadius(buttonsSize / 4)
                
                Spacer()
                    .frame(height: 50)
            }.padding()
        }
    }
}
