//
//  MapView.swift
//  eydr
//
//  Created by Simon Chervenak on 1/22/21.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var route: MKPolyline?
    var locationManager: LocationManager!

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.setRegion(locationManager.region, animated: false)
        map.showsUserLocation = true

        return map
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.delegate = locationManager
        view.translatesAutoresizingMaskIntoConstraints = false
        addRoute(to: view)
    }
}

private extension MapView {
    func addRoute(to view: MKMapView) {
        if !view.overlays.isEmpty {
            view.removeOverlays(view.overlays)
        }

        guard let route = route else { return }
        let mapRect = route.boundingMapRect
        view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
        view.addOverlay(route)
    }
}
