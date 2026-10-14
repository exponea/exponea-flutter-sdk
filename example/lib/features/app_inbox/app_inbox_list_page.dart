import 'package:exponea_example/features/app_inbox/app_inbox_detail_page.dart';
import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

class AppInboxListPage extends StatelessWidget {
  const AppInboxListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          identifier: 'btn_app_inbox_back',
          button: true,
          label: 'Back',
          child: const BackButton(),
        ),
        title: Semantics(
          identifier: 'lbl_app_inbox_title',
          label: 'App inbox',
          child: const Text('App inbox'),
        ),
      ),
      body: Semantics(
        identifier: 'list_app_inbox',
        child: AppInboxListView(
          onAppInboxItemClicked: (AppInboxMessage message) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) =>
                    AppInboxDetailPage(messageId: message.id),
              ),
            );
          },
        ),
      ),
    );
  }
}
