import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let googleMapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String else {
      fatalError("Google Maps API key not found in Info.plist. Make sure GOOGLE_MAPS_API_KEY is set.")
    }

    // Check if the key is the placeholder value which means it wasn't replaced by the build process
    if googleMapsApiKey == "$(GOOGLE_MAPS_API_KEY)" {
        fatalError("Google Maps API Key is the placeholder value. Ensure MapsConfig.xcconfig is linked in Xcode build settings and contains the key.")
    }

    GMSServices.provideAPIKey(googleMapsApiKey)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
