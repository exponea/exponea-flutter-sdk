import 'dart:io';

import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

class InAppCbPage extends StatelessWidget {
  const InAppCbPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformSpecificPlaceholderId =
        Platform.isIOS ? 'ph_x_example_iOS' : 'ph_x_example_Android';
    const contentBlockFrequency = 10;
    List<Widget> items = [];
    for (int i = 0; i < 100; i++) {
      if (i % contentBlockFrequency == 0) {
        items.add(const InAppContentBlockPlaceholder(
            placeholderId: 'example_list'));
      } else {
        items.add(
          const ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('InApp CB Example'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Placeholder: example_top'),
            InAppContentBlockPlaceholder(
              placeholderId: 'example_top',
              onMessageShown: (placeholderId, contentBlock) {
                print('InAppContentBlockPlaceholder $placeholderId: onMessageShown invoked');
              },
              onNoMessageFound: (placeholderId) {
                print('InAppContentBlockPlaceholder $placeholderId: onNoMessageFound invoked');
              },
              onActionClicked: (placeholderId, contentBlock, action) {
                print('InAppContentBlockPlaceholder $placeholderId: onActionClicked invoked');
              },
              onCloseClicked: (placeholderId, contentBlock) {
                print('InAppContentBlockPlaceholder $placeholderId: onCloseClicked invoked');
              },
              onError: (placeholderId, contentBlock, errorMessage) {
                print('InAppContentBlockPlaceholder $placeholderId: onError invoked');
              },
            ),
            const Text('Placeholder: platformSpecificPlaceholderId'),
            InAppContentBlockPlaceholder(
                placeholderId: platformSpecificPlaceholderId),
            const Text('Products (Placeholder: example_list)'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: items,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
