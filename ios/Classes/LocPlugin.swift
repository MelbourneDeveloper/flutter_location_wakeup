import Flutter
import UIKit
import CoreLocation

public class LocPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, CLLocationManagerDelegate {
    private var eventSink: FlutterEventSink?
    private var locationManager: CLLocationManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "loc", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "loc_stream", binaryMessenger: registrar.messenger())
        
        let instance = LocPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startMonitoring":
            startMonitoring()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startMonitoring() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    @objc public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    @objc public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let status = CLLocationManager.authorizationStatus()
            let permissionStatus = stringFromAuthorizationStatus(status: status)
            
            var locationData: [String: Any] = [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "altitude": location.altitude,
                "horizontalAccuracy": location.horizontalAccuracy,
                "verticalAccuracy": location.verticalAccuracy,
                "course": location.course,
                "speed": location.speed,
                "timestamp": location.timestamp.timeIntervalSince1970, // Convert to UNIX timestamp
                "permissionStatus": permissionStatus
            ]
            
            if let floor = location.floor {
                locationData["floorLevel"] = floor.level
            }
            
            eventSink?(locationData)
        }
    }

    func stringFromAuthorizationStatus(status: CLAuthorizationStatus) -> String {
        switch status {
        case .authorizedAlways:
            return "granted"
        case .authorizedWhenInUse:
            //Not differentiating between when in use and always
            return "granted"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        case .notDetermined:
            return "notDetermined"
        @unknown default:
            return "unknown"
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        eventSink?(FlutterError(code: "LOCATION_ERROR", message: error.localizedDescription, details: nil))
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            eventSink?(FlutterError(code: "LOCATION_PERMISSION_DENIED", message: "Location permission restricted", details: ["permissionStatus": "restricted"]))
        case .denied:
            eventSink?(FlutterError(code: "LOCATION_PERMISSION_DENIED", message: "Location permission denied", details: ["permissionStatus": "denied"]))
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        @unknown default:
            eventSink?(FlutterError(code: "UNKNOWN_LOCATION_ERROR", message: "Unknown location error occurred", details: nil))
        }
    }
}
