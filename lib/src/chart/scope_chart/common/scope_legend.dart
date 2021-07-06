import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'scope_channel.dart';

class ScopeLegendChannel with EquatableMixin {
  final String title;
  final Color color;
  ScopeLegendChannel({
    required this.title,
    required this.color,
  });

  factory ScopeLegendChannel.fromChannel(ScopeChannelData channel) =>
      ScopeLegendChannel(
          color: channel.color, title: channel.axis.title.titleText);

  @override
  List<Object?> get props => [
        title,
        color,
      ];
}

class ScopeLegendData with EquatableMixin {
  final bool showLegend;
  final double width;
  final Offset offset;
  final double size;
  final TextStyle textStyle;

  ScopeLegendData({
    this.showLegend = true,
    this.width = 2.0,
    this.offset = const Offset(10.0, 10.0),
    this.size = 20.0,
    TextStyle? textStyle,
  }) : textStyle = textStyle ??
            const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 11,
            );

  ScopeLegendData copyWith({
    bool? showLegend,
    TextStyle? textStyle,
  }) =>
      ScopeLegendData(
        showLegend: showLegend ?? this.showLegend,
        textStyle: textStyle ?? this.textStyle,
      );

  TextPainter getTextPainter(
    String text,
    double textScale,
  ) {
    final span = TextSpan(style: textStyle, text: text);
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      textScaleFactor: textScale,
    );
    tp.layout();
    return tp;
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        showLegend,
        width,
        offset,
        size,
        textStyle,
      ];
}
