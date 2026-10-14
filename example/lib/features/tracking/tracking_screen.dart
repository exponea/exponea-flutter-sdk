import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/features/tracking/identify_customer_dialog.dart';
import 'package:exponea_example/features/tracking/track_custom_event_dialog.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/widgets/action_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String _cookieId = '<not initialized>';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCookieId());
  }

  Future<void> _loadCookieId() async {
    final service = ExponeaServiceScope.of(context);
    final cookie = await service.getCustomerCookie();
    if (mounted) {
      setState(() {
        _cookieId = cookie.isEmpty ? '<not initialized>' : cookie;
      });
    }
  }

  bool get _canCopyCookie => _cookieId != '<not initialized>';

  Future<void> _copyCookieId() async {
    await Clipboard.setData(ClipboardData(text: _cookieId));
    if (!mounted) {
      return;
    }
    showActionSnackBar(context, 'Cookie ID copied to clipboard');
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    String? snackBarMessage,
  }) async {
    setState(() => _loading = true);
    try {
      await action();
      if (mounted && snackBarMessage != null) {
        showActionSnackBar(context, snackBarMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _setAuthToken() async {
    final service = ExponeaServiceScope.of(context);
    final message = await service.setAuthToken();
    if (mounted) {
      showActionSnackBar(context, message);
    }
  }

  Future<void> _requestPushPermission() async {
    final granted =
        await ExponeaServiceScope.of(context).requestPushAuthorization();
    if (mounted) {
      showActionSnackBar(context, 'Push permission granted: $granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrandColors.grey100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'Cookie ID',
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      identifier: 'lbl_cookie_id',
                      label: _cookieId,
                      child: SelectableText(
                        _cookieId,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: BrandColors.grey600,
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    identifier: 'btn_copy_cookie_id',
                    button: true,
                    label: 'Copy Cookie ID',
                    child: IconButton(
                      onPressed: _canCopyCookie ? _copyCookieId : null,
                      tooltip: 'Copy Cookie ID',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints.tightFor(width: 32, height: 32),
                      icon: const Icon(Icons.copy_outlined, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SectionCard(
              title: 'Customer',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TrackingButton(
                    semanticsId: 'btn_identify_customer',
                    label: 'Identify Customer',
                    filled: true,
                    onPressed: _loading
                        ? null
                        : () => showIdentifyCustomerDialog(context),
                  ),
                  const SizedBox(height: 6),
                  _TrackingButton(
                    semanticsId: 'btn_set_auth_token',
                    label: 'Set Auth Token',
                    onPressed:
                        _loading ? null : () => _runAction(_setAuthToken),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SectionCard(
              title: 'Events',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TrackingButton(
                    semanticsId: 'btn_track_custom_event',
                    label: 'Track Custom Event',
                    onPressed: _loading
                        ? null
                        : () => showTrackCustomEventDialog(context),
                  ),
                  const SizedBox(height: 6),
                  _TrackingButton(
                    semanticsId: 'btn_track_payment',
                    label: 'Track Payment',
                    onPressed: _loading
                        ? null
                        : () => _runAction(
                              ExponeaServiceScope.of(context).trackDemoPayment,
                              snackBarMessage:
                                  'Payment tracked: 99 USD demo_item',
                            ),
                  ),
                  const SizedBox(height: 6),
                  _TrackingButton(
                    semanticsId: 'btn_track_page_view',
                    label: 'Track Page View',
                    onPressed: _loading
                        ? null
                        : () => _runAction(
                              () => ExponeaServiceScope.of(context)
                                  .trackPageView(screenName: 'Tracking'),
                              snackBarMessage: 'Page view tracked: Tracking',
                            ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SectionCard(
              title: 'Push',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2 x 2 grid keeps every push action on screen at the automation
                  // reference size (off-screen nodes are hidden from XCUITest on iOS).
                  // IntrinsicHeight: a wrapped label must not make the pair uneven.
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _TrackingButton(
                            semanticsId: 'btn_request_push',
                            label: 'Request Push Permission',
                            filled: true,
                            onPressed: _loading
                                ? null
                                : () => _runAction(_requestPushPermission),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _TrackingButton(
                            semanticsId: 'btn_track_fcm_token',
                            label: 'Track FCM Token',
                            onPressed: _loading
                                ? null
                                : () => _runAction(
                                      ExponeaServiceScope.of(context)
                                          .trackDemoFcmToken,
                                      snackBarMessage:
                                          'FCM token tracked (demo value)',
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _TrackingButton(
                          semanticsId: 'btn_track_push_delivered',
                          label: 'Track Delivered',
                          onPressed: _loading
                              ? null
                              : () => _runAction(
                                    ExponeaServiceScope.of(context)
                                        .trackDemoPushDelivered,
                                    snackBarMessage:
                                        'Delivered push tracked (campaign_id=demo)',
                                  ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _TrackingButton(
                          semanticsId: 'btn_track_push_clicked',
                          label: 'Track Clicked',
                          onPressed: _loading
                              ? null
                              : () => _runAction(
                                    ExponeaServiceScope.of(context)
                                        .trackDemoPushClicked,
                                    snackBarMessage:
                                        'Clicked push tracked (campaign_id=demo)',
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
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
  });

  final String title;
  final Widget child;

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
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _TrackingButton extends StatelessWidget {
  const _TrackingButton({
    required this.semanticsId,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String semanticsId;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final button = filled
        ? FilledButton(
            onPressed: onPressed,
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: BrandColors.black,
              backgroundColor: BrandColors.white,
              side: const BorderSide(color: BrandColors.black),
              minimumSize: const Size.fromHeight(44),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: Text(label),
          );

    return Semantics(
      identifier: semanticsId,
      button: true,
      label: label,
      child: SizedBox(
        width: double.infinity,
        child: button,
      ),
    );
  }
}
