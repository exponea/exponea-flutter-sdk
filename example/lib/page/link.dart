import 'package:flutter/material.dart';

class LinkPage extends StatelessWidget {
  final String link;

  const LinkPage({
    Key? key,
    required this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link'),
      ),
      body: Center(
        child: Text(link),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.done),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
