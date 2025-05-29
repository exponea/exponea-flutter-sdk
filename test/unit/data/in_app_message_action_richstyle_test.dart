import 'package:exponea/exponea.dart';
import 'package:exponea/src/data/encoder/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base.dart';

void main() {
  group('InAppMessageAction richstyle', () {
    const encode = InAppMessageActionEncoder.encode;
    const decode = InAppMessageActionEncoder.decode;

    final data = readMapData('in_app_message_action_richstyle');
    test('check data', () async {
      expect(data.length, 6);
    });
    final clickNulls = data[0];
    final clickMinimal = data[1];
    final closeMinimal = data[2];
    final closeComplete = data[3];
    final errorComplete = data[4];
    final shown = data[5];

    group('encode', () {
      test('click action with nulls', () {
        const inAppMessageAction = InAppMessageAction(
          message: InAppMessage(
              id: '5dd86f44511946ea55132f29',
              name: 'Test serving in-app message',
              messageType: 'modal',
              frequency: 'unknown',
              payload: {
                'title': 'filip.vozar@exponea.com',
                'body_text': 'This is an example of your in-app message body text.',
                'image_url': 'https://i.ytimg.com/vi/t4nM1FoUqYs/maxresdefault.jpg',
                'title_text_color': '#000000',
                'title_text_size': '22px',
                'body_text_color': '#000000',
                'body_text_size': '14px',
                'background_color': '#ffffff',
                'overlay_color': '#FF00FF10',
                'buttons_align': 'center',
                'text_position': 'top',
                'image_enabled': true,
                'image_size': 'auto',
                'image_margin': '200 10 10 10',
                'image_corner_radius': '10px',
                'image_aspect_ratio_width': '16',
                'image_aspect_ratio_height': '9',
                'image_object_fit': 'fill',
                'image_overlay_enabled': false,
                'title_enabled': true,
                'title_format': ['bold'],
                'title_align': 'center',
                'title_line_height': '32px',
                'title_padding': '200px 10px 15px 10px',
                'title_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'body_enabled': true,
                'body_format': ['bold'],
                'body_align': 'center',
                'body_line_height': '32px',
                'body_padding': '200px 10px 15px 10px',
                'body_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'close_button_enabled': true,
                'close_button_margin': '50px 10px',
                'close_button_background_color': 'yellow',
                'close_button_color': '#ffffff',
                'buttons': [
                  {
                    'button_text': 'Action',
                    'button_type': 'deep-link',
                    'button_link': 'https://someaddress.com',
                    'button_text_color': '#ffffff',
                    'button_background_color': 'blue',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  },
                  {
                    'button_text': 'Cancel',
                    'button_type': 'cancel',
                    'button_text_color': '#ffffff',
                    'button_background_color': '#f44cac',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  }
                ]
              },
              variantId: 0,
              variantName: 'Variant A',
              trigger: {
                'event_type': 'session_start',
                'filter': []
              },
              dateFilter: {
                'enabled': false
              },
              isHtml: false,
              isRichText: true
          ),
          type: InAppMessageActionType.click,
        );

        expect(encode(inAppMessageAction), clickNulls);
      });

      test('click action minimal', () {
        const inAppMessageAction = InAppMessageAction(
          message: InAppMessage(
              id: '5dd86f44511946ea55132f29',
              name: 'Test serving in-app message',
              messageType: 'modal',
              frequency: 'unknown',
              payload: {
                'title': 'filip.vozar@exponea.com',
                'body_text': 'This is an example of your in-app message body text.',
                'image_url': 'https://i.ytimg.com/vi/t4nM1FoUqYs/maxresdefault.jpg',
                'title_text_color': '#000000',
                'title_text_size': '22px',
                'body_text_color': '#000000',
                'body_text_size': '14px',
                'background_color': '#ffffff',
                'overlay_color': '#FF00FF10',
                'buttons_align': 'center',
                'text_position': 'top',
                'image_enabled': true,
                'image_size': 'auto',
                'image_margin': '200 10 10 10',
                'image_corner_radius': '10px',
                'image_aspect_ratio_width': '16',
                'image_aspect_ratio_height': '9',
                'image_object_fit': 'fill',
                'image_overlay_enabled': false,
                'title_enabled': true,
                'title_format': ['bold'],
                'title_align': 'center',
                'title_line_height': '32px',
                'title_padding': '200px 10px 15px 10px',
                'title_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'body_enabled': true,
                'body_format': ['bold'],
                'body_align': 'center',
                'body_line_height': '32px',
                'body_padding': '200px 10px 15px 10px',
                'body_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'close_button_enabled': true,
                'close_button_margin': '50px 10px',
                'close_button_background_color': 'yellow',
                'close_button_color': '#ffffff',
                'buttons': [
                  {
                    'button_text': 'Action',
                    'button_type': 'deep-link',
                    'button_link': 'https://someaddress.com',
                    'button_text_color': '#ffffff',
                    'button_background_color': 'blue',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  },
                  {
                    'button_text': 'Cancel',
                    'button_type': 'cancel',
                    'button_text_color': '#ffffff',
                    'button_background_color': '#f44cac',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  }
                ]
              },
              variantId: 0,
              variantName: 'Variant A',
              trigger: {
                'event_type': 'session_start',
                'filter': []
              },
              dateFilter: {
                'enabled': false
              },
              isHtml: false,
              isRichText: true
          ),
          type: InAppMessageActionType.click,
          button: InAppMessageButton(
            text: "Click me!",
            url: "https://example.com",
          ),
        );

        expect(encode(inAppMessageAction), clickMinimal);
      });

      test('close action minimal', () {
        const inAppMessageAction = InAppMessageAction(
          message: InAppMessage(
              id: '5dd86f44511946ea55132f29',
              name: 'Test serving in-app message',
              messageType: 'modal',
              frequency: 'unknown',
              payload: {
                'title': 'filip.vozar@exponea.com',
                'body_text': 'This is an example of your in-app message body text.',
                'image_url': 'https://i.ytimg.com/vi/t4nM1FoUqYs/maxresdefault.jpg',
                'title_text_color': '#000000',
                'title_text_size': '22px',
                'body_text_color': '#000000',
                'body_text_size': '14px',
                'background_color': '#ffffff',
                'overlay_color': '#FF00FF10',
                'buttons_align': 'center',
                'text_position': 'top',
                'image_enabled': true,
                'image_size': 'auto',
                'image_margin': '200 10 10 10',
                'image_corner_radius': '10px',
                'image_aspect_ratio_width': '16',
                'image_aspect_ratio_height': '9',
                'image_object_fit': 'fill',
                'image_overlay_enabled': false,
                'title_enabled': true,
                'title_format': ['bold'],
                'title_align': 'center',
                'title_line_height': '32px',
                'title_padding': '200px 10px 15px 10px',
                'title_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'body_enabled': true,
                'body_format': ['bold'],
                'body_align': 'center',
                'body_line_height': '32px',
                'body_padding': '200px 10px 15px 10px',
                'body_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'close_button_enabled': true,
                'close_button_margin': '50px 10px',
                'close_button_background_color': 'yellow',
                'close_button_color': '#ffffff',
                'buttons': [
                  {
                    'button_text': 'Action',
                    'button_type': 'deep-link',
                    'button_link': 'https://someaddress.com',
                    'button_text_color': '#ffffff',
                    'button_background_color': 'blue',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  },
                  {
                    'button_text': 'Cancel',
                    'button_type': 'cancel',
                    'button_text_color': '#ffffff',
                    'button_background_color': '#f44cac',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  }
                ]
              },
              variantId: 0,
              variantName: 'Variant A',
              trigger: {
                'event_type': 'session_start',
                'filter': []
              },
              dateFilter: {
                'enabled': false
              },
              isHtml: false,
              isRichText: true
          ),
          type: InAppMessageActionType.close,
          interaction: false,
        );


        expect(encode(inAppMessageAction), closeMinimal);
      });

      test('close action complete', () {
        const inAppMessageAction = InAppMessageAction(
          message: InAppMessage(
              id: '5dd86f44511946ea55132f29',
              name: 'Test serving in-app message',
              messageType: 'modal',
              frequency: 'unknown',
              payload: {
                'title': 'filip.vozar@exponea.com',
                'body_text': 'This is an example of your in-app message body text.',
                'image_url': 'https://i.ytimg.com/vi/t4nM1FoUqYs/maxresdefault.jpg',
                'title_text_color': '#000000',
                'title_text_size': '22px',
                'body_text_color': '#000000',
                'body_text_size': '14px',
                'background_color': '#ffffff',
                'overlay_color': '#FF00FF10',
                'buttons_align': 'center',
                'text_position': 'top',
                'image_enabled': true,
                'image_size': 'auto',
                'image_margin': '200 10 10 10',
                'image_corner_radius': '10px',
                'image_aspect_ratio_width': '16',
                'image_aspect_ratio_height': '9',
                'image_object_fit': 'fill',
                'image_overlay_enabled': false,
                'title_enabled': true,
                'title_format': ['bold'],
                'title_align': 'center',
                'title_line_height': '32px',
                'title_padding': '200px 10px 15px 10px',
                'title_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'body_enabled': true,
                'body_format': ['bold'],
                'body_align': 'center',
                'body_line_height': '32px',
                'body_padding': '200px 10px 15px 10px',
                'body_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'close_button_enabled': true,
                'close_button_margin': '50px 10px',
                'close_button_background_color': 'yellow',
                'close_button_color': '#ffffff',
                'buttons': [
                  {
                    'button_text': 'Action',
                    'button_type': 'deep-link',
                    'button_link': 'https://someaddress.com',
                    'button_text_color': '#ffffff',
                    'button_background_color': 'blue',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  },
                  {
                    'button_text': 'Cancel',
                    'button_type': 'cancel',
                    'button_text_color': '#ffffff',
                    'button_background_color': '#f44cac',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  }
                ]
              },
              variantId: 0,
              variantName: 'Variant A',
              trigger: {
                'event_type': 'session_start',
                'filter': []
              },
              dateFilter: {
                'enabled': false
              },
              isHtml: false,
              isRichText: true
          ),
          type: InAppMessageActionType.close,
          interaction: true,
          button: InAppMessageButton(
            text: "Click me!",
          ),
        );

        expect(encode(inAppMessageAction), closeComplete);
      });

      test('error action', () {
        const inAppMessageAction = InAppMessageAction(
          message: InAppMessage(
              id: '5dd86f44511946ea55132f29',
              name: 'Test serving in-app message',
              messageType: 'modal',
              frequency: 'unknown',
              payload: {
                'title': 'filip.vozar@exponea.com',
                'body_text': 'This is an example of your in-app message body text.',
                'image_url': 'https://i.ytimg.com/vi/t4nM1FoUqYs/maxresdefault.jpg',
                'title_text_color': '#000000',
                'title_text_size': '22px',
                'body_text_color': '#000000',
                'body_text_size': '14px',
                'background_color': '#ffffff',
                'overlay_color': '#FF00FF10',
                'buttons_align': 'center',
                'text_position': 'top',
                'image_enabled': true,
                'image_size': 'auto',
                'image_margin': '200 10 10 10',
                'image_corner_radius': '10px',
                'image_aspect_ratio_width': '16',
                'image_aspect_ratio_height': '9',
                'image_object_fit': 'fill',
                'image_overlay_enabled': false,
                'title_enabled': true,
                'title_format': ['bold'],
                'title_align': 'center',
                'title_line_height': '32px',
                'title_padding': '200px 10px 15px 10px',
                'title_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'body_enabled': true,
                'body_format': ['bold'],
                'body_align': 'center',
                'body_line_height': '32px',
                'body_padding': '200px 10px 15px 10px',
                'body_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'close_button_enabled': true,
                'close_button_margin': '50px 10px',
                'close_button_background_color': 'yellow',
                'close_button_color': '#ffffff',
                'buttons': [
                  {
                    'button_text': 'Action',
                    'button_type': 'deep-link',
                    'button_link': 'https://someaddress.com',
                    'button_text_color': '#ffffff',
                    'button_background_color': 'blue',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  },
                  {
                    'button_text': 'Cancel',
                    'button_type': 'cancel',
                    'button_text_color': '#ffffff',
                    'button_background_color': '#f44cac',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  }
                ]
              },
              variantId: 0,
              variantName: 'Variant A',
              trigger: {
                'event_type': 'session_start',
                'filter': []
              },
              dateFilter: {
                'enabled': false
              },
              isHtml: false,
              isRichText: true
          ),
          type: InAppMessageActionType.error,
          errorMessage: 'Something goes wrong',
        );

        expect(encode(inAppMessageAction), errorComplete);
      });

      test('show action', () {
        const inAppMessageAction = InAppMessageAction(
          message: InAppMessage(
              id: '5dd86f44511946ea55132f29',
              name: 'Test serving in-app message',
              messageType: 'modal',
              frequency: 'unknown',
              payload: {
                'title': 'filip.vozar@exponea.com',
                'body_text': 'This is an example of your in-app message body text.',
                'image_url': 'https://i.ytimg.com/vi/t4nM1FoUqYs/maxresdefault.jpg',
                'title_text_color': '#000000',
                'title_text_size': '22px',
                'body_text_color': '#000000',
                'body_text_size': '14px',
                'background_color': '#ffffff',
                'overlay_color': '#FF00FF10',
                'buttons_align': 'center',
                'text_position': 'top',
                'image_enabled': true,
                'image_size': 'auto',
                'image_margin': '200 10 10 10',
                'image_corner_radius': '10px',
                'image_aspect_ratio_width': '16',
                'image_aspect_ratio_height': '9',
                'image_object_fit': 'fill',
                'image_overlay_enabled': false,
                'title_enabled': true,
                'title_format': ['bold'],
                'title_align': 'center',
                'title_line_height': '32px',
                'title_padding': '200px 10px 15px 10px',
                'title_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'body_enabled': true,
                'body_format': ['bold'],
                'body_align': 'center',
                'body_line_height': '32px',
                'body_padding': '200px 10px 15px 10px',
                'body_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                'close_button_enabled': true,
                'close_button_margin': '50px 10px',
                'close_button_background_color': 'yellow',
                'close_button_color': '#ffffff',
                'buttons': [
                  {
                    'button_text': 'Action',
                    'button_type': 'deep-link',
                    'button_link': 'https://someaddress.com',
                    'button_text_color': '#ffffff',
                    'button_background_color': 'blue',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  },
                  {
                    'button_text': 'Cancel',
                    'button_type': 'cancel',
                    'button_text_color': '#ffffff',
                    'button_background_color': '#f44cac',
                    'button_width': 'hug',
                    'button_corner_radius': '12dp',
                    'button_margin': '20px 10px 15px 10px',
                    'button_font_size': '24px',
                    'button_line_height': '32px',
                    'button_padding': '20px 10px 15px 10px',
                    'button_border_color': 'black',
                    'button_border_width': '1px',
                    'button_font_url': 'https://webpagepublicity.com/free-fonts/x/Xtrusion%20(BRK).ttf',
                    'button_font_format': ['bold'],
                    'button_enabled': true
                  }
                ]
              },
              variantId: 0,
              variantName: 'Variant A',
              trigger: {
                'event_type': 'session_start',
                'filter': []
              },
              dateFilter: {
                'enabled': false
              },
              isHtml: false,
              isRichText: true
          ),
          type: InAppMessageActionType.show,
        );

        expect(encode(inAppMessageAction), shown);
      });
    });

    group('decode', () {
      test('click action with nulls', () {
        final inAppMessageAction = decode(clickNulls);
        expect(encode(inAppMessageAction), clickNulls);
      });

      test('click action minimal', () {
        final inAppMessageAction = decode(clickMinimal);
        expect(encode(inAppMessageAction), clickMinimal);
      });

      test('close action minimal', () {
        final inAppMessageAction = decode(closeMinimal);
        expect(encode(inAppMessageAction), closeMinimal);
      });

      test('close action complete', () {
        final inAppMessageAction = decode(closeComplete);
        expect(encode(inAppMessageAction), closeComplete);
      });

      test('error action', () {
        final inAppMessageAction = decode(errorComplete);
        expect(encode(inAppMessageAction), errorComplete);
      });

      test('show action', () {
        final inAppMessageAction = decode(shown);
        expect(encode(inAppMessageAction), shown);
      });
    });
  });
}
