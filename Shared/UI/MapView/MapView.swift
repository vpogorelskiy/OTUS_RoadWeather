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
            VStack {
                DebouncingTextField(title: "",
                                    debouncedText: $viewModel.searchText)
                if !viewModel.foundLocations.isEmpty {
                    List {
                        ForEach(viewModel.foundLocations, id: \.location) { location in
                            Button {
                                print("Location selected: \(location)")
                            } label: {
                                Text(location.name ?? "\(location)")
                            }

                            
                        }
                    }.frame(minHeight: 30, maxHeight: 150, alignment: .top)
                }
                Spacer()
            }.padding()
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
