import Foundation
import CoreLocation
import MapKit

extension MapViewModel {
    enum Constants {
        static let weatherPinsCount = 10
    }
}

class MapViewModel: NSObject, ObservableObject {
    @Published var mapRegion: MKCoordinateRegion = .init() {
        didSet {
            
        }
    }
    
    weak var mapView: MKMapView?
    
    var searchText: String = "" {
        didSet {
            print("\(Self.self).\(#function): \(searchText)")
            updateFoundLocations(searchText)
        }
    }
    
    @Published var destination: CLLocation?
    
    @Published var foundLocations: [CLPlacemark] = [] {
        didSet {
//            print("\(Self.self).\(#function): \(foundLocations)")
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
    private var lastRoute: MKRoute? {
        didSet {
//            print("\(Self.self).\(#function): \(String(describing: lastRoute?.polyline.coordinates))")
        }
    }
    
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
    
    func buildRoute(to: CLPlacemark) {
        guard let map = mapView else { return }
        
        
        geoCoder.reverseGeocodeLocation(userLocation) { placemarks, error in
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
                map.removeAnnotations(map.annotations)
                map.removeOverlays(map.overlays)
                map.addAnnotations([from, dest])
                map.addOverlay(route.polyline)
                map.setVisibleMapRect(
                    route.polyline.boundingMapRect,
                    edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                    animated: true)
                self.lastRoute = route
                self.getWeather(for: route)
            }
        }
    }
    
    func getWeather(for route: MKRoute) {
        print("\(Self.self).\(#function); route.polyline.coordinates.count: \(route.polyline.coordinates.count)")
        let routeCoordinates = route.polyline.coordinates
        let step = routeCoordinates.count / Constants.weatherPinsCount
        let chunked = routeCoordinates.enumerated().compactMap { enumerated in
            return enumerated.offset % step == 0 ? enumerated.element : nil
        }
        print("\(Self.self).\(#function); chunked.count: \(chunked.count)")
        weatherManager.getWeather(for: chunked) { responses in
            print("\(Self.self).\(#function): Count: \(responses.count); \n \(responses)")
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
}

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("\(Self.self).\(#function): \(locations)")
        guard let firstLocation = locations.first else {
            return
        }
        
        self.userLocation = firstLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}
