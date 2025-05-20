
import UIKit
import Flutter
import Firebase
import GoogleMaps


@UIApplicationMain @objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyDIljZjTPM6J0UDqyA6BeJWD16ybuNLyzM")

    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self
      
    Messaging.messaging().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

}
