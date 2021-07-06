import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_data.dart';

import 'scope_axis.dart';
import 'scope_chart_helper.dart';

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
  final ScopeAxisData axis;
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
    this.axis = const ScopeAxisData(),
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
    ScopeAxisData? axis,
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
