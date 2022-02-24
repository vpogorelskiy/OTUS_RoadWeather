import Foundation
import WeatherApi
import CoreLocation



final class WeatherManager {
    
    private let apiKey = ""
    
    func getWeather(for locations: [CLLocationCoordinate2D], completion: @escaping ([ModelResponse]) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        var responses: [ModelResponse] = []
        
        for location in locations {
            group.enter()
            GetForecastAPI.getForecast(apiKey: apiKey,
                                       lat: "\(location.latitude)",
                                       lon: "\(location.longitude)",
                                       units: "metric",
                                       exclude: nil,
                                       apiResponseQueue: queue) { data, error in
                if let response = data {
                    responses.append(response)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(responses)
        }
    }
}

