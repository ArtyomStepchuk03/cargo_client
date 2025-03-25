
import UIKit
import Flutter
import Firebase
import GoogleMaps


@UIApplicationMain @objc class AppDelegate: FlutterAppDelegate {

  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyD6IF5PyUqDRKujgqDffFYz6VALpDqTDq0")

    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

}
