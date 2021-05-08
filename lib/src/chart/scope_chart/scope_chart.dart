import 'package:flutter/widgets.dart';

import 'scope_chart_data.dart';
import 'scope_chart_renderer.dart';

/// Renders a line chart as a widget, using provided [ScopeChartData].
class ScopeChart extends StatefulWidget {
  /// Determines how the [ScopeChart] should be look like.
  final ScopeChartData data;

  /// [data] determines how the [LineChart] should be look like,
  /// when you make any change in the [LineChartData], it updates
  /// new values with animation, and duration is [swapAnimationDuration].
  /// also you can change the [swapAnimationCurve]
  /// which default is [Curves.linear].
  const ScopeChart({Key? key, required this.data}) : super(key: key);

  /// Creates a [_LineChartState]
  @override
  _ScopeChartState createState() => _ScopeChartState();
}

class _ScopeChartState extends State<ScopeChart> {
  @override
  Widget build(BuildContext context) {
    final showingData = _getData();

    /// Wr wrapped our chart with [GestureDetector], and onLongPressStart callback.
    /// because we wanted to lock the widget from being scrolled when user long presses on it.
    /// If we found a solution for solve this issue, then we can remove this undoubtedly.
    return GestureDetector(
      onLongPressStart: (details) {},
      child: ScopeChartLeaf(
        data: widget.data,
        targetData: showingData,
      ),
    );
  }

  ScopeChartData _getData() => widget.data;
}
