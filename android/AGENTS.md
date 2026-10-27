# Android plugin

Apply the root guide as well. Paths below are relative to the repository root.
Native SDK version and plugin toolchain live in `android/build.gradle`; the example pins the same SDK again in `example/android/app/build.gradle.kts` and its AGP/Kotlin versions in `example/android/settings.gradle.kts`. Keep the SDK pins equal on an upgrade.

## Commands

There is no Gradle wrapper in `android/`. The module builds and tests only as a dependency of the example app. Run `flutter pub get` in `example/` first so `local.properties` exists.

```sh
cd example/android
./gradlew :app:testGmsDebugUnitTest
./gradlew :app:testGmsDebugUnitTest --tests com.exponea.example.ConfigurationTest
./gradlew :app:assembleGmsDebug
./gradlew :app:assembleHmsDebug
```

A flavor (`Gms` or `Hms`) is mandatory in every task name; `example/android/app/build.gradle.kts` applies the Google or Huawei plugin by inspecting the requested task. Tests in `example/android/app/src/test/kotlin/com/exponea/example/` exercise plugin classes from `android/src/main/kotlin/com/exponea/` directly and read fixtures from the repository `test/values/`.
`example/android/gradle.properties` carries `android.newDsl=false` and `android.builtInKotlin=false` as written by the Flutter app template; they are not an HMS decision, so follow the Flutter tooling when it migrates them. The HMS-specific constraint is in `example/android/build.gradle.kts`: the `agcp` classpath excludes `com.android.tools.build` and the buildscript pins AGP explicitly, because `agcp` pulls in an old AGP that breaks the AGP 9 DSL. That pin must equal the AGP version in `settings.gradle.kts`.

## Change the owning adapter

- `ExponeaPlugin` (`FlutterPlugin`, `ActivityAware`) registers the method channel, five event channels and five platform-view factories in `onAttachedToEngine` and clears them in `onDetachedFromEngine`. Register new views there with the same type string the Dart widget uses.
- `ExponeaMethodHandler` dispatches on string constants in its companion object. Add the constant, the `when` branch and a private handler together. Handlers use `runWithResult`, `runWithNoResult` or `runAsync`; async handlers must call `result.success`/`result.error` exactly once from their callback.
- `requireConfigured()` / `requireNotConfigured()` throw `ExponeaException`; all exceptions become `result.error("ExponeaPlugin", message, null)`. Use `ExponeaException` factories for SDK-state errors and `ExponeaDataException` for payload errors.
- Parsing lives in `android/.../data/`: `ExponeaConfigurationParser`, `CustomerIdentityParser`, `ConfigurationChangeParser`, `*Coder`, `*Encoder`. Use `getRequired`/`getOptional` from `data/Extensions.kt`; do not cast raw maps inline.
- `configure` (root guide, section 4) additionally caches the parsed configuration on the plugin instance on first call and on engine reattach; the doc comment on `configure` explains why later calls do not overwrite it.
- Companion functions `handleCampaignIntent`, `handleRemoteMessage`, `trackGmsPushToken`, `trackHmsPushToken`, `handleNewGmsToken`, `handleNewHmsToken` are called from integrators' Kotlin code; the `ExponeaPushReceiver` broadcast receiver is declared in `android/src/main/AndroidManifest.xml`. All of them are public API.
- `AndroidManifest.xml` meta-data `ExponeaFlutterSDK` and `ExponeaFlutterSDKVersion` are read by the native SDK to report the wrapper; the version is bumped on release.
- Stream handlers (`OpenedPushStreamHandler`, `ReceivedPushStreamHandler`, `InAppMessageActionStreamHandler.currentInstance`, `SegmentationDataStreamHandler`, `SdkAuthStreamHandler`) hold the last event until a Dart listener attaches. Only the in-app handler is a singleton; the others are created per engine attach in `onAttachedToEngine` and keep `currentInstance` plus the pending event in their companion object so the event survives engine reattach. Keep the static pending-event storage when changing them.
- Platform views in `android/.../widget/` receive their arguments from the Dart `creationParams` map and talk back on `com.exponea/<ViewType>/<viewId>`. UI work runs on the main thread via `Handler(Looper.getMainLooper())`.
- HMS methods exist here only; iOS rejects them. Keep that asymmetry and document it in the Dart doc comment.

## Verification

Run the Gradle tests above and `cd example && flutter build apk --debug --flavor gms`. Stub the native SDK and network; assert payload shape, invalid input and `Result` behavior. Report any task you could not run instead of describing it as passed.
Native lifecycle, storage and HTTP defects belong in [exponea-android-sdk](https://github.com/exponea/exponea-android-sdk) at the pinned version; keep only conversion and forwarding here.
