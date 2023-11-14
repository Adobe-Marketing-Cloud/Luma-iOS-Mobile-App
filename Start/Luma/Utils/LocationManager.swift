//
//  LocationManager.swift
//  Luma
//
//  Created by Rob In der Maur on 22/07/2022.
//

import CoreLocation
import Foundation
import os.log

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined
    @Published var ibeacons = [IBeacon]()
    @Published var startScanningEnabled = false
    
    /// Inirilizartion
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        // manager.startUpdatingLocation()
    }
    
    /// Wrapper function
    func requestLocation() {
        manager.requestLocation()
    }
    
    /// Wrapper function to request authorization always or not
    /// - Parameter always: true or false
    public func requestAuthorisation(always: Bool = false) {
        if always {
            self.manager.requestAlwaysAuthorization()
        } else {
            self.manager.requestWhenInUseAuthorization()
        }
    }
    
    /// Tells the delegate when the app creates the location manager and when the authorization status changes.
    /// - Parameters:
    ///   - manager: location manager reporting the event
    ///   - status: status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Logger.notifications.info("LocationManager - didChangeAuthorization")
        authorisationStatus = status
        if status == .authorizedWhenInUse {
            Logger.notifications.info("LocationManager - didChangeAuthorization: status is authorizedWhenInUse")
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                Logger.notifications.info("LocationManager - didChangeAuthorization: status is isMonitoringAvailable")
                if CLLocationManager.isRangingAvailable() {
                    Logger.notifications.info("LocationManager - didChangeAuthorization: status is isRangingAvailable")
                    startScanningEnabled = true
                }
            }
        }
    }
    
    /// Tells the delegate that new location is available
    /// - Parameters:
    ///   - manager: the location manager object that generated the update event
    ///   - locations: location details
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    /// Tells the delegate that the location manager was unable to retrieve a location value.
    /// - Parameters:
    ///   - manager: The location manager object that was unable to retrieve the location.
    ///   - error: The error object containing the reason the location or heading could not be retrieved.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.notifications.error("LocationManager - didFailWithError: \(error.localizedDescription)…")
    }
    
    /// Start scanning beacons
    func startScanning() {
        for ibeacon in ibeacons {
            let uuid = UUID(uuidString: ibeacon.uuid)!
            let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: uuid, major: CLBeaconMajorValue(ibeacon.major), minor: CLBeaconMinorValue(ibeacon.minor))
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconIdentityConstraint, identifier: ibeacon.identifier)
            self.manager.startMonitoring(for: beaconRegion)
            self.manager.startRangingBeacons(satisfying: beaconIdentityConstraint)
        }
    }
    
    /// Tells the delegate that one or more beacons are in range.
    /// - Parameters:
    ///   - manager: Tells the delegate that one or more beacons are in range.
    ///   - beacons: An array of CLBeacon objects representing the beacons currently in range.
    ///   - region: The region object containing the parameters that were used to locate the beacons.
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // if let beacon = beacons.first {
        for beacon in beacons {
            updateIBeacon(uuid: beacon.uuid, major: CLBeaconMajorValue(truncating: beacon.major), minor: CLBeaconMinorValue(truncating: beacon.minor), distance: beacon.proximity)
        } 
    }
    
    /// Updates the array of ibeacons with status and symbol
    /// - Parameters:
    ///   - uuid: uuid to use to look up the ibeacon
    ///   - distance: distance reported from the actual beacon to use to update status and symbol
    func updateIBeacon(uuid: UUID, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, distance: CLProximity) {
        var beaconStatus = "unknown"
        var beaconSymbol = "circle.slash"
        
        // if we find matching ibeacon for the beacon
        if let idxCurrentIBeacon:Int = self.ibeacons.firstIndex(where: { $0.uuid == uuid.uuidString && UInt16($0.major) == major && UInt16($0.minor) == minor }) {
            // if we find ibeacon definition in the list of updated beacons
            if let iBeacon = self.ibeacons.first(where: {$0.uuid == uuid.uuidString && UInt16($0.major) == major && UInt16($0.minor) == minor }) {
                // figure out the distance for status and symbol
                switch distance {
                case .far:
                    beaconStatus = "far"
                    beaconSymbol = "circle"
                    
                case .near:
                    beaconStatus = "near"
                    beaconSymbol = "circle.circle"
                    
                case .immediate:
                    beaconStatus = "immediate"
                    beaconSymbol = "circle.circle.fill"
                    
                default:
                    beaconStatus = "unkown"
                    beaconSymbol = "circle.slash"
                }
                
                // create new ibeacon with updated values for the one we found
                let updatedIBeaon = IBeacon(
                    uuid: iBeacon.uuid,
                    major: iBeacon.major,
                    minor: iBeacon.minor,
                    identifier: iBeacon.title,
                    title: iBeacon.title,
                    location: iBeacon.location,
                    category: iBeacon.category,
                    status: beaconStatus,
                    symbol: beaconSymbol
                )
                // remove the outdated ibeacon from the list
                ibeacons.remove(at: idxCurrentIBeacon)
                ibeacons.append(updatedIBeaon)
            }
        }
        
    }
}

extension SceneDelegate : CLLocationManagerDelegate {
    
    
    /// Tells the delegate that the user entered the specified region.
    /// - Parameters:
    ///   - manager: The location manager object reporting the event.
    ///   - region: An object containing information about the region that was entered.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // handle region enter logic
        Logger.notifications.info("LovationManager - didEnterRegion \(region.description)")
    }
    
    /// Tells the delegate that the user left the specified region.
    /// - Parameters:
    ///   - manager: The location manager object reporting the event.
    ///   - region: An object containing information about the region that was exited.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // handle region exit logic
        Logger.notifications.info("LovationManager - didExitRegion \(region.description)")
    }
}
