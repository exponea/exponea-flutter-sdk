import Foundation
import Flutter
import exponea

@main
@objc class AppDelegate: ExponeaFlutterAppDelegate, FlutterImplicitEngineDelegate {

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
}
