import 'package:flutter/material.dart';

enum CursorTitlePosition { bottom, top }

class ScopeCursorData {
  final double width;
  final Color color;
  final bool show;
  final TextStyle textStyle;
  final CursorTitlePosition titlePosition;
  final double reservedSize;
  const ScopeCursorData({
    this.show = false,
    this.width = 2.0,
    this.color = Colors.black,
    TextStyle? textStyle,
    this.reservedSize = 20,
    this.titlePosition = CursorTitlePosition.top,
  }) : textStyle =
            textStyle ?? const TextStyle(color: Colors.black, fontSize: 11);
}
