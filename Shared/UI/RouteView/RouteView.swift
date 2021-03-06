
import Foundation
import SwiftUI

struct RouteView: View {
    @ObservedObject var viewModel: MapViewModel = .init()
    
    var body: some View {
        ZStack {
            MapView(viewModel: viewModel)
            VStack {
                DebouncingTextField(title: "",
                                    debouncedText: $viewModel.searchText)
                if !viewModel.foundLocations.isEmpty {
                    List {
                        ForEach(viewModel.foundLocations, id: \.location) { location in
                            Button {
                                print("Location selected: \(location)")
                                viewModel.buildRoute(to: location)
                            } label: {
                                Text(location.name ?? "\(location)")
                            }
                            
                            

                            
                        }
                    }.frame(minHeight: 30, maxHeight: 150, alignment: .top)
                }
                if viewModel.currentRoute != nil {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.resetRoute()
                        } label: {
                            Image(systemName: "multiply.circle")
                                .tint(.black)
                                .font(.system(size: 20))
                        }

                    }
                }
                Spacer()
                if viewModel.currentRoute != nil {
                    Picker("Weather display", selection: $viewModel.displayedWeather) {
                        Text("Temperature").tag(WeatherDisplay.temperature)
                        Text("Pressure").tag(WeatherDisplay.pressure)
                        Text("Humidity").tag(WeatherDisplay.humidity)
                        Text("Visibility").tag(WeatherDisplay.visibility)
                        Text("Wind").tag(WeatherDisplay.wind)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(.white)
                }
            }.padding()
        }
    }
}
