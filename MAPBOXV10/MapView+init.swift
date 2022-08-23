//
//  MapView+init.swift
//  MAPBOXV10
//
//  Created by Ilya Filinovich on 28.07.2022.
//

import Foundation
import MapboxMaps

extension MapView {

    static func defaultInit() -> MapView {
        let map = MapView(
            frame: .zero,
            mapInitOptions: .init(
                resourceOptions: .init(accessToken: ""),
                mapOptions: .init(
                    constrainMode: .none,
                    viewportMode: .default,
                    orientation: .upwards,
                    crossSourceCollisions: false,
                    optimizeForTerrain: false,
                    size: nil,
                    pixelRatio: 1,
                    glyphsRasterizationOptions: .init()
                ),
                cameraOptions: .init(
                    center: .init(latitude: 59.9382370399789, longitude: 30.3182691832409),
                    padding: nil,
                    anchor: nil,
                    zoom: 11,
                    bearing: nil,
                    pitch: nil
                ),
                styleURI: .init(url: .init(string:"https://monetization-trap-api.aviasales.ru/api/v1/trap/LED/style_light.json?locale=ru_RU")!)
            )
        )

        map.gestures.options.rotateEnabled = false
        map.ornaments.options.scaleBar.visibility = .hidden
        return map
    }
}
