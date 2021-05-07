import 'package:equatable/equatable.dart';
import 'package:fl_chart/src/utils/list_wrapper.dart';

import 'scope_chart_data.dart';

/// Contains anything that helps LineChart works
class ScopeChartHelper {
  /// Contains List of cached results, base on [List<LineChartBarData>]
  ///
  /// We use it to prevent redundant calculations
  static final Map<ListWrapper<ScopeChartBarData>, ScopeChartMinMaxAxisValues> _cachedResults = {};

  static ScopeChartMinMaxAxisValues calculateMaxAxisValues(List<ScopeChartBarData> lineBarsData) {
    if (lineBarsData.isEmpty) {
      return ScopeChartMinMaxAxisValues(0, 0, 0, 0);
    }

    var listWrapper = lineBarsData.toWrapperClass();

    if (_cachedResults.containsKey(listWrapper)) {
      return _cachedResults[listWrapper]!.copyWith(readFromCache: true);
    }

    for (var i = 0; i < lineBarsData.length; i++) {
      final lineBarChart = lineBarsData[i];
      if (lineBarChart.spots.isEmpty) {
        throw Exception('spots could not be null or empty');
      }
    }

    var minX = lineBarsData[0].spots[0].x;
    var maxX = lineBarsData[0].spots[0].x;
    var minY = lineBarsData[0].spots[0].y;
    var maxY = lineBarsData[0].spots[0].y;

    for (var i = 0; i < lineBarsData.length; i++) {
      final barData = lineBarsData[i];
      for (var j = 0; j < barData.spots.length; j++) {
        final spot = barData.spots[j];
        if (spot.isNotNull()) {
          if (spot.x > maxX) {
            maxX = spot.x;
          }

          if (spot.x < minX) {
            minX = spot.x;
          }

          if (spot.y > maxY) {
            maxY = spot.y;
          }

          if (spot.y < minY) {
            minY = spot.y;
          }
        }
      }
    }

    final result = ScopeChartMinMaxAxisValues(minX, maxX, minY, maxY);
    _cachedResults[listWrapper] = result;
    return result;
  }
}

/// Holds minX, maxX, minY, and maxY for use in [LineChartData]
class ScopeChartMinMaxAxisValues with EquatableMixin {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final bool readFromCache;

  ScopeChartMinMaxAxisValues(
    this.minX,
    this.maxX,
    this.minY,
    this.maxY, {
    this.readFromCache = false,
  });

  @override
  List<Object?> get props => [minX, maxX, minY, maxY, readFromCache];

  ScopeChartMinMaxAxisValues copyWith(
      {double? minX, double? maxX, double? minY, double? maxY, bool? readFromCache}) {
    return ScopeChartMinMaxAxisValues(
      minX ?? this.minX,
      maxX ?? this.maxX,
      minY ?? this.minY,
      maxY ?? this.maxY,
      readFromCache: readFromCache ?? this.readFromCache,
    );
  }
}
