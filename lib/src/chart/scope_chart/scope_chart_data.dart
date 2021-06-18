import 'dart:collection';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;

import 'scope_chart_helper.dart';

class ScopeBorderData with EquatableMixin {
  final bool showBorder;
  Border border;

  ScopeBorderData({
    this.showBorder = true,
    Border? border,
  }) : border = border ??
            Border.all(
              color: Colors.black,
              width: 1.0,
              style: BorderStyle.solid,
            );

  @override
  List<Object?> get props => [showBorder, border];

  ScopeBorderData copyWith(bool? showBorder, Border? border) => ScopeBorderData(
        showBorder: showBorder ?? this.showBorder,
        border: border ?? this.border,
      );
}

class ScopeAxisTitle with EquatableMixin {
  final bool showTitle;
  final bool colorize;
  final String titleText;
  final double reservedSize;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final double margin;

  const ScopeAxisTitle({
    this.showTitle = false,
    this.colorize = false,
    this.titleText = '',
    this.reservedSize = 14,
    TextStyle? textStyle,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.center,
    this.margin = 4,
  }) : textStyle = textStyle ??
            const TextStyle(
              color: Colors.black,
              fontSize: 11,
            );

  ScopeAxisTitle copyWith({
    bool? showTitle,
    String? titleText,
    double? reservedSize,
    TextStyle? textStyle,
    TextDirection? textDirection,
    TextAlign? textAlign,
    double? margin,
  }) =>
      ScopeAxisTitle(
        showTitle: showTitle ?? this.showTitle,
        titleText: titleText ?? this.titleText,
        reservedSize: reservedSize ?? this.reservedSize,
        textStyle: textStyle ?? this.textStyle,
        textDirection: textDirection ?? this.textDirection,
        textAlign: textAlign ?? this.textAlign,
        margin: margin ?? this.margin,
      );

  TextPainter getTextPainter(
    double textScale,
    double? minWidth,
  ) {
    final span = TextSpan(style: textStyle, text: titleText);
    final tp = TextPainter(
      text: span,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScale,
    );
    tp.layout(minWidth: minWidth ?? 0.0);
    return tp;
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        showTitle,
        titleText,
        reservedSize,
        textStyle,
        textAlign,
        margin,
      ];
}

class ScopeAxisTitles with EquatableMixin {
  final bool showTitles;
  final bool colorize;
  final GetTitleFunction getTitles;
  final double reservedSize;
  final TextStyle textStyle;
  final TextDirection textDirection;
  final double margin;
  final double rotateAngle;

  const ScopeAxisTitles({
    this.showTitles = true,
    this.colorize = false,
    this.getTitles = defaultGetTitle,
    this.reservedSize = 22,
    TextStyle? textStyle,
    this.textDirection = TextDirection.ltr,
    this.margin = 6,
    this.rotateAngle = 0.0,
  }) : textStyle = textStyle ??
            const TextStyle(
              color: Colors.black,
              fontSize: 11,
            );

  ScopeAxisTitles copyWith({
    bool? showTitles,
    GetTitleFunction? getTitles,
    double? reservedSize,
    TextStyle? textStyle,
    TextDirection? textDirection,
    double? margin,
    double? rotateAngle,
  }) =>
      ScopeAxisTitles(
        showTitles: showTitles ?? this.showTitles,
        getTitles: getTitles ?? this.getTitles,
        reservedSize: reservedSize ?? this.reservedSize,
        textStyle: textStyle ?? this.textStyle,
        textDirection: textDirection ?? this.textDirection,
        margin: margin ?? this.margin,
        rotateAngle: rotateAngle ?? this.rotateAngle,
      );

  TextPainter getTextPainter(double value, double textScale) {
    final span = TextSpan(style: textStyle, text: getTitles(value));
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: textDirection,
      textScaleFactor: textScale,
    );
    tp.layout();
    return tp;
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        showTitles,
        getTitles,
        reservedSize,
        textStyle,
        margin,
        rotateAngle,
      ];
}

class ScopeGrid with EquatableMixin {
  final bool showGrid;
  final GetDrawingGridLine getDrawingLine;
  final CheckToShowGrid checkToShowLine;

  const ScopeGrid({
    this.showGrid = true,
    this.getDrawingLine = defaultGridLine,
    this.checkToShowLine = showAllGrids,
  });

  ScopeGrid copyWith({
    bool? showGrid,
    GetDrawingGridLine? getDrawingLine,
    CheckToShowGrid? checkToShowLine,
  }) =>
      ScopeGrid(
        showGrid: showGrid ?? this.showGrid,
        getDrawingLine: getDrawingLine ?? this.getDrawingLine,
        checkToShowLine: checkToShowLine ?? this.checkToShowLine,
      );

  @override
  List<Object?> get props => [
        showGrid,
        getDrawingLine,
        checkToShowLine,
      ];
}

class ScopeAxis {
  final bool showAxis;
  final double width;
  final ScopeAxisTitle title;
  final ScopeAxisTitles titles;
  final ScopeGrid grid;
  final double? interval;
  final double? min;
  final double? max;

  const ScopeAxis({
    this.showAxis = true,
    this.width = 2.0,
    this.titles = const ScopeAxisTitles(reservedSize: 16),
    this.grid = const ScopeGrid(),
    this.title = const ScopeAxisTitle(),
    this.interval,
    this.min,
    this.max,
  });

  ScopeAxis copyWith({
    bool? showAxis,
    ScopeAxisTitles? titles,
    ScopeGrid? grid,
    ScopeAxisTitle? title,
    double? interval,
    double? min,
    double? max,
  }) =>
      ScopeAxis(
        showAxis: showAxis ?? this.showAxis,
        titles: this.titles.copyWith(
              showTitles: titles?.showTitles,
              textStyle: titles?.textStyle,
              getTitles: titles?.getTitles,
              margin: titles?.margin,
              reservedSize: titles?.reservedSize,
              rotateAngle: titles?.rotateAngle,
              textDirection: titles?.textDirection,
            ),
        grid: this.grid.copyWith(
              showGrid: grid?.showGrid,
              checkToShowLine: grid?.checkToShowLine,
              getDrawingLine: grid?.getDrawingLine,
            ),
        title: this.title.copyWith(
            showTitle: title?.showTitle,
            titleText: title?.titleText,
            reservedSize: title?.reservedSize,
            textStyle: title?.textStyle,
            textDirection: title?.textDirection,
            textAlign: title?.textAlign,
            margin: title?.margin),
        interval: interval ?? this.interval,
        min: min ?? this.min,
        max: max ?? this.max,
      );
}

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

class ScopeZoomArea with EquatableMixin {
  final bool show;
  final double min;
  final double max;
  final double zoomStart;
  final double zoomEnd;
  final Color backgroundColor;
  final Color areaColor;
  final double height;

  ScopeZoomArea({
    this.show = false,
    required this.min,
    required this.max,
    double? zoomStart,
    double? zoomEnd,
    this.backgroundColor = Colors.transparent,
    this.areaColor = Colors.lightBlue,
    this.height = 40.0,
  })  : zoomStart = zoomStart ?? min,
        zoomEnd = zoomEnd ?? max;

  @override
  List<Object?> get props => [
        min,
        max,
        zoomStart,
        zoomEnd,
        backgroundColor,
        areaColor,
        height,
      ];
}

class ScopeChartData with EquatableMixin {
  final Iterable<ScopeChannelData> channelsData;
  final ScopeAxis timeAxis;
  final ScopeBorderData borderData;
  final FlClipData clipData;
  final Color backgroundColor;
  final ScopeChannelData? activeChannel;
  final bool stopped;
  final ScopeZoomArea? zoomArea;

  double get minX => timeAxis.min ?? 0;
  double get maxX => timeAxis.max ?? 0;

  ScopeChartData({
    required this.channelsData,
    this.stopped = false,
    this.timeAxis = const ScopeAxis(min: 0, max: 5000),
    this.activeChannel,
    this.zoomArea,
    ScopeBorderData? borderData,
    FlClipData? clipData,
    Color? backgroundColor,
  })  : borderData = borderData ?? ScopeBorderData(),
        backgroundColor = backgroundColor ?? Colors.transparent,
        clipData = clipData ?? FlClipData.none();

  ScopeChartData copyWith({
    Iterable<ScopeChannelData>? channels,
    ScopeAxis? timeAxis,
    ScopeBorderData? borderData,
    double? minX,
    double? maxX,
    FlClipData? clipData,
    Color? backgroundColor,
    ScopeChannelData? activeChannel,
  }) =>
      ScopeChartData(
        channelsData: channels ?? this.channelsData,
        timeAxis: timeAxis ?? this.timeAxis,
        borderData: borderData ?? this.borderData,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        clipData: clipData ?? this.clipData,
        activeChannel: activeChannel ?? this.activeChannel,
      );

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        timeAxis,
        borderData,
        activeChannel,
        backgroundColor,
      ];
}

/// Holds data for drawing each individual line in the [ScopeChart]
class ScopeChannelData with EquatableMixin {
  final String id;
  final bool show;
  final Color color;
  final double width;
  final bool isCurved;
  final double curveSmoothness;
  final bool preventCurveOverShooting;
  final double preventCurveOvershootingThreshold;
  final Shadow shadow;
  final ScopeAxis axis;
  final ListQueue<FlSpot> _spots;

  ListQueue<FlSpot> get spots => _spots;
  late ScopeChartMinMaxAxisValues _dynamicLimits;
  double get minY => axis.min ?? _dynamicLimits.minY;
  double get maxY => axis.max ?? _dynamicLimits.maxY;

  ScopeChannelData({
    required this.id,
    this.show = true,
    this.color = Colors.redAccent,
    this.width = 2.0,
    this.isCurved = false,
    this.curveSmoothness = 0.35,
    this.preventCurveOverShooting = false,
    this.preventCurveOvershootingThreshold = 10.0,
    this.shadow = const Shadow(color: Colors.transparent),
    this.axis = const ScopeAxis(),
    ListQueue<FlSpot>? spots,
  }) : _spots = spots ?? ListQueue() {
    calculateMaxAxisValues();
  }

  void calculateMaxAxisValues() =>
      _dynamicLimits = ScopeChartHelper.calculateMaxAxisValues(this);

  /// Copies current [LineChartBarData] to a new [LineChartBarData],
  /// and replaces provided values.
  ScopeChannelData copyWith({
    String? id,
    ListQueue<FlSpot>? spots,
    bool? show,
    Color? color,
    double? width,
    bool? isCurved,
    double? curveSmoothness,
    bool? preventCurveOverShooting,
    double? preventCurveOvershootingThreshold,
    Shadow? shadow,
    ScopeAxis? axis,
  }) {
    return ScopeChannelData(
      id: id ?? this.id,
      spots: spots ?? this.spots,
      show: show ?? this.show,
      width: width ?? this.width,
      isCurved: isCurved ?? this.isCurved,
      curveSmoothness: curveSmoothness ?? this.curveSmoothness,
      preventCurveOverShooting:
          preventCurveOverShooting ?? this.preventCurveOverShooting,
      preventCurveOvershootingThreshold: preventCurveOvershootingThreshold ??
          this.preventCurveOvershootingThreshold,
      shadow: shadow ?? this.shadow,
      axis: axis ?? this.axis,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        spots,
        show,
        color,
        width,
        isCurved,
        curveSmoothness,
        preventCurveOverShooting,
        preventCurveOvershootingThreshold,
        shadow,
        axis,
      ];
}
