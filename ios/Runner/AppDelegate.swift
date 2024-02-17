import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Firebaseの初期化コード ??
    // FirebaseApp.configure()
    // return true

    // 追加
    GMSServices.provideAPIKey("AIzaSyB3hlptGf6fXPV4rmv_WObYCuUFBrQ1doM")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
