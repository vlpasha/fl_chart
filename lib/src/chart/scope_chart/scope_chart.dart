import 'package:flutter/widgets.dart';

import 'scope_chart_data.dart';
import 'scope_chart_renderer.dart';

class ScopeChart extends StatelessWidget {
  final ScopeChartData data;
  const ScopeChart({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: RenderScopeChart(
          data,
          MediaQuery.of(context).textScaleFactor,
        ),
      );
}
