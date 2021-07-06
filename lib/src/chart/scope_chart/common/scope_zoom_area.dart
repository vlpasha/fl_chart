import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'scope_cursor.dart';

class ScopeZoomAreaData {
  final bool show;
  final double min;
  final double max;
  final double minZoom;
  final double maxZoom;
  final Color backgroundColor;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double height;
  final double minWidth;
  final ScopeCursorData cursor;

  ScopeZoomAreaData({
    this.show = false,
    required this.min,
    required this.max,
    required this.minZoom,
    required this.maxZoom,
    this.backgroundColor = Colors.transparent,
    this.color = Colors.lightBlue,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.height = 40.0,
    this.minWidth = 5.0,
    this.cursor = const ScopeCursorData(),
  });

  ScopeZoomAreaData copyWith({
    bool? show,
    double? min,
    double? max,
    double? minZoom,
    double? maxZoom,
    Color? backgroundColor,
    Color? color,
    double? height,
    double? minWidth,
    ScopeCursorData? cursor,
  }) =>
      ScopeZoomAreaData(
        show: show ?? this.show,
        min: min ?? this.min,
        max: max ?? this.max,
        minZoom: minZoom ?? this.minZoom,
        maxZoom: maxZoom ?? this.maxZoom,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        color: color ?? this.color,
        height: height ?? this.height,
        minWidth: minWidth ?? this.minWidth,
        cursor: cursor ?? this.cursor,
      );

  @override
  List<Object?> get props => [
        min,
        max,
        minZoom,
        maxZoom,
        backgroundColor,
        color,
        height,
        minWidth,
        cursor,
      ];
}
