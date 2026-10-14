import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

class AppInboxDetailPage extends StatelessWidget {
  const AppInboxDetailPage({
    super.key,
    required this.messageId,
  });

  final String messageId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          identifier: 'btn_app_inbox_detail_back',
          button: true,
          label: 'Back',
          child: const BackButton(),
        ),
        title: Semantics(
          identifier: 'lbl_app_inbox_detail_title',
          label: 'App inbox message',
          child: const Text('App inbox message'),
        ),
      ),
      body: Semantics(
        identifier: 'view_app_inbox_detail',
        child: AppInboxDetailView(messageId: messageId),
      ),
    );
  }
}
