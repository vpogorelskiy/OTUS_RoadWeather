import Foundation
import WeatherApi
import CoreLocation

final class WeatherManager {
    
    private let apiKey = "dfe49e5f10c83f7864f93dd71291aa0f"
    
    func getWeather(for locations: [CLLocationCoordinate2D], completion: @escaping ([ModelResponse]) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        var responses: [ModelResponse] = []
        
        for location in locations {
            group.enter()
            let lat = "\(location.latitude)"
            let lon = "\(location.longitude)"
            GetForecastAPI.getForecast(apiKey: apiKey,
                                       lat: location.latitude,
                                       lon: location.longitude,
                                       units: "metric",
                                       exclude: "daily,hourly,minutely,alerts",
                                       lang: "en",
                                       apiResponseQueue: queue) { data, error in
                print("\(Self.self).\(#function); Lat: \(lat); Lon: \(lon); Response: \(data); Error: \(error)")
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

