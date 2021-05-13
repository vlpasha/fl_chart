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

class ScopeTitles with EquatableMixin {
  final bool showTitles;
  final GetTitleFunction getTitles;
  final double reservedSize;
  final GetTitleTextStyleFunction getTextStyles;
  final TextDirection textDirection;
  final double margin;
  final double rotateAngle;

  ScopeTitles({
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
  final ScopeTitles titles;
  final ScopeGrid grid;
  ScopeAxis({
    this.showAxis = true,
    ScopeTitles? titles,
    ScopeGrid? grid,
    ScopeAxisTitle? title,
    double? interval,
  })  : titles = titles ?? ScopeTitles(reservedSize: 16),
        grid = grid ?? ScopeGrid(),
        title = title ?? ScopeAxisTitle(),
        interval = interval;
}

class ScopeAxesData {
  final ScopeAxis vertical;
  final ScopeAxis horizontal;
  ScopeAxesData({
    ScopeAxis? vertical,
    ScopeAxis? horizontal,
  })  : vertical = vertical ?? ScopeAxis(),
        horizontal = horizontal ?? ScopeAxis();
}

class ScopeChartData with EquatableMixin {
  final List<ScopeChartBarData> lineBarsData;
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
    List<ScopeChartBarData>? lineBarsData,
    ScopeAxesData? axesData,
    ScopeBorderData? borderData,
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    FlClipData? clipData,
    Color? backgroundColor,
  })  : lineBarsData = lineBarsData ?? const [],
        axesData = axesData ?? ScopeAxesData(),
        borderData = borderData ?? ScopeBorderData(),
        backgroundColor = backgroundColor ?? Colors.transparent,
        clipData = clipData ?? FlClipData.none(),
        minX = minX ?? ScopeChartHelper.calculateMaxAxisValues(lineBarsData ?? const []).minX,
        maxX = maxX ?? ScopeChartHelper.calculateMaxAxisValues(lineBarsData ?? const []).maxX,
        minY = minY ?? ScopeChartHelper.calculateMaxAxisValues(lineBarsData ?? const []).minY,
        maxY = maxY ?? ScopeChartHelper.calculateMaxAxisValues(lineBarsData ?? const []).maxY;

  ScopeChartData copyWith({
    List<ScopeChartBarData>? lineBarsData,
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
      lineBarsData: lineBarsData ?? this.lineBarsData,
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
        lineBarsData,
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
class ScopeChartBarData with EquatableMixin {
  /// This line goes through this spots.
  ///
  /// You can have multiple lines by splitting them,
  /// put a [FlSpot.nullSpot] between each section.
  final List<FlSpot> spots;

  /// Determines to show or hide the line.
  final bool show;

  /// determines the color of drawing line, if one color provided it applies a solid color,
  /// otherwise it gradients between provided colors for drawing the line.
  final Color color;

  /// Determines thickness of drawing line.
  final double barWidth;

  /// If it's true, [ScopeChart] draws the line with curved edges,
  /// otherwise it draws line with hard edges.
  final bool isCurved;

  /// If [isCurved] is true, it determines smoothness of the curved edges.
  final double curveSmoothness;

  /// Prevent overshooting when draw curve line with high value changes.
  /// check this [issue](https://github.com/imaNNeoFighT/fl_chart/issues/25)
  final bool preventCurveOverShooting;

  /// Applies threshold for [preventCurveOverShooting] algorithm.
  final double preventCurveOvershootingThreshold;

  /// Drops a shadow behind the bar line.
  final Shadow shadow;

  /// [BarChart] draws some lines and overlaps them in the chart's view,
  /// You can have multiple lines by splitting them,
  /// put a [FlSpot.nullSpot] between each section.
  /// each line passes through [spots], with hard edges by default,
  /// [isCurved] makes it curve for drawing, and [curveSmoothness] determines the curve smoothness.
  ///
  /// [show] determines the drawing, if set to false, it draws nothing.
  ///
  /// [colors] determines the color of drawing line, if one color provided it applies a solid color,
  /// otherwise it gradients between provided colors for drawing the line.
  /// Gradient happens using provided [colorStops], [gradientFrom], [gradientTo].
  /// if you want it draw normally, don't touch them,
  /// check [LinearGradient] for understanding [colorStops]
  ///
  /// [barWidth] determines the thickness of drawing line,
  ///
  /// if [isCurved] is true, in some situations if the spots changes are in high values,
  /// an overshooting will happen, we don't have any idea to solve this at the moment,
  /// but you can set [preventCurveOverShooting] true, and update the threshold
  /// using [preventCurveOvershootingThreshold] to achieve an acceptable curve,
  /// check this [issue](https://github.com/imaNNeoFighT/fl_chart/issues/25)
  /// to overshooting understand the problem.
  ///
  /// [isStrokeCapRound] determines the shape of line's cap.
  ///
  /// [belowBarData], and  [aboveBarData] used to fill the space below or above the drawn line,
  /// you can fill with a solid color or a linear gradient.
  ///
  /// [LineChart] draws points that the line is going through [spots],
  /// you can customize it's appearance using [dotData].
  ///
  /// there are some indicators with a line and bold point on each spot,
  /// you can show them by filling [showingIndicators] with indices
  /// you want to show indicator on them.
  ///
  /// [LineChart] draws the lines with dashed effect if you fill [dashArray].
  ///
  /// If you want to have a Step Line Chart style, just set [isStepLineChart] true,
  /// also you can tweak the [LineChartBarData.lineChartStepData].
  ScopeChartBarData({
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
        barWidth = barWidth ?? 2.0,
        isCurved = isCurved ?? false,
        curveSmoothness = curveSmoothness ?? 0.35,
        preventCurveOverShooting = preventCurveOverShooting ?? false,
        preventCurveOvershootingThreshold = preventCurveOvershootingThreshold ?? 10.0,
        shadow = shadow ?? const Shadow(color: Colors.transparent);

  /// Copies current [LineChartBarData] to a new [LineChartBarData],
  /// and replaces provided values.
  ScopeChartBarData copyWith({
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
    return ScopeChartBarData(
      spots: spots ?? this.spots,
      show: show ?? this.show,
      barWidth: barWidth ?? this.barWidth,
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
        barWidth,
        isCurved,
        curveSmoothness,
        preventCurveOverShooting,
        preventCurveOvershootingThreshold,
        shadow,
      ];
}

/// Represent a targeted spot inside a line bar.
class ScopeBarSpot extends FlSpot with EquatableMixin {
  /// Is the [LineChartBarData] that this spot is inside of.
  final ScopeChartBarData bar;

  /// Is the index of our [bar], in the [LineChartData.lineBarsData] list,
  final int barIndex;

  /// Is the index of our [super.spot], in the [LineChartBarData.spots] list.
  final int spotIndex;

  /// [bar] is the [LineChartBarData] that this spot is inside of,
  /// [barIndex] is the index of our [bar], in the [LineChartData.lineBarsData] list,
  /// [spot] is the targeted spot.
  /// [spotIndex] is the index this [FlSpot], in the [LineChartBarData.spots] list.
  ScopeBarSpot(
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
