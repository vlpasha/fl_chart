import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_data.dart';
import 'package:flutter/material.dart' hide Image;

import 'scope_chart_helper.dart';

/// [ScopeChart] needs this class to render itself.
///
/// It holds data needed to draw a line chart,
/// including bar lines, spots, colors, touches, ...
class ScopeChartData extends AxisChartData with EquatableMixin {
  /// [ScopeChart] draws some lines in various shapes and overlaps them.
  final List<ScopeChartBarData> lineBarsData;

  /// Titles on left, top, right, bottom axis for each number.
  final FlTitlesData titlesData;

  /// [ScopeChart] draws some lines in various shapes and overlaps them.
  /// lines are defined in [lineBarsData]
  ///
  /// It draws some titles on left, top, right, bottom sides per each axis number,
  /// you can modify [titlesData] to have your custom titles,
  /// also you can define the axis title (one text per axis) for each side
  /// using [axisTitleData], you can restrict the y axis using [minY] and [maxY] value,
  /// and restrict x axis using [minX] and [maxX].
  ///
  /// It draws a color as a background behind everything you can set it using [backgroundColor],
  /// then a grid over it, you can customize it using [gridData],
  /// and it draws 4 borders around your chart, you can customize it using [borderData].
  ///
  /// [clipData] forces the [LineChart] to draw lines inside the chart bounding box.
  ScopeChartData({
    List<ScopeChartBarData>? lineBarsData,
    FlTitlesData? titlesData,
    FlGridData? gridData,
    FlBorderData? borderData,
    FlAxisTitleData? axisTitleData,
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    FlClipData? clipData,
    Color? backgroundColor,
  })  : lineBarsData = lineBarsData ?? const [],
        titlesData = titlesData ?? FlTitlesData(),
        super(
          gridData: gridData ?? FlGridData(),
          touchData: FlTouchData(false),
          borderData: borderData,
          axisTitleData: axisTitleData ?? FlAxisTitleData(),
          rangeAnnotations: RangeAnnotations(),
          clipData: clipData ?? FlClipData.none(),
          backgroundColor: backgroundColor,
          minX: minX ?? ScopeChartHelper.calculateMaxAxisValues(lineBarsData ?? const []).minX,
          maxX: maxX ?? ScopeChartHelper.calculateMaxAxisValues(lineBarsData ?? const []).maxX,
          minY: minY ?? ScopeChartHelper.calculateMaxAxisValues(lineBarsData ?? const []).minY,
          maxY: maxY ?? ScopeChartHelper.calculateMaxAxisValues(lineBarsData ?? const []).maxY,
        );

  /// Lerps a [BaseChartData] based on [t] value, check [Tween.lerp].
  @override
  ScopeChartData lerp(BaseChartData a, BaseChartData b, double t) {
    if (a is ScopeChartData && b is ScopeChartData) {
      return ScopeChartData(
        minX: lerpDouble(a.minX, b.minX, t),
        maxX: lerpDouble(a.maxX, b.maxX, t),
        minY: lerpDouble(a.minY, b.minY, t),
        maxY: lerpDouble(a.maxY, b.maxY, t),
        backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
        borderData: FlBorderData.lerp(a.borderData, b.borderData, t),
        clipData: b.clipData,
        gridData: FlGridData.lerp(a.gridData, b.gridData, t),
        titlesData: FlTitlesData.lerp(a.titlesData, b.titlesData, t),
        axisTitleData: FlAxisTitleData.lerp(a.axisTitleData, b.axisTitleData, t),
      );
    } else {
      throw Exception('Illegal State');
    }
  }

  /// Copies current [LineChartData] to a new [LineChartData],
  /// and replaces provided values.
  ScopeChartData copyWith({
    List<ScopeChartBarData>? lineBarsData,
    FlTitlesData? titlesData,
    FlAxisTitleData? axisTitleData,
    FlGridData? gridData,
    FlBorderData? borderData,
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    FlClipData? clipData,
    Color? backgroundColor,
  }) {
    return ScopeChartData(
      lineBarsData: lineBarsData ?? this.lineBarsData,
      titlesData: titlesData ?? this.titlesData,
      axisTitleData: axisTitleData ?? this.axisTitleData,
      gridData: gridData ?? this.gridData,
      borderData: borderData ?? this.borderData,
      minX: minX ?? this.minX,
      maxX: maxX ?? this.maxX,
      minY: minY ?? this.minY,
      maxY: maxY ?? this.maxY,
      clipData: clipData ?? this.clipData,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        lineBarsData,
        titlesData,
        gridData,
        borderData,
        axisTitleData,
        rangeAnnotations,
        minX,
        maxX,
        minY,
        maxY,
        clipData,
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
