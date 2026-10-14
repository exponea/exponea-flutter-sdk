import 'dart:async';

import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/app/env_config.dart';
import 'package:exponea_example/features/anonymize/anonymize_screen.dart';
import 'package:exponea_example/features/content_blocks/content_blocks_screen.dart';
import 'package:exponea_example/features/flushing/flushing_screen.dart';
import 'package:exponea_example/features/fetching/fetching_screen.dart';
import 'package:exponea_example/features/tracking/tracking_screen.dart';
import 'package:exponea_example/logging/sdk_log_bridge.dart';
import 'package:exponea_example/logging/sdk_log_store_scope.dart';
import 'package:exponea_example/navigation/deeplink_resolver.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/widgets/brand_logo.dart';
import 'package:exponea_example/widgets/configuration_info_sheet.dart';
import 'package:exponea_example/widgets/logs_sheet.dart';
import 'package:exponea_example/widgets/sdk_status_indicator.dart';
import 'package:exponea_example/widgets/stop_integration_dialog.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.envConfig,
    required this.onResetToAuth,
    this.initialTabIndex = 0,
    this.pendingDeeplink,
    this.onDeeplinkConsumed,
  });

  final EnvConfig envConfig;
  final VoidCallback onResetToAuth;
  final int initialTabIndex;
  final DeeplinkAction? pendingDeeplink;
  final VoidCallback? onDeeplinkConsumed;

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  late int _tabIndex;
  late Set<int> _visitedTabs;
  bool _resetting = false;

  static const _tabs = [
    _ShellTab(
      semanticsId: 'btn_nav_fetching',
      label: 'Fetching',
      title: 'Fetching',
      icon: Icons.cloud_download_outlined,
    ),
    _ShellTab(
      semanticsId: 'btn_nav_tracking',
      label: 'Tracking',
      title: 'Tracking',
      icon: Icons.edit_note_outlined,
    ),
    _ShellTab(
      semanticsId: 'btn_nav_flushing',
      label: 'Flushing',
      title: 'Flushing',
      icon: Icons.cloud_upload_outlined,
    ),
    _ShellTab(
      semanticsId: 'btn_nav_anonymize',
      label: 'Anonymize',
      title: 'Anonymize',
      icon: Icons.person_outline,
    ),
    _ShellTab(
      semanticsId: 'btn_nav_content_blocks',
      label: 'In-app CB',
      title: 'In-app Content Blocks',
      icon: Icons.view_carousel_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex;
    _visitedTabs = {widget.initialTabIndex};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenName = _tabs[_tabIndex].label;
        ExponeaServiceScope.of(context).trackPageView(screenName: screenName);
        _consumePendingDeeplink();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pendingDeeplink != null &&
        widget.pendingDeeplink != oldWidget.pendingDeeplink) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _consumePendingDeeplink();
        }
      });
    }
  }

  void _consumePendingDeeplink() {
    final action = widget.pendingDeeplink;
    if (action == null) {
      return;
    }
    unawaited(_handleDeeplink(action));
    widget.onDeeplinkConsumed?.call();
  }

  Future<void> _handleDeeplink(DeeplinkAction action) async {
    switch (action) {
      case DeeplinkAction.stopAndContinue:
        try {
          await ExponeaServiceScope.of(context).stopIntegration();
        } catch (_) {
          // Treat as de-integrated for example-app routing.
        }
        if (!mounted) {
          return;
        }
        _selectTab(0);
        return;
      case DeeplinkAction.stopAndRestart:
        try {
          await ExponeaServiceScope.of(context).stopIntegration();
        } catch (_) {}
        if (!mounted) {
          return;
        }
        ExponeaServiceScope.of(context).resetShellState();
        widget.onResetToAuth();
        return;
      case DeeplinkAction.fetch:
      case DeeplinkAction.track:
      case DeeplinkAction.flush:
      case DeeplinkAction.anonymize:
      case DeeplinkAction.inAppCb:
        final index = DeeplinkResolver.tabIndexFor(action);
        if (index != null) {
          _selectTab(index);
        }
    }
  }

  void _selectTab(int index) {
    setState(() {
      _tabIndex = index;
      _visitedTabs.add(index);
    });
    ExponeaServiceScope.of(context).trackPageView(
      screenName: _tabs[index].label,
    );
  }

  Future<void> resetState() async {
    if (_resetting) {
      return;
    }
    final choice = await showStopIntegrationDialog(
      context,
      backToAuthSemanticsId: 'btn_reset_back_to_auth',
      stopAndContinueSemanticsId: 'btn_reset_stop_and_continue',
      cancelSemanticsId: 'btn_reset_cancel',
    );
    if (!mounted) {
      return;
    }
    switch (choice) {
      case StopIntegrationChoice.cancel:
        return;
      case StopIntegrationChoice.backToAuth:
        setState(() => _resetting = true);
        try {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
          final service = ExponeaServiceScope.of(context);
          final logStoreScope = SdkLogStoreScope.of(context);
          try {
            await service.stopIntegration();
          } catch (error) {
            // Reset must always return to auth, even if stopIntegration fails.
            service.appendLog('Reset: ignoring stopIntegration error ($error)');
          }
          service.resetShellState();
          logStoreScope.clear();
          await SdkLogBridge.clearNative();
          if (!mounted) {
            return;
          }
          setState(() {
            _tabIndex = 0;
            _visitedTabs = {0};
          });
          widget.onResetToAuth();
        } finally {
          if (mounted) {
            setState(() => _resetting = false);
          }
        }
      case StopIntegrationChoice.stopAndContinue:
        // Stop SDK only — no navigation, no log wipe. Semafor goes red.
        setState(() => _resetting = true);
        try {
          await ExponeaServiceScope.of(context).stopIntegration();
        } catch (error) {
          // Ignore; the SDK is treated as de-integrated.
        } finally {
          if (mounted) {
            setState(() => _resetting = false);
          }
        }
    }
  }

  Future<void> _openLogs() => showLogsSheet(context);

  Future<void> _openConfiguration() => showConfigurationInfoSheet(context);

  Widget _buildTabScreen(int index) => switch (index) {
        0 => const FetchingScreen(),
        1 => const TrackingScreen(),
        2 => const FlushingScreen(),
        3 => AnonymizeScreen(onResetToAuth: widget.onResetToAuth),
        4 => const ContentBlocksScreen(),
        _ => const SizedBox.shrink(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BrandColors.black,
        foregroundColor: BrandColors.white,
        title: Row(
          children: [
            Semantics(
              identifier: 'btn_shell_logo',
              button: true,
              label: 'Bloomreach logo',
              child: InkWell(
                onTap: _openConfiguration,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: BrandLogo.mini(size: 28),
                ),
              ),
            ),
            const Spacer(),
            const SdkStatusIndicator(),
            Semantics(
              identifier: 'btn_open_logs',
              button: true,
              label: 'Logs',
              child: IconButton(
                onPressed: _openLogs,
                icon: const Icon(Icons.menu),
                tooltip: 'Logs',
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            identifier: 'btn_reset_state',
            button: true,
            label: 'Reset state',
            child: TextButton(
              onPressed: _resetting ? null : resetState,
              child: Text(_resetting ? 'Resetting…' : 'Reset'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          for (int i = 0; i < _tabs.length; i++)
            if (_visitedTabs.contains(i))
              Offstage(
                offstage: _tabIndex != i,
                child: TickerMode(
                  enabled: _tabIndex == i,
                  child: _buildTabScreen(i),
                ),
              ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          _selectTab(index);
        },
        destinations: [
          // Semantics must own onTap: on iOS, Appium activates the accessibility
          // node (not a hit-test). button:true without onTap is a silent no-op, so
          // tabs after Tracking never switch even though Click Element "passes".
          for (final (index, item) in _tabs.indexed)
            NavigationDestination(
              icon: Semantics(
                identifier: item.semanticsId,
                button: true,
                label: item.label,
                onTap: () => _selectTab(index),
                // Do not excludeSemantics: XCUITest sometimes hit-tests the
                // Material destination; excluding broke Anonymize activate path.
                child: Icon(item.icon),
              ),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.semanticsId,
    required this.label,
    required this.title,
    required this.icon,
  });

  final String semanticsId;
  final String label;
  final String title;
  final IconData icon;
}
