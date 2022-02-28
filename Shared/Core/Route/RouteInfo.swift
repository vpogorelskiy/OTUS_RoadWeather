
import Foundation
import MapKit
import WeatherApi

class RouteInfo {
    
    let from: MKPlacemark
    let to: MKPlacemark
    let route: MKRoute
    
    var weatherInfo: [ModelResponse] = []
    
    init(route: MKRoute, from: MKPlacemark, to: MKPlacemark) {
        self.route = route
        self.from = from
        self.to = to
    }
    
}
