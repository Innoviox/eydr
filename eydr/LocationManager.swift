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

    var polyline: MKPolyline?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
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

            route.append(region.center)
            updatePoly()
        }
    }
}

extension LocationManager: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 1.0

        return renderer
    }
}

extension LocationManager {
    var infoString: String {
        get {
            let t = Int(time)
            let p = length == 0 ? 0 : (time / (length / 1609.34)) / 60
            return String(format: "Distance: %02.2fmi\nTime    : %02d:%02d:%02d\nSpeed   : %02.2fmph\nPace    : %02d:%02dmin/mi", length / 1609.34, t / 3600, (t % 3600) / 60, t % 60, length / time, Int(p), Int((p - Double(Int(p))) * 60))
        }
    }

    func update(_ i: Item) {
//        return
        print("UPDATING", i.time, i.length)
        self.running = Int(i.running)

        if let route = i.route {
            do {
//                let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: Route.self, from: route as! Data)
//                self.route = data?.toRoute() ?? []
                self.route = (route as! Route).toRoute()
            } catch {
                print("UPDATING7 error loading route \(error)")
            }
        } else {
            self.route = []
        }

        self.time = i.time
        self.length = i.length

        self.updatePoly()
    }

    func updatePoly() {
        polyline = MKPolyline(coordinates: route, count: route.count)
    }
}

class Route: NSObject {
    enum Keys: String {
      case coords = "coords"
    }
    
    var coords: [[Double]] = []

    required convenience init?(coder aDecoder: NSCoder) {
        let coords = aDecoder.decodeObject(forKey: Keys.coords.rawValue) as! [[Double]]
        aDecoder.decodeData()

        self.init(coords)
    }

    init(_ route: [CLLocationCoordinate2D]) {
        coords = []
        for i in route {
            coords.append([i.latitude, i.longitude])
        }
        print("UPDATING made route", coords)
    }
    
    init(_ coords: [[Double]]) {
        self.coords = coords
    }

    func toRoute() -> [CLLocationCoordinate2D] {
        return coords.map { i in
            CLLocationCoordinate2D(latitude: i[0], longitude: i[1])
        }
    }
}

extension Route: NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(coords)
    }
}

extension Route: NSSecureCoding {
    static var supportsSecureCoding: Bool {
        true
    }
}
