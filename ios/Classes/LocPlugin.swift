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
            eventSink?([
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ])
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        eventSink?(FlutterError(code: "LOCATION_ERROR", message: error.localizedDescription, details: nil))
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            eventSink?(FlutterError(code: "LOCATION_PERMISSION_DENIED", message: "Location permission denied", details: nil))
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        @unknown default:
            eventSink?(FlutterError(code: "UNKNOWN_LOCATION_ERROR", message: "Unknown location error occurred", details: nil))
        }
    }
}
