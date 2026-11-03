# AGENTS.md: Bloomreach Engagement Flutter SDK

## 1. Scope

This repository ships the `exponea` Flutter plugin through pub.dev. It wraps the native Android SDK (Maven) and iOS SDK (CocoaPods) for Flutter integrators.
This is a **public SDK**. Public API, default behavior, and `Documentation/` reach integrators.

Nested instruction files take precedence inside their directory:

| File                                   | Covers                                                        |
| -------------------------------------- | ------------------------------------------------------------- |
| [lib/AGENTS.md](lib/AGENTS.md)         | Dart API, encoders, method/event channel contract, Dart tests |
| [android/AGENTS.md](android/AGENTS.md) | Kotlin plugin, push receiver, platform views, Gradle tests    |
| [ios/AGENTS.md](ios/AGENTS.md)         | Swift plugin, app delegate, stream handlers, Quick specs      |
| [example/AGENTS.md](example/AGENTS.md) | Example app, GMS/HMS flavors, native test hosts, credentials  |

Sibling SDKs: [Android](https://github.com/exponea/exponea-android-sdk), [iOS](https://github.com/exponea/exponea-ios-sdk), [React Native](https://github.com/exponea/exponea-react-native-sdk).
Cross-platform contract: no standalone specification exists. Use the pinned native SDKs (versions in `android/build.gradle` and `ios/exponea.podspec`) and [Bloomreach mobile docs](https://documentation.bloomreach.com/engagement/docs/mobile-sdks). Report conflicts instead of inventing a contract.

## 2. Commands

Run from the repo root. These are the commands CI and reviewers trust.

```bash
flutter pub get
```

```bash
(cd example && flutter build apk --debug --flavor gms)                                # Android build check
(cd example/ios && pod install) && (cd example && flutter build ios --debug --no-codesign)   # iOS build check
```

```bash
flutter test                                                   # Dart unit + widget tests (test/)
(cd example && flutter test)                                   # Example app tests incl. automation contract
(cd example/android && ./gradlew :app:testGmsDebugUnitTest)    # Kotlin plugin tests, hosted by the example
(cd example/ios && xcodebuild test -workspace Runner.xcworkspace -scheme Runner -only-testing:RunnerTests -destination 'platform=iOS Simulator,name=<device>')   # pick <device> from `xcrun simctl list devices available`
```

```bash
flutter test test/unit/data/consent_test.dart
```

```bash
flutter analyze                                                # covers example/ too; exits 1 on pre-existing infos, see section 6
dart run build_runner build                                    # regenerate *.mocks.dart after changing a mocked interface, see lib/AGENTS.md
```

There is no checked-in build/test CI. The only GitHub workflows upload `Documentation/` to ReadMe.
Native plugin tests live under `example/`, not under `android/` or `ios/`; the nested guides explain why.
Do not run `dart format` on existing files: the tree is not formatter-clean and the diff would be noise. Match the surrounding style.
Toolchain versions live in `pubspec.yaml`, `android/build.gradle`, `ios/exponea.podspec`, `example/pubspec.yaml`, `example/android/settings.gradle.kts`, `example/android/app/build.gradle.kts`, `example/ios/Podfile{,.lock}`; read them there.

## 3. Public API stability

- The migration guide for breaking changes is `Documentation/version-update.md`.
- Library-private means: nothing under `lib/src/` is public unless `lib/exponea.dart` exports it; new Kotlin/Swift types stay `internal`/`private`.
- Approval also covers a new method-channel name or payload key and a new public Kotlin/Swift host-app hook; a new optional named parameter with a default, a new internal encoder/parser or a characterization test does not need it.
- Public surface is more than Dart: method names, event-channel names, platform-view type names and argument maps are a contract between `lib/src/platform/method_channel.dart`, `android/.../ExponeaPlugin.kt` and `ios/Classes/SwiftExponeaPlugin.swift`. All three change together.
- Host-app entry points are public too: `ExponeaPlugin` companion functions and `ExponeaPushReceiver` on Android; `ExponeaFlutterAppDelegate` and `SwiftExponeaPlugin` static functions on iOS. Integrators call them from their own native code.
- Native SDK identifies this wrapper by reflection: `@objc(IsExponeaFlutterSDK)`, `@objc(ExponeaFlutterVersion)` and the `ExponeaFlutterSDK*` manifest meta-data. Never rename them.
- No automated API diff exists. Review `lib/exponea.dart` exports and the three method-name lists by hand.

## 4. Architecture

- `lib/exponea.dart` is the single export file. `ExponeaPlugin` (`lib/src/plugin/exponea.dart`) is the integrator facade; it delegates every call to `ExponeaPlatform.instance`.
- `BaseInterface` (`lib/src/interface.dart`) is implemented by both `ExponeaPlatform` and `ExponeaPlugin`. `MethodChannelExponeaPlatform` (`lib/src/platform/method_channel.dart`) is the only real implementation and owns all channel names.
- One method channel `com.exponea`; five event channels `com.exponea/{opened_push,received_push,in_app_messages,segmentation_data,sdk_auth}`. Platform views get a per-instance channel `com.exponea/<ViewType>/<viewId>`.
- Dart models live in `lib/src/data/model/`, their encoders in `lib/src/data/encoder/`, config normalization in `lib/src/data/normalization/`. Every model crosses the bridge as a `Map` produced by an encoder; `Encodable.encodeClean()` drops nulls.
- Android: `ExponeaPlugin` registers channels and platform-view factories; `ExponeaMethodHandler` dispatches by method name and calls `com.exponea.sdk.Exponea`. Parsers and coders live in `android/.../data/`.
- iOS: `SwiftExponeaPlugin` dispatches via the `METHOD_NAME` enum and calls `ExponeaSDK.Exponea.shared`. Coders live in `ios/Classes/Data/`, stream handlers next to the plugin, views in `ios/Classes/Widget/`.
- Persistence, HTTP, retries, identity and campaign state belong to the native SDKs. The wrapper only converts data and forwards calls; fix defects in the owning layer.
- Event streams hold the last event until a Dart listener attaches. Stream handlers are re-created on every engine attach; the pending event and the current instance live in static fields, so the event survives engine reattach. Only `InAppMessageActionStreamHandler.currentInstance` is a process-wide singleton. Hot restart does not reset native state.
- `configure` initializes the native SDK once per process on both platforms. Later calls (engine reattach, hot restart) only rebind the push and in-app callbacks to the current plugin instance and return `false`. Read the doc comment on `configure` before changing it.
- Native UI (platform views, in-app messages) runs on the platform main thread. Keep existing `Handler(Looper.getMainLooper())` / `DispatchQueue.main` dispatch.

## 5. Conventions

- A bridge call completes its `Result`/`FlutterResult` exactly once. Use the existing `runWithResult` / `runWithNoResult` / `runAsync` helpers on Android and `requireConfigured(with:)` on iOS.
- Errors cross the bridge as `PlatformException` with code `ExponeaPlugin` and a human-readable message. Do not turn a failure into a silent success; do not crash the host app on malformed input.
- Keep consent-aware methods and their `WithoutTrackingConsent` twins in sync on all three layers.
- Platform-only features (`trackHmsPushToken`, `appGroup`, session timestamps on iOS) are rejected or ignored with a logged message, not emulated. Document the gap in the Dart doc comment.
- Required bridge fields use `getRequired`, which throws `StateError('<key> is required!')`; tests assert that exact message.
- Never log tokens, authorization headers or customer payloads in new diagnostics.
- Code comments never contain ticket numbers, Slack/Jira references, or customer names.

## 6. Testing and verification

- Framework and mocks: `flutter_test` with JSON fixtures in `test/values/` loaded by `test/unit/data/base.dart`, Mockito mocks of `ExponeaPlatform` in `test/unit/platform/*.mocks.dart` (generated, never hand-edited); JUnit4 in `example/android/app/src/test/`; Quick/Nimble in `example/ios/RunnerTests/`; example widget tests run against `FakeExponeaService`. Method-channel tests mock the channel with `setMockMethodCallHandler`. Network is always stubbed; never configure a live project in a test.
- Every model change updates the model, its encoder, its JSON fixture and its test on Dart, Android and iOS.
- Add characterization tests before changing shared managers, lifecycle, identity, or cache.
- Never delete or skip a test to make CI green.

What to run before calling a change done:

| Change touches     | Run                                                                               |
| ------------------ | --------------------------------------------------------------------------------- |
| Docs only          | Check front matter and links; keep `{user.*}` merge tags                          |
| Dart internal code | `flutter analyze` + affected `flutter test` files                                 |
| Android / iOS code | Above + Gradle or Xcode tests from section 2 + example build on that platform     |
| Public API         | Full `flutter test`, both native test suites, both example builds, docs in same PR|
| Build / packaging  | Above + `flutter pub publish --dry-run`; inspect the file list                    |

`flutter analyze` currently exits 1 on pre-existing infos. Compare the issue count before and after your change (or use `--no-fatal-infos`); do not touch unrelated code to silence them.
`flutter pub publish --dry-run` exits 65 because the package has no `CHANGELOG.md` (release notes live in `Documentation/release-notes.md`); that is expected. Read the file list it prints, not the exit code, and do not add a changelog to fix it.

## 7. Cross-platform parity

- This wrapper follows the pinned native SDKs; a native SDK fix needs a released native version before the wrapper can rely on it.
- Files that change together for every new native API: `lib/src/interface.dart`, `lib/src/platform/platform_interface.dart`, `lib/src/platform/method_channel.dart`, `lib/src/plugin/exponea.dart`, model + encoder + fixture + test, `ExponeaPlugin.kt` (constant, `when` branch, handler), `SwiftExponeaPlugin.swift` (`METHOD_NAME` case, `switch` branch, handler), Kotlin and Swift tests, `Documentation/*.md`.
- For UI APIs also: the Dart widget, `AndroidView`/`UiKitView` type name, both native factories and views, and the example page.

## 8. Docs, changelog, release

- `Documentation/*.md` syncs to ReadMe via `.github/workflows/`: `develop` → sandbox, `main` → production. Keep the front matter (`title`, `slug`, `category`, `parent`, `content.excerpt`) intact. New public API ships with docs in the same PR.
- Docs use ReadMe merge tags such as `{user.mkg}` and `{user.dh}` for product names. Do not replace them with literal names.
- Releases are prepared by `prepare_release.js flutter` from the `sdk-release-scripts` repository, never by hand. It creates `feat/version_X.Y.Z` from a clean `develop`, bumps the plugin version (`pubspec.yaml`, `android/build.gradle`, `android/src/main/AndroidManifest.xml`, `ExponeaFlutterVersion` in `ios/Classes/SwiftExponeaPlugin.swift`) and the example app version (`example/pubspec.yaml`, `MARKETING_VERSION` in `example/ios/Runner.xcodeproj`), inserts the release-notes template into `Documentation/release-notes.md` and commits `feat/Version X.Y.Z`. Fill in the release notes and amend that commit. Do not add release-notes entries in feature PRs.
- The example app follows the plugin version; the script bumps both. `ios/exponea.podspec` keeps its placeholder version; Flutter ignores it.
- The only `MARKETING_VERSION` left in `example/ios/Runner.xcodeproj` is on the RunnerTests target and must stay a plain three-part `X.Y.Z` equal to the plugin version. The script's pattern does not escape dots and accepts empty numbers, so any other value (for example `1.0` or `$(FLUTTER_BUILD_NAME)`) breaks the pbxproj or gets the wrong version. The Runner target itself takes its version from `example/pubspec.yaml`.
- After the script runs, check its result: it also reads `example/android/local.properties`, a gitignored file that may not exist on a fresh checkout. Report a script failure instead of finishing the bump by hand.
- Native SDK upgrade touches `android/build.gradle`, `example/android/app/build.gradle.kts`, `ios/exponea.podspec`, `example/ios/Podfile` (`ExponeaSDK-Notifications` pin), regenerated `example/ios/Podfile.lock`, and a release-notes line. The example pins carry comments saying they must equal the plugin pins.
- `.pubignore` replaces `.gitignore` for pub and excludes `Documentation/`, `build/`, `coverage/` and every `AGENTS.md`/`CLAUDE.md` from the published package. Keep maintainer-only context out of `Documentation/`.

## 9. Commits and PRs

- Do not create commits, tags or publish unless the task asks for it.
- In the PR, list the exact commands you ran with their results, including the checks you could not run.

## 10. When the task is ambiguous

- Before inventing an API, file path or backend field, check the pinned native SDKs and the React Native wrapper, which share the contract with this plugin.

## 11. Boundaries

**Always:** run `flutter analyze` and the section 6 checks for the layers you touched; match surrounding style; report failures and skipped checks honestly.

**Ask first:** public API or bridge contract change; new or upgraded dependency (Dart, Gradle, CocoaPods); native SDK version bump; CI workflows, signing, packaging, `.pubignore`; docs front matter.

**Never:** commit secrets or production tokens (`example/android/credentials.json`, `example/ios/credentials.json` are gitignored on purpose); edit generated or vendored code (`**/build/`, `.dart_tool/`, `example/ios/Pods/`, `example/ios/Flutter/Generated.xcconfig`, `GeneratedPluginRegistrant.*`, `*.mocks.dart`, `**/.gradle/`); force-push shared branches; commit `.claude/`, `.idea/`, `.vscode/` or other local agent/IDE state.

## 12. Gotchas

- There is no Gradle wrapper or Xcode project in `android/` or `ios/`. Native plugin tests build only through `example/android` and `example/ios` (see the nested guides).
- The production docs workflow triggers on `main`, but the remote has `master` and `develop` only. Flag this when touching release docs; do not rename branches to fix it.
- Swift rejects unknown method names with "not supported by iOS". Adding a Dart method without the Swift `METHOD_NAME` case fails at runtime, not at build time.
- The in-app message stream handler is a singleton on both platforms; a second `inAppMessageActionStream()` call re-sends handler flags but reuses the stream.
- iOS `EngineDeliveryGuard` drops event delivery while the app is in background to avoid engine-teardown crashes. Do not bypass it to "fix" a missing callback.
- `Flutter` push callbacks on iOS arrive through `application(_:didReceiveRemoteNotification:)` only; the `fetchCompletionHandler` variant is never called by Flutter but must stay implemented.
- `example/android` needs `--flavor gms` or `--flavor hms`; a bare `flutter run` fails.
- `flutter pub get` on a Flutter other than the one that resolved `pubspec.lock` or `example/pubspec.lock` rewrites that lockfile (the `sdks:` block in each lock states the minimum it expects). Restore it with `git checkout` unless the task is a dependency upgrade.
- The example app has a looser SDK constraint and its own `flutter_lints` major than the plugin. Do not "align" them in a feature PR.

## 13. Maintaining this file

Propose edits to the nearest AGENTS.md when a rule is missing or wrong; do not change rules silently. Keep the root file within 120 to 180 lines.
Add a gotcha only after someone (or an agent) hit it, with the file that proves it. Move detail into the nested guides, not here.
