import 'dart:io';

import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

class InAppCbCarouselPage extends StatelessWidget {
  const InAppCbCarouselPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformSpecificPlaceholderId = Platform.isIOS ? 'example_carousel_ios' : 'example_carousel_and';
    return Scaffold(
      appBar: AppBar(
        title: const Text('InApp CB Carousel Example'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Default Carousel: example_carousel'),
              InAppContentBlockCarousel(
                placeholderId: 'example_carousel',
                onMessageShown: (placeholderId, contentBlock, index, count) {
                  print('InAppContentBlockCarousel $placeholderId: onMessageShown invoked');
                },
                onActionClicked: (placeholderId, contentBlock, action) {
                  print('InAppContentBlockCarousel $placeholderId: action ${action.name} has been clicked in carousel');
                },
                onCloseClicked: (placeholderId, contentBlock) {
                  print('InAppContentBlockCarousel $placeholderId: close action has been clicked in carousel');
                },
                onError: (placeholderId, contentBlock, errorMessage) {
                  print('InAppContentBlockCarousel $placeholderId error: $errorMessage');
                },
                onMessagesChanged: (count, messages) {
                  print('InAppContentBlockCarousel: messages changed with new count: $count');
                },
                onNoMessageFound: (placeholderId) {
                  print('InAppContentBlockCarousel $placeholderId is empty');
                },
                onHeightUpdate: (placeholderId, height) {
                  print('InAppContentBlockCarousel $placeholderId height changed to: $height');
                },

              ),
              const Text('Customized Carousel: example_carousel'),
              InAppContentBlockCarousel(
                placeholderId: 'example_carousel',
                maxMessagesCount: 5,
                scrollDelay: 10,
                filterContentBlocks: (contentBlocks)
                {
                  return contentBlocks.where((element) => !element.name.contains('discarded')).toList();
                },
                sortContentBlocks: (contentBlocks)
                {
                  return contentBlocks.reversed.toList();
                },
              ),
              Text('Platform specific Carousel: $platformSpecificPlaceholderId'),
              InAppContentBlockCarousel(placeholderId: platformSpecificPlaceholderId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
