import Foundation
import CoreLocation
import MapKit

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
            print("\(Self.self).\(#function): \(String(describing: lastRoute?.polyline.coordinates))")
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
        guard let destCoordinate = to.location?.coordinate, let map = mapView else { return }
        let from = MKPlacemark(coordinate: userLocation.coordinate)
        let dest = MKPlacemark(coordinate: destCoordinate)
        
        
        print("Searching route from \(from); To: \(to)")
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: from)
        request.destination = MKMapItem(placemark: dest)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            map.addAnnotations([from, dest])
            map.addOverlay(route.polyline)
            map.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                animated: true)
            self.lastRoute = route
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
        print("\(Self.self).\(#function): \(locations)")
        guard let firstLocation = locations.first else {
            return
        }
        
        self.userLocation = firstLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}
