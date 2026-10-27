# iOS plugin

Apply the root guide as well. Paths below are relative to the repository root.
Native SDK version and deployment target live in `ios/exponea.podspec`; the example resolves them through `example/ios/Podfile{,.lock}`. The podspec `s.version` is a placeholder that Flutter ignores; the wrapper version lives in `ExponeaFlutterVersion`.

## Commands

There is no standalone Xcode project in `ios/`. Build and test through the example app.

```sh
(cd example && flutter pub get)
(cd example/ios && pod install)
(cd example && flutter build ios --debug --no-codesign)
(cd example/ios && xcodebuild test -workspace Runner.xcworkspace -scheme Runner \
  -only-testing:RunnerTests -destination 'platform=iOS Simulator,name=iPhone 17')
```

The `Runner` scheme's test action runs the `RunnerTests` target, a nested target of `Runner` in the Podfile that adds Quick and Nimble. Plugin specs live in `example/ios/RunnerTests/*Spec.swift` and read fixtures from the repository `test/values/`; `DeeplinkHandlingTests.swift` is plain XCTest for the example itself. Pick a simulator name that exists on the machine. The Podfile reads `Flutter/Generated.xcconfig`, so `flutter pub get` must precede `pod install`.
`example/ios/Podfile` pins `ExponeaSDK-Notifications` for the push extensions; keep it equal to the `ExponeaSDK` version in `ios/exponea.podspec`.

## Change the owning adapter

- `ExponeaPlugin.h/.m` only forwards registration to `SwiftExponeaPlugin.register(with:)`. Everything else is Swift.
- `SwiftExponeaPlugin.handle(_:result:)` maps `call.method` through the `METHOD_NAME` enum; an unknown name returns `FlutterError` "not supported by iOS". Add the enum case, the `switch` branch and a private handler together.
- Every handler starts with `guard requireConfigured(with: result) else { return }` unless it is legal before configuration. Errors are `FlutterError(code: "ExponeaPlugin", message:, details: nil)` built from `ExponeaError` or `ExponeaDataError`. Call `result` exactly once, including in asynchronous completions.
- Payload parsing goes through `JsonDataParser`, `NSDictionary+getSafely.swift` (`getRequiredSafely`/`getOptionalSafely`) and the coders in `ios/Classes/Data/`. Handle `NSNull` and `NSNumber` booleans explicitly.
- `@objc(IsExponeaFlutterSDK)` and `@objc(ExponeaFlutterVersion)` are looked up by the native SDK via reflection. Never rename them; bump the returned version string only on release.
- `ExponeaFlutterAppDelegate` is `open` and is subclassed by integrators (see `example/ios/Runner/AppDelegate.swift`). Keep overrides `open`, keep `configurePushNotificationDelegate()` running before `super`, and keep the `fetchCompletionHandler` variant even though Flutter never calls it.
- Static entry points `setUserNotificationCenterDelegate`, `handlePushNotificationToken`, `handlePushNotificationOpened` (two overloads) and `continueUserActivity` are public API for apps with a custom delegate.
- The plugin registers as both application delegate and scene delegate on purpose (UIScene adoption). Universal links are tracked on both paths; do not remove either.
- Stream handlers (`OpenedPushStreamHandler`, `ReceivedPushStreamHandler`, `InAppMessageActionStreamHandler.currentInstance`, `SegmentationDataStreamHandler`, `SdkAuthStreamHandler`) hold the last event until Dart listens. `EngineDeliveryGuard` blocks delivery while the app is in background and detaches handlers on engine teardown; route new event types through it.
- Platform views (`FluffView`, `InAppContentBlockPlaceholder`, `AppInboxDetailView`, `AppInboxListView`, `InAppContentBlockCarousel`) are registered in `register(with:)` with the same type string as the Dart widget and report back on `com.exponea/<ViewType>/<viewId>` from `DispatchQueue.main`.
- Platform differences to preserve: HMS methods are rejected, `trackSessionStart/End` ignore the timestamp, `clearLocalCustomerData` accepts `appGroup`. Do not add parity behavior without a public API decision.

## Verification

Add or extend a `*Spec.swift` in `example/ios/RunnerTests/` next to the coder you change; `TestUtil.swift` has the fixture helpers. Run the `xcodebuild test` command above and the example build. If no simulator or Xcode is available, say so in the PR instead of claiming coverage.
No fake of `ExponeaType` exists yet, so no spec drives `configure` or a `requireConfigured` path. `SwiftExponeaPlugin.exponeaInstance` is a `lazy var ExponeaType`, reachable through `@testable import exponea`. To cover such a path: add `FakeExponea: ExponeaType` under `example/ios/RunnerTests/` (implement every member of the protocol at the pinned ExponeaSDK version; the pod's `ExponeaType.swift` lists them), add the file to the `RunnerTests` target in `Runner.xcodeproj` (a plain group, files on disk are not picked up), and set `plugin.exponeaInstance = fake` before calling `handle`. Without the fake, say in the PR that the path is untested.
Persistence, flushing, auth and in-app logic belong in [exponea-ios-sdk](https://github.com/exponea/exponea-ios-sdk) at the pinned version.
