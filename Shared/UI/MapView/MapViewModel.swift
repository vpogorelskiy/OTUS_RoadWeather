import Foundation
import CoreLocation
import MapKit
import WeatherApi

extension MapViewModel {
    enum Constants {
        static let weatherPinsCount = 10
    }
}

enum WeatherDisplay: Int {
    case temperature = 0
    case pressure
    case humidity
    case visibility
    case wind
}

class MapViewModel: NSObject, ObservableObject {
    @Published var mapRegion: MKCoordinateRegion = .init()
    @Published var destination: CLLocation?
    @Published var foundLocations: [CLPlacemark] = []
    @Published var currentRoute: RouteInfo? {
        didSet {
            updateAnnotations()
        }
    }
    
    @Published var displayedWeather: WeatherDisplay = .temperature {
        didSet {
            updateAnnotations()
        }
    }
    
    weak var mapView: MKMapView?
    
    var searchText: String = "" {
        didSet {
            updateFoundLocations(searchText)
            updateFoundMKLocations(searchText)
        }
    }
    
    private let weatherManager = WeatherManager()
    private let locationManager: CLLocationManager
    private let geoCoder: CLGeocoder
    private(set) var userLocation: CLLocation = .init() {
        didSet {
            mapRegion = .init(center: userLocation.coordinate, span: mapSpan)
            mapView?.setRegion(mapRegion, animated: true)
        }
    }
    
    private var mapSpan: MKCoordinateSpan = .init(latitudeDelta: 10,
                                                  longitudeDelta: 10)
    
    override init() {
        locationManager = .init()
        geoCoder = .init()
        super.init()
        locationManager.delegate = self
        attemptLocationAccess()
    }
    
    func updateUserLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func attemptLocationAccess() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }
    
    func resetRoute() {
        currentRoute = nil
    }
    
    func buildRoute(to: CLPlacemark) {
        geoCoder.reverseGeocodeLocation(userLocation) { [weak self] placemarks, error in
            self?.foundLocations = []
            guard let placeMark = placemarks?.first else { return }
            
            let from = MKPlacemark(placemark: placeMark)
            let dest = MKPlacemark(placemark: to)
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: from)
            request.destination = MKMapItem(placemark: dest)
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let route = response?.routes.first else { return }
                self?.currentRoute = RouteInfo(route: route, from: from, to: dest)
                self?.destination = nil
                self?.getWeather(for: route)
            }
        }
    }
    
    func getWeather(for route: MKRoute) {
        let routeCoordinates = route.polyline.coordinates
        let step = routeCoordinates.count / Constants.weatherPinsCount
        let chunked = routeCoordinates.enumerated().compactMap { enumerated in
            return enumerated.offset % step == 0 ? enumerated.element : nil
        }

        weatherManager.getWeather(for: chunked) { [weak self] responses in
            self?.currentRoute?.weatherInfo = responses
            self?.updateAnnotations()
        }
    }
    
    private func updateFoundMKLocations(_ query: String) {
        guard let mapView = mapView, !query.isEmpty else {
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            print("\(Self.self).\(#function): \(response?.mapItems)")
        }
        
    }
    
    private func updateFoundLocations(_ query: String) {
        guard !query.isEmpty else {
            foundLocations = []
            return
        }
        
        geoCoder.geocodeAddressString(query, in: nil, preferredLocale: .init(identifier: "RU")) { [weak self] placemarks, error in
            if let error = error {
                print("\(Self.self).\(#function); ERROR finding location: \(error) ")
            }
            
            guard  query == self?.searchText else { return }
            
            guard let placemarks = placemarks else {
                self?.foundLocations = []
                return
            }
            
            self?.foundLocations = placemarks
        }
    }
    
    private func updateAnnotations() {
        guard let mapView = mapView else { return }
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        if let currentRoute = currentRoute {
            mapView.addAnnotations([currentRoute.from, currentRoute.to])
            mapView.addOverlay(currentRoute.route.polyline)
            mapView.setVisibleMapRect(
                currentRoute.route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                animated: true)
            
            for response in currentRoute.weatherInfo {
                let coordinate = CLLocationCoordinate2D(latitude: response.lat, longitude: response.lon)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                let weather = response.current

                var weatherText = ""
                switch displayedWeather {
                case .temperature:
                    let temp = weather?.temp ?? 0
                    weatherText = (temp > 0 ? "+ " : "")  + "\(temp)"
                case .pressure:
                    weatherText = "\(weather?.pressure ?? 0)"
                case .humidity:
                    weatherText = "\(weather?.humidity ?? 0)"
                case .visibility:
                    weatherText = "\(weather?.visibility ?? 0)"
                case .wind:
                    weatherText = "\(weather?.windSpeed ?? 0)"
                }
                
                annotation.title = weatherText
                
                mapView.addAnnotation(annotation)
            }
        }
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else {
            return
        }
        
        self.userLocation = firstLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}
