import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

import 'app_inbox_detail_page.dart';

class AppInboxListPage extends StatelessWidget {
  const AppInboxListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App inbox')),
      body: AppInboxListView(
        onAppInboxItemClicked: (AppInboxMessage message) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AppInboxDetailPage(messageId: message.id),
          ));
        },
      ),
    );
  }
}
