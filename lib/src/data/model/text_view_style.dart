import 'package:exponea/exponea.dart';
import 'package:flutter/material.dart';

import '../util/Codable.dart';

class TextViewStyle extends Encodable {
  final bool? visible;
  final String? textColor;
  final String? textSize;
  final String? textWeight;
  final String? textOverride;

  TextViewStyle({
      this.visible,
      this.textColor,
      this.textSize,
      this.textWeight,
      this.textOverride});

  @override
  String toString() {
    return 'TextViewStyle{visible: $visible, textColor: $textColor,'
        'textSize: $textSize, textWeight: $textWeight,'
        'textOverride: $textOverride}';
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'visible': visible,
      'textColor': textColor,
      'textSize': textSize,
      'textWeight': textWeight,
      'textOverride': textOverride
    };
  }

}
