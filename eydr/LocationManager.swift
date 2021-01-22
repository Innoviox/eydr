//
//  LocationManager.swift
//  eydr
//
//  Created by Simon Chervenak on 1/21/21.
//

import Foundation
import CoreLocation
import Combine
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    
    var running = 0 // stopped => 0, paused => 1, running => 2
    var length: Double = 0
    var time: Double = 0
    
    var lastLoc: CLLocation?
    var lastTime = Date()
    
    var route: [CLLocationCoordinate2D] = []
    
    @State var polyline: MKPolyline?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        route.append(CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275))
    }

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }

    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
//        print(#function, statusString)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
//        print(#function, location)
        if lastLocation != nil {
            region.center = lastLocation!.coordinate
            route.append(region.center)
            polyline = MKPolyline(coordinates: route, count: route.count)
            print(route.count)
        }
        
        if running == 2 {
            let now = Date()
            time += lastTime.distance(to: now)
            lastTime = now
            
            if let loc = lastLoc {
//                print(location, loc, location.distance(from: loc))
                length += location.distance(from: loc)
            }
            lastLoc = location
        }
    }
}

extension LocationManager: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 1.0
        
        print("rendering")
    
        return renderer
    }
}
