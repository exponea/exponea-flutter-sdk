import 'package:exponea_example/app/app_shell.dart';
import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/app/env_config.dart';
import 'package:exponea_example/features/authentication/authentication_screen.dart';
import 'package:exponea_example/navigation/deeplink_bridge.dart';
import 'package:exponea_example/navigation/deeplink_resolver.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/widgets/brand_logo.dart';
import 'package:flutter/material.dart';

enum _AppRoute { loading, auth, shell }

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.white,
      body: Center(
        child: Semantics(
          identifier: 'img_loading_logo',
          image: true,
          label: 'Bloomreach logo',
          child: const BrandLogo.mini(size: 96),
        ),
      ),
    );
  }
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({
    super.key,
    this.skipLoading = false,
    this.startOnShell = false,
  });

  final bool skipLoading;

  /// Test helper: bypass auth gate and show the main shell directly.
  final bool startOnShell;

  @override
  State<ExampleApp> createState() => ExampleAppState();
}

class ExampleAppState extends State<ExampleApp> {
  late final EnvConfig _envConfig = EnvConfig.fromEnvironment();
  _AppRoute _route = _AppRoute.loading;
  DeeplinkAction? _pendingDeeplink;
  DeeplinkBridge? _deeplinkBridge;

  @override
  void initState() {
    super.initState();
    _deeplinkBridge = DeeplinkBridge(onAction: _onDeeplinkAction);
    _deeplinkBridge!.startListening();
    if (widget.startOnShell) {
      _route = _AppRoute.shell;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (widget.skipLoading) {
        _resolveInitialRoute();
      } else {
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _resolveInitialRoute();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _deeplinkBridge?.stopListening();
    super.dispose();
  }

  void _onDeeplinkAction(DeeplinkAction action) {
    if (!mounted) {
      return;
    }
    setState(() => _pendingDeeplink = action);
    // stopAndRestart must reach auth even if shell is not mounted yet.
    if (action == DeeplinkAction.stopAndRestart && _route != _AppRoute.shell) {
      final service = ExponeaServiceScope.of(context);
      service.stopIntegration().whenComplete(() {
        if (!mounted) {
          return;
        }
        service.resetShellState();
        setState(() {
          _route = _AppRoute.auth;
          _pendingDeeplink = null;
        });
      });
    }
  }

  Future<void> _resolveInitialRoute() async {
    final service = ExponeaServiceScope.of(context);
    if (service.isConfigured) {
      setState(() => _route = _AppRoute.shell);
      return;
    }

    if (_envConfig.shouldAutoConfigure) {
      try {
        await service.configure(_envConfig.toConfigureRequest());
        if (mounted) {
          setState(() => _route = _AppRoute.shell);
        }
        return;
      } catch (_) {
        // Fall through to manual auth screen.
      }
    }

    if (mounted) {
      setState(() => _route = _AppRoute.auth);
    }
  }

  void _onConfigured() {
    setState(() => _route = _AppRoute.shell);
  }

  void _onResetToAuth() {
    setState(() => _route = _AppRoute.auth);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildExampleAppTheme(),
      home: switch (_route) {
        _AppRoute.loading => const LoadingScreen(),
        _AppRoute.auth => AuthenticationScreen(
            onConfigured: _onConfigured,
            envConfig: _envConfig,
          ),
        _AppRoute.shell => AppShell(
            envConfig: _envConfig,
            onResetToAuth: _onResetToAuth,
            pendingDeeplink: _pendingDeeplink,
            onDeeplinkConsumed: () {
              if (mounted) {
                setState(() => _pendingDeeplink = null);
              }
            },
          ),
      },
    );
  }
}
