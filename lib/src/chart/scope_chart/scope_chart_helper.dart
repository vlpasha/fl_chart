import 'package:equatable/equatable.dart';
import 'package:fl_chart/src/utils/list_wrapper.dart';

import 'scope_chart_data.dart';

/// Contains anything that helps LineChart works
class ScopeChartHelper {
  /// Contains List of cached results, base on [List<LineChartBarData>]
  ///
  /// We use it to prevent redundant calculations
  static final Map<ScopeChannelData, ScopeChartMinMaxAxisValues> _cachedResults = {};

  static ScopeChartMinMaxAxisValues calculateMaxAxisValues(
    ScopeChannelData lineBarsData,
  ) {
    if (lineBarsData.spots.isEmpty) {
      return ScopeChartMinMaxAxisValues(0, 0, 0, 0);
    }

    if (_cachedResults.containsKey(lineBarsData)) {
      return _cachedResults[lineBarsData]!.copyWith(readFromCache: true);
    }

    var minX = lineBarsData.spots[0].x;
    var maxX = lineBarsData.spots[0].x;
    var minY = lineBarsData.spots[0].y;
    var maxY = lineBarsData.spots[0].y;

    final barData = lineBarsData;
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

    if (maxX == minX) {
      maxX += 1;
      minX -= 1;
    }

    if (maxY == minY) {
      maxY += 1;
      minY -= 1;
    }

    final result = ScopeChartMinMaxAxisValues(minX, maxX, minY, maxY);
    _cachedResults[lineBarsData] = result;
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

  ScopeChartMinMaxAxisValues copyWith({
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    bool? readFromCache,
  }) {
    return ScopeChartMinMaxAxisValues(
      minX ?? this.minX,
      maxX ?? this.maxX,
      minY ?? this.minY,
      maxY ?? this.maxY,
      readFromCache: readFromCache ?? this.readFromCache,
    );
  }
}
