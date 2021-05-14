import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_data.dart';
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
  List<Object?> get props => [
        showBorder,
        border,
      ];

  ScopeBorderData copyWith(
    bool? showBorder,
    Border? border,
  ) =>
      ScopeBorderData(showBorder: showBorder ?? this.showBorder, border: border ?? this.border);
}

class ScopeAxisTitle with EquatableMixin {
  final bool showTitle;
  final String titleText;
  final double reservedSize;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final double margin;

  ScopeAxisTitle({
    this.showTitle = false,
    String? titleText,
    double? reservedSize,
    TextStyle? textStyle,
    TextDirection? textDirection,
    TextAlign? textAlign,
    double? margin,
  })  : titleText = titleText ?? '',
        reservedSize = reservedSize ?? 14,
        textStyle = textStyle ??
            const TextStyle(
              color: Colors.black,
              fontSize: 11,
            ),
        textDirection = textDirection ?? TextDirection.ltr,
        textAlign = textAlign ?? TextAlign.center,
        margin = margin ?? 4;

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
  final GetTitleFunction getTitles;
  final double reservedSize;
  final GetTitleTextStyleFunction getTextStyles;
  final TextDirection textDirection;
  final double margin;
  final double rotateAngle;

  ScopeAxisTitles({
    this.showTitles = true,
    GetTitleFunction? getTitles,
    double? reservedSize,
    GetTitleTextStyleFunction? getTextStyles,
    TextDirection? textDirection,
    double? margin,
    double? rotateAngle,
  })  : getTitles = getTitles ?? defaultGetTitle,
        reservedSize = reservedSize ?? 22,
        getTextStyles = getTextStyles ?? defaultGetTitleTextStyle,
        textDirection = textDirection ?? TextDirection.ltr,
        margin = margin ?? 6,
        rotateAngle = rotateAngle ?? 0.0;

  ScopeAxisTitles copyWith({
    bool? showTitles,
    GetTitleFunction? getTitles,
    double? reservedSize,
    GetTitleTextStyleFunction? getTextStyles,
    TextDirection? textDirection,
    double? margin,
    double? rotateAngle,
  }) =>
      ScopeAxisTitles(
        showTitles: showTitles ?? this.showTitles,
        getTitles: getTitles ?? this.getTitles,
        reservedSize: reservedSize ?? this.reservedSize,
        getTextStyles: getTextStyles ?? this.getTextStyles,
        textDirection: textDirection ?? this.textDirection,
        margin: margin ?? this.margin,
        rotateAngle: rotateAngle ?? this.rotateAngle,
      );

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        showTitles,
        getTitles,
        reservedSize,
        getTextStyles,
        margin,
        rotateAngle,
      ];
}

class ScopeGrid with EquatableMixin {
  final bool showGrid;
  final GetDrawingGridLine getDrawingLine;
  final CheckToShowGrid checkToShowLine;

  ScopeGrid({
    bool? showGrid,
    GetDrawingGridLine? getDrawingLine,
    CheckToShowGrid? checkToShowLine,
  })  : showGrid = showGrid ?? true,
        getDrawingLine = getDrawingLine ?? defaultGridLine,
        checkToShowLine = checkToShowLine ?? showAllGrids;

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
  double? interval;
  final ScopeAxisTitle title;
  final ScopeAxisTitles titles;
  final ScopeGrid grid;

  ScopeAxis({
    this.showAxis = true,
    ScopeAxisTitles? titles,
    ScopeGrid? grid,
    ScopeAxisTitle? title,
    double? interval,
  })  : titles = titles ?? ScopeAxisTitles(reservedSize: 16),
        grid = grid ?? ScopeGrid(),
        title = title ?? ScopeAxisTitle(),
        interval = interval;

  ScopeAxis copyWith({
    bool? showAxis,
    ScopeAxisTitles? titles,
    ScopeGrid? grid,
    ScopeAxisTitle? title,
    double? interval,
  }) =>
      ScopeAxis(
          showAxis: showAxis ?? this.showAxis,
          titles: this.titles.copyWith(
                showTitles: titles?.showTitles,
                getTextStyles: titles?.getTextStyles,
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
          interval: interval ?? this.interval);
}

class ScopeAxesData {
  final ScopeAxis vertical;
  final ScopeAxis horizontal;

  ScopeAxesData({
    ScopeAxis? vertical,
    ScopeAxis? horizontal,
  })  : vertical = vertical ?? ScopeAxis(),
        horizontal = horizontal ?? ScopeAxis();

  ScopeAxesData copyWith({
    ScopeAxis? vertical,
    ScopeAxis? horizontal,
  }) =>
      ScopeAxesData(
        horizontal: this.horizontal.copyWith(
            showAxis: horizontal?.showAxis,
            interval: horizontal?.interval,
            grid: horizontal?.grid,
            title: horizontal?.title,
            titles: horizontal?.titles),
        vertical: this.vertical.copyWith(
            showAxis: vertical?.showAxis,
            interval: vertical?.interval,
            grid: vertical?.grid,
            title: vertical?.title,
            titles: vertical?.titles),
      );
}

class ScopeChartData with EquatableMixin {
  final List<ScopeChannelData> channelsData;
  final ScopeAxesData axesData;
  final ScopeBorderData borderData;
  final FlClipData clipData;
  final Color backgroundColor;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  double get verticalDiff => maxY - minY;
  double get horizontalDiff => maxX - minX;

  ScopeChartData({
    List<ScopeChannelData>? channelsData,
    ScopeAxesData? axesData,
    ScopeBorderData? borderData,
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    FlClipData? clipData,
    Color? backgroundColor,
  })  : channelsData = channelsData ?? const [],
        axesData = axesData ?? ScopeAxesData(),
        borderData = borderData ?? ScopeBorderData(),
        backgroundColor = backgroundColor ?? Colors.transparent,
        clipData = clipData ?? FlClipData.none(),
        minX = minX ?? ScopeChartHelper.calculateMaxAxisValues(channelsData ?? const []).minX,
        maxX = maxX ?? ScopeChartHelper.calculateMaxAxisValues(channelsData ?? const []).maxX,
        minY = minY ?? ScopeChartHelper.calculateMaxAxisValues(channelsData ?? const []).minY,
        maxY = maxY ?? ScopeChartHelper.calculateMaxAxisValues(channelsData ?? const []).maxY;

  ScopeChartData copyWith({
    List<ScopeChannelData>? channelsData,
    ScopeAxesData? axesData,
    ScopeBorderData? borderData,
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    FlClipData? clipData,
    Color? backgroundColor,
  }) {
    return ScopeChartData(
      channelsData: channelsData ?? this.channelsData,
      axesData: axesData ?? this.axesData,
      borderData: borderData ?? this.borderData,
      minX: minX ?? this.minX,
      maxX: maxX ?? this.maxX,
      minY: minY ?? this.minY,
      maxY: maxY ?? this.maxY,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        channelsData,
        axesData,
        borderData,
        minX,
        maxX,
        minY,
        maxY,
        backgroundColor,
      ];
}

/// Holds data for drawing each individual line in the [ScopeChart]
class ScopeChannelData with EquatableMixin {
  final List<FlSpot> spots;
  final bool show;
  final Color color;
  final double width;
  final bool isCurved;
  final double curveSmoothness;
  final bool preventCurveOverShooting;
  final double preventCurveOvershootingThreshold;
  final Shadow shadow;
  ScopeChannelData({
    List<FlSpot>? spots,
    bool? show,
    Color? color,
    double? barWidth,
    bool? isCurved,
    double? curveSmoothness,
    bool? preventCurveOverShooting,
    double? preventCurveOvershootingThreshold,
    Shadow? shadow,
  })  : spots = spots ?? const [],
        show = show ?? true,
        color = color ?? Colors.redAccent,
        width = barWidth ?? 2.0,
        isCurved = isCurved ?? false,
        curveSmoothness = curveSmoothness ?? 0.35,
        preventCurveOverShooting = preventCurveOverShooting ?? false,
        preventCurveOvershootingThreshold = preventCurveOvershootingThreshold ?? 10.0,
        shadow = shadow ?? const Shadow(color: Colors.transparent);

  /// Copies current [LineChartBarData] to a new [LineChartBarData],
  /// and replaces provided values.
  ScopeChannelData copyWith({
    List<FlSpot>? spots,
    bool? show,
    Color? color,
    double? barWidth,
    bool? isCurved,
    double? curveSmoothness,
    bool? preventCurveOverShooting,
    double? preventCurveOvershootingThreshold,
    Shadow? shadow,
  }) {
    return ScopeChannelData(
      spots: spots ?? this.spots,
      show: show ?? this.show,
      barWidth: barWidth ?? this.width,
      isCurved: isCurved ?? this.isCurved,
      curveSmoothness: curveSmoothness ?? this.curveSmoothness,
      preventCurveOverShooting: preventCurveOverShooting ?? this.preventCurveOverShooting,
      preventCurveOvershootingThreshold:
          preventCurveOvershootingThreshold ?? this.preventCurveOvershootingThreshold,
      shadow: shadow ?? this.shadow,
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
      ];
}

/// Represent a targeted spot inside a line bar.
class ScopeChannelSpot extends FlSpot with EquatableMixin {
  /// Is the [LineChartBarData] that this spot is inside of.
  final ScopeChannelData bar;

  /// Is the index of our [bar], in the [LineChartData.channelsData] list,
  final int barIndex;

  /// Is the index of our [super.spot], in the [LineChartBarData.spots] list.
  final int spotIndex;

  /// [bar] is the [LineChartBarData] that this spot is inside of,
  /// [barIndex] is the index of our [bar], in the [LineChartData.channelsData] list,
  /// [spot] is the targeted spot.
  /// [spotIndex] is the index this [FlSpot], in the [LineChartBarData.spots] list.
  ScopeChannelSpot(
    this.bar,
    this.barIndex,
    FlSpot spot,
  )   : spotIndex = bar.spots.indexOf(spot),
        super(spot.x, spot.y);

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        bar,
        barIndex,
        spotIndex,
        x,
        y,
      ];
}
