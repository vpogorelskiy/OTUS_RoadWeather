import Foundation
import CoreLocation
import MapKit

class MapViewModel: NSObject, ObservableObject {
    @Published var mapRegion: MKCoordinateRegion = .init() {
        didSet {
//            print("\(Self.self).\(#function): \(mapRegion)")
        }
    }
    
    private let locationManager: CLLocationManager
    private var userLocation: CLLocation = .init() {
        didSet {
            mapRegion = .init(center: userLocation.coordinate, span: mapSpan)
        }
    }
    
    private var mapSpan: MKCoordinateSpan = .init(latitudeDelta: 10,
                                                  longitudeDelta: 10)
    
    override init() {
        locationManager = .init()
        super.init()
        locationManager.delegate = self
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
        //
        //      let commonDelta: CLLocationDegrees = 25 / 111 // 1/111 = 1 latitude km
        //      let span = MKCoordinateSpan(latitudeDelta: commonDelta, longitudeDelta: commonDelta)
        //      let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)
        //
        //      currentRegion = region
        //      completer.region = region
        //
        //      CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
        //        guard let firstPlace = places?.first, self.originTextField.contents == nil else {
        //          return
        //        }
        //
        //        self.currentPlace = firstPlace
        //        self.originTextField.text = firstPlace.abbreviation
        //      }
        //    }
        //
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}
