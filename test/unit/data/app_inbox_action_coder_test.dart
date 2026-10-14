import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppInboxCoder.encodeAction', () {
    const encode = AppInboxCoder.encodeAction;

    test('empty action', () {
      const action = AppInboxAction();
      expect(encode(action), <String, dynamic>{});
    });

    test('action only', () {
      const action = AppInboxAction(action: 'mock-action');
      expect(encode(action), {'action': 'mock-action'});
    });

    test('title only', () {
      const action = AppInboxAction(title: 'mock-title');
      expect(encode(action), {'title': 'mock-title'});
    });

    test('url only', () {
      const action = AppInboxAction(url: 'https://mock.url');
      expect(encode(action), {'url': 'https://mock.url'});
    });

    test('full', () {
      const action = AppInboxAction(
        action: 'mock-action',
        title: 'mock-title',
        url: 'https://mock.url',
      );
      expect(encode(action), {
        'action': 'mock-action',
        'title': 'mock-title',
        'url': 'https://mock.url',
      });
    });
  });

  group('AppInboxCoder.encodeActionMessage', () {
    const encode = AppInboxCoder.encodeActionMessage;

    const minMessage = AppInboxMessage(id: 'mock-id', type: 'mock-type');
    const fullMessage = AppInboxMessage(
      id: 'mock-id',
      type: 'mock-type',
      isRead: true,
      createTime: 1,
      content: {'mock-key': 'mock-value'},
    );

    test('empty action with minimal message', () {
      // encodeAction({}) returns {} (empty map, not null), so the 'action'
      // key is retained because removeWhere only strips null values.
      const action = AppInboxAction();
      expect(encode(action, minMessage), {
        'action': <String, dynamic>{},
        'message': {'id': 'mock-id', 'type': 'mock-type'},
      });
    });

    test('full action with minimal message', () {
      const action = AppInboxAction(
        action: 'mock-action',
        title: 'mock-title',
        url: 'https://mock.url',
      );
      expect(encode(action, minMessage), {
        'action': {
          'action': 'mock-action',
          'title': 'mock-title',
          'url': 'https://mock.url',
        },
        'message': {'id': 'mock-id', 'type': 'mock-type'},
      });
    });

    test('full action with full message', () {
      const action = AppInboxAction(action: 'mock-action');
      expect(encode(action, fullMessage), {
        'action': {'action': 'mock-action'},
        'message': {
          'id': 'mock-id',
          'type': 'mock-type',
          'isRead': true,
          'createTime': 1,
          'content': {'mock-key': 'mock-value'},
        },
      });
    });
  });
}
