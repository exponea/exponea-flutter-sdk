import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

class AppInboxDetailPage extends StatelessWidget {
  final String messageId;

  const AppInboxDetailPage({super.key, required this.messageId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App inbox message')),
      body: AppInboxDetailView(messageId: messageId),
    );
  }
}
