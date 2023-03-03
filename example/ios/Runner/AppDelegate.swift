import Foundation
import Flutter
import exponea

@UIApplicationMain
@objc class AppDelegate: ExponeaFlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        
        registrar(forPlugin: "AppInbox")?.register(FluffViewFactory(), withId: "FluffView")
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

