import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/features/app_inbox/app_inbox_list_page.dart';
import 'package:exponea_example/features/fetching/fetch_recommendation_dialog.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/services/sdk_status_scope.dart';
import 'package:exponea_example/services/sdk_status_store.dart';
import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

const _resultPlaceholder = 'Result will appear here.';

class FetchingScreen extends StatefulWidget {
  const FetchingScreen({super.key});

  @override
  State<FetchingScreen> createState() => _FetchingScreenState();
}

class _FetchingScreenState extends State<FetchingScreen> {
  String _resultText = _resultPlaceholder;
  bool _loading = false;

  Future<void> _runFetch(Future<String> Function() fetch) async {
    setState(() => _loading = true);
    try {
      final result = await fetch();
      if (mounted) {
        setState(() => _resultText = result);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _resultText = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _fetchConsents() {
    final service = ExponeaServiceScope.of(context);
    return _runFetch(service.fetchConsents);
  }

  Future<void> _fetchRecommendations() async {
    final recommendationId = await showFetchRecommendationDialog(context);
    if (recommendationId == null || !mounted) {
      return;
    }
    final service = ExponeaServiceScope.of(context);
    await _runFetch(
      () => service.fetchRecommendation(recommendationId: recommendationId),
    );
  }

  Future<void> _fetchSegments() {
    final service = ExponeaServiceScope.of(context);
    return _runFetch(service.fetchSegments);
  }

  void _clearResult() {
    setState(() => _resultText = _resultPlaceholder);
  }

  void _openAppInbox() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AppInboxListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sdkReady =
        SdkStatusScope.of(context).state != SdkLifecycleState.notInitialized;
    return ColoredBox(
      color: BrandColors.grey100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'Fetch',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FetchButton(
                    semanticsId: 'btn_fetch_consents',
                    label: 'Fetch Consents',
                    onPressed: _loading ? null : _fetchConsents,
                  ),
                  const SizedBox(height: 6),
                  _FetchButton(
                    semanticsId: 'btn_fetch_recommendations',
                    label: 'Fetch Recommendations',
                    onPressed: _loading ? null : _fetchRecommendations,
                  ),
                  const SizedBox(height: 6),
                  _FetchButton(
                    semanticsId: 'btn_fetch_segments',
                    label: 'Fetch Segments',
                    onPressed: _loading ? null : _fetchSegments,
                  ),
                  if (sdkReady) ...[
                    const SizedBox(height: 6),
                    Semantics(
                      identifier: 'btn_app_inbox_provider',
                      button: true,
                      label: 'App Inbox provider button',
                      child: const SizedBox(
                        height: 44,
                        width: double.infinity,
                        child: AppInboxProvider(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _FetchButton(
                      semanticsId: 'btn_open_inbox',
                      label: 'Open App Inbox (Flutter Widgets)',
                      onPressed: _openAppInbox,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _SectionCard(
                title: 'Result',
                expandBody: true,
                trailing: Semantics(
                  identifier: 'btn_clear_result',
                  button: true,
                  label: 'Clear result',
                  child: IconButton(
                    onPressed: _clearResult,
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear result',
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      identifier: 'status_fetch_loading',
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        value: _loading ? null : 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: BrandColors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: BrandColors.grey300),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(8),
                          child: Semantics(
                            identifier: 'lbl_fetch_result',
                            label: _resultText,
                            child: SelectableText(
                              _resultText,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: BrandColors.grey600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    this.expandBody = false,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: BrandColors.grey300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            if (expandBody) Expanded(child: child) else child,
          ],
        ),
      ),
    );
  }
}

class _FetchButton extends StatelessWidget {
  const _FetchButton({
    required this.semanticsId,
    required this.label,
    required this.onPressed,
  });

  final String semanticsId;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      button: true,
      label: label,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }
}
