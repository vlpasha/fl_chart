import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'scope_chart_data.dart';
import 'scope_chart_painter.dart';

class ScopeChartRenderer extends CustomPainter {
  final Animation? listenable;
  final ScopeChartData _data;
  final double _textScale;
  ScopeChartRenderer({
    required ScopeChartData data,
    required double textScale,
    this.listenable,
  })  : _data = data,
        _textScale = textScale,
        super(repaint: listenable);

  final _painter = ScopeChartPainter();

  ScopePaintHolder get paintHolder => ScopePaintHolder(_data, _textScale);

  @override
  bool shouldRepaint(ScopeChartRenderer oldDelegate) =>
      oldDelegate._data != _data;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, 0);
    _painter.paint(CanvasWrapper(canvas, size), paintHolder);
    canvas.restore();
  }
}

class ScopeLegendRenderer extends CustomPainter {
  final ScopeLegendData _data;
  final Iterable<ScopeChannelData> _channels;
  final double _textScale;

  ScopeLegendRenderer({
    required ScopeLegendData data,
    required double textScale,
    required Iterable<ScopeChannelData> channels,
  })  : _data = data,
        _textScale = textScale,
        _channels = channels,
        super();

  final _painter = ScopeChartLegendPainter();

  @override
  bool shouldRepaint(ScopeLegendRenderer oldDelegate) =>
      oldDelegate._data != _data;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, 0);
    _painter.paint(
      CanvasWrapper(canvas, size),
      legend: _data,
      channels: _channels
          .where((e) => e.show)
          .map((e) => ScopeLegendChannel.fromChannel(e)),
      textScale: _textScale,
    );
    canvas.restore();
  }
}
