    //
    //  ViewController.swift
    //  MAPBOXV10
    //
    //  Created by Ilya Filinovich on 28.12.2021.
    //

import UIKit
import MapboxMaps
import CoreLocation

class ViewController: UIViewController {

    enum Constants {
        static let coordinates1 = CLLocationCoordinate2D.init(latitude: 59.9302370399789, longitude: 30.3102691832409)
        static let coordinates2 = CLLocationCoordinate2D.init(latitude: 59.9392370399789, longitude: 30.3172691832409)
        static let space: Double = 5
    }

    struct State {

        struct PinState {
            let id: Int
            var originalCoordinates: CLLocationCoordinate2D
            var screenConstrainedCoordinates: CLLocationCoordinate2D
            var resultCoordinates: CLLocationCoordinate2D
            var resultCenter: CGPoint
        }

        var pins: [PinState]
    }

    private lazy var mapView = MapView.defaultInit()
    private let pin1 = PinView(id: 1, text: "Хагги Вагги")
    private let pin2 = PinView(id: 2, text: "Кисси Мисси")

    private var pin1VC: NSLayoutConstraint?
    private var pin1HC: NSLayoutConstraint?
    private var pin2VC: NSLayoutConstraint?
    private var pin2HC: NSLayoutConstraint?
    private var state: State = .init(pins: [
        .init(
            id: 1,
            originalCoordinates: Constants.coordinates1,
            screenConstrainedCoordinates: Constants.coordinates1,
            resultCoordinates: Constants.coordinates1,
            resultCenter: .zero
        ),
        .init(
            id: 2,
            originalCoordinates: Constants.coordinates2,
            screenConstrainedCoordinates: Constants.coordinates2,
            resultCoordinates: Constants.coordinates2,
            resultCenter: .zero
        )
    ])

    private var pins: [PinView] {
        [pin1, pin2]
    }

    override func loadView() {
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup pins
        pins.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        pin1VC = pin1.centerYAnchor.constraint(equalTo: mapView.centerYAnchor)
        pin1HC = pin1.centerXAnchor.constraint(equalTo: mapView.centerXAnchor)
        pin2VC = pin2.centerYAnchor.constraint(equalTo: mapView.centerYAnchor)
        pin2HC = pin2.centerXAnchor.constraint(equalTo: mapView.centerXAnchor)
        pin1VC?.isActive = true
        pin1HC?.isActive = true
        pin2VC?.isActive = true
        pin2HC?.isActive = true

        // Setup map
        mapView.mapboxMap.onEvery(event: .cameraChanged) { _ in

            // Move Pins From Bounds
            for i in 0..<self.state.pins.count {
                self.state.pins[i].screenConstrainedCoordinates = self.constrainedCoordinates(self.state.pins[i].originalCoordinates)
            }

            // Move pins from each other
            if self.pinsIntersects() {
                let newCenterLatitudeForBothViews = (self.state.pins[0].screenConstrainedCoordinates.latitude + self.state.pins[1].screenConstrainedCoordinates.latitude) / 2

                let newBottomCoordinates = CLLocationCoordinate2D(latitude: newCenterLatitudeForBothViews, longitude: self.state.pins[0].screenConstrainedCoordinates.longitude)
                let bottomPoint = self.mapView.mapboxMap.point(for: newBottomCoordinates)
                self.state.pins[0].resultCenter = CGPoint(x: bottomPoint.x, y: bottomPoint.y + self.pin1.frame.size.height/2 + Constants.space)
                self.state.pins[0].resultCoordinates = self.mapView.mapboxMap.coordinate(for: self.state.pins[0].resultCenter)

                let newTopCoordinates = CLLocationCoordinate2D(latitude: newCenterLatitudeForBothViews, longitude: self.state.pins[1].screenConstrainedCoordinates.longitude)
                let topPoint = self.mapView.mapboxMap.point(for: newTopCoordinates)
                self.state.pins[1].resultCenter = CGPoint(x: topPoint.x, y: topPoint.y - (self.pin2.frame.size.height / 2.0 + Constants.space))
                self.state.pins[1].resultCoordinates = self.mapView.mapboxMap.coordinate(for: self.state.pins[1].resultCenter)
            } else {
                for i in 0..<self.state.pins.count {
                    self.state.pins[i].resultCoordinates = self.state.pins[i].screenConstrainedCoordinates
                    self.state.pins[i].resultCenter = self.mapView.mapboxMap.point(for: self.state.pins[i].resultCoordinates)
                }
            }

            // Apply final coordinates
            self.setConstraints()
            self.updateArrows()
        }
    }

    func pinsIntersects() -> Bool {
        let pin1State = self.state.pins[0]
        let pin2State = self.state.pins[1]
        let newCenterLatitudeForBothViews = (pin1State.screenConstrainedCoordinates.latitude + pin2State.screenConstrainedCoordinates.latitude) / 2
        let newCenterLongitudeForBothViews = (pin1State.screenConstrainedCoordinates.longitude + pin2State.screenConstrainedCoordinates.longitude) / 2
        let verticalDistance = abs((pin1State.screenConstrainedCoordinates.latitude - newCenterLatitudeForBothViews) * mapPointsPerDegree)
        let horizontalDistance = abs((pin1State.screenConstrainedCoordinates.longitude - newCenterLongitudeForBothViews) * mapPointsPerDegree)
        return verticalDistance < pin1.frame.size.height / 2.0 + Constants.space && horizontalDistance < pin1.frame.size.width / 2.0 + Constants.space
    }
    func constrainedCoordinates(_ coordinates: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let minPoint = mapView.mapboxMap.coordinate(for: .init(x: mapView.frame.minX + pin1.frame.size.width/2 + Constants.space, y: mapView.frame.maxY - pin1.frame.size.height/2 - Constants.space))
        let maxPoint = mapView.mapboxMap.coordinate(for: .init(x: mapView.frame.maxX - pin1.frame.size.width/2 - Constants.space, y: mapView.frame.minY + pin1.frame.size.height/2 + Constants.space))

        return CLLocationCoordinate2D(
            latitude: max(
                min(
                    coordinates.latitude,
                    maxPoint.latitude
                ),
                minPoint.latitude
            ),
            longitude: max(
                min(
                    coordinates.longitude,
                    maxPoint.longitude
                ),
                minPoint.longitude
            )
        )
    }

    func setConstraints() {
        pin1VC?.constant = self.state.pins[0].resultCenter.y - mapView.center.y
        pin1HC?.constant = self.state.pins[0].resultCenter.x - mapView.center.x

        pin2VC?.constant = self.state.pins[1].resultCenter.y - mapView.center.y
        pin2HC?.constant = self.state.pins[1].resultCenter.x - mapView.center.x
    }

    func updateArrows() {
        for i in 0..<state.pins.count {
            pins[i].showleft = state.pins[i].screenConstrainedCoordinates.longitude > state.pins[i].originalCoordinates.longitude
            pins[i].showRight = state.pins[i].screenConstrainedCoordinates.longitude < state.pins[i].originalCoordinates.longitude
            pins[i].showUp = state.pins[i].screenConstrainedCoordinates.latitude < state.pins[i].originalCoordinates.latitude
            pins[i].showDown = state.pins[i].screenConstrainedCoordinates.latitude > state.pins[i].originalCoordinates.latitude
        }
    }

    // Calculation

    var mapDegreesPerPoint: Double {
        let minLatitude = mapView.mapboxMap.coordinate(for: .init(x: 0, y: mapView.frame.maxY)).latitude
        let maxLatitude = mapView.mapboxMap.coordinate(for: .init(x: 0, y: mapView.frame.minY)).latitude
        return (maxLatitude - minLatitude) / mapView.frame.size.height
    }
    var mapPointsPerDegree: Double {
        1 / mapDegreesPerPoint
    }
}

extension ViewController: ViewAnnotationUpdateObserver {
    func framesDidChange(for annotationViews: [UIView]) {}
    func visibilityDidChange(for annotationViews: [UIView]) {}
}
