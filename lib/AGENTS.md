# Dart layer

Apply the root guide as well. Paths below are relative to the repository root.

## Layout and ownership

- `lib/exponea.dart` is the only export file. A symbol is public exactly when it is exported there. Keep the list sorted by feature group as it is now.
- `lib/src/interface.dart` (`BaseInterface`) declares the API with its doc comments. `lib/src/platform/platform_interface.dart` repeats every member with `throw UnimplementedError()`. `lib/src/platform/method_channel.dart` implements it. `lib/src/plugin/exponea.dart` forwards it. A new method touches all four.
- `lib/src/data/model/` holds immutable value types; `lib/src/data/encoder/` holds a `*Encoder` with static `encode`/`decode` for each; `lib/src/data/encoder/main.dart` re-exports encoders. Tests import encoders from `package:exponea/src/data/encoder/main.dart`.
- `lib/src/data/normalization/` resolves legacy `projectToken`/`authorizationToken`/`baseUrl` into `integrationConfig` and builds the `configure` payload. Keep that migration; integrators still pass legacy fields.
- `lib/src/widget/` wraps native platform views. Each widget owns its view type string and a per-instance channel `com.exponea/<ViewType>/<viewId>` created in `onPlatformViewCreated`.
- `lib/src/data/util/object.dart` provides `let`, `getOptional`, `getRequired`. `Codable.dart` (capitalized, keep the name) provides `Encodable.encodeClean()`.

## Bridge contract

- Method names are string constants at the top of `method_channel.dart`. The same strings exist in Kotlin (`ExponeaPlugin.kt` companion) and Swift (`METHOD_NAME` enum). Changing one without the others is a runtime error, not a compile error.
- Payloads are plain `Map<String, dynamic>` with `camelCase` keys. Content blocks and in-app messages are sent as JSON strings inside the map (`jsonEncode(...)`), not nested maps. Follow the existing call for the same type.
- Timestamps cross as Unix seconds (`DateTimeEncoder`), durations as seconds (`DurationEncoder`). Enums cross as the strings produced by their encoder; check the fixture before adding a value.
- Event channels are broadcast streams created lazily and cached. `inAppMessageActionStream()` also invokes `setInAppMessageActionHandler` with the flags each time it is called.
- `segmentationDataStream` registers a native callback and returns a per-instance Dart stream handled by `SegmentationStreamDataHandler`; cancelling the subscription unregisters natively. Preserve that pairing.
- `flushData()` awaits native completion and may complete with `PlatformException`. Its doc comment is the integrator-facing contract; update it if behavior changes.

## Tests

- Run `flutter test` or a single file `flutter test test/unit/data/<name>_test.dart`. `test/unit/` covers encoders and the platform layer, `test/widget/` covers the platform-view widgets.
- Fixtures live in `test/values/<name>.json` as a JSON array; `test/unit/data/base.dart` reads them. Each test asserts fixture length first, then encode/decode per entry, then required-field failures with the exact `StateError` message.
- Method-channel behavior is tested with `TestWidgetsFlutterBinding` and `setMockMethodCallHandler` (see `test/unit/platform/method_channel_flush_test.dart`); reset the handler in `tearDown`.
- The `ExponeaPlugin` facade is tested against a Mockito `MockExponeaPlatform` (`test/unit/platform/exponea_plugin_test.dart`). The `.mocks.dart` file is generated: after changing `ExponeaPlatform`, run `flutter pub get` against the committed `pubspec.lock` first, then `dart run build_runner build` from the repo root (the pinned build_runner deletes conflicting outputs by default; the old `--delete-conflicting-outputs` flag is ignored). If the regenerated file changes more than the stubs you added, keep only the new stubs; a different mockito resolution rewrites the whole file.
- Add the fixture and test on the same PR as the model; mirror the fixture in `example/android/app/src/test/` and `example/ios/RunnerTests/` when the native coder changes. Native tests read the same `test/values/` files.
- `flutter analyze` exits 1 on pre-existing infos; do not add new issues. `analysis_options.yaml` escalates `parameter_assignments` to an error; everything else from `flutter_lints` is advisory and pre-existing infos are not yours to fix.
