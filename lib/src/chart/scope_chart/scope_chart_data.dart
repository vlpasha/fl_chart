import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_data.dart';
import 'package:flutter/material.dart' hide Image;

import 'common/scope_common.dart';

enum ScopePointerEventTarget { chart, zoomarea }
enum ScopeGestureEventType { scroll, scale, horizontalDrag, verticalDrag, tap }

class ScopePointerEvent {
  PointerEvent event;
  ScopePointerEventTarget? target;
  Rect chartRect;
  Rect viewRect;
  Rect? zoomRect;
  ScopePointerEvent({
    required this.event,
    required this.viewRect,
    required this.chartRect,
    this.zoomRect,
    this.target,
  });
}

typedef ScopeGestureCallback = void Function({
  ScopePointerEvent? pointerEvent,
  dynamic details,
});

class ScopePaintHolder {
  final dynamic data;
  final double textScale;
  ScopePaintHolder(this.data, this.textScale);
}

class ScopeChartData with EquatableMixin {
  final Iterable<ScopeChannelData> channelsData;
  final ScopeAxisData timeAxis;
  final ScopeBorderData borderData;
  final ScopeCursorData cursorData;
  final FlClipData clipData;
  final ScopeZoomAreaData? zoomAreaData;

  final Color backgroundColor;
  final ScopeChannelData? activeChannel;
  final bool stopped;
  final double? cursorValue;

  double get minX => timeAxis.min ?? 0;
  double get maxX => timeAxis.max ?? 0;

  ScopeChartData({
    required this.channelsData,
    this.stopped = false,
    this.timeAxis = const ScopeAxisData(min: 0, max: 5000),
    this.activeChannel,
    this.zoomAreaData,
    this.cursorValue,
    ScopeBorderData? borderData,
    ScopeCursorData? cursorData,
    FlClipData? clipData,
    Color? backgroundColor,
  })  : cursorData = cursorData ?? const ScopeCursorData(),
        borderData = borderData ?? ScopeBorderData(),
        backgroundColor = backgroundColor ?? Colors.transparent,
        clipData = clipData ?? FlClipData.none();

  ScopeChartData copyWith({
    Iterable<ScopeChannelData>? channelsData,
    ScopeAxisData? timeAxis,
    ScopeBorderData? borderData,
    double? minX,
    double? maxX,
    FlClipData? clipData,
    Color? backgroundColor,
    ScopeChannelData? activeChannel,
    double? cursorValue,
    ScopeZoomAreaData? zoomAreaData,
  }) =>
      ScopeChartData(
        channelsData: channelsData ?? this.channelsData,
        timeAxis: timeAxis ?? this.timeAxis,
        borderData: borderData ?? this.borderData,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        clipData: clipData ?? this.clipData,
        activeChannel: activeChannel ?? this.activeChannel,
        zoomAreaData: zoomAreaData ?? this.zoomAreaData,
        cursorValue: cursorValue ?? this.cursorValue,
      );

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        timeAxis,
        borderData,
        activeChannel,
        backgroundColor,
        clipData,
        channelsData,
        zoomAreaData,
        cursorValue,
      ];
}
