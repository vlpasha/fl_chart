import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../fl_chart.dart';
import '../../extensions/canvas_extension.dart';
import '../../extensions/paint_extension.dart';
import '../../utils/canvas_wrapper.dart';
import '../../utils/utils.dart' as utils;
import '../base/axis_chart/axis_chart_data.dart';
import 'scope_chart_data.dart';

class ScopePaintHolder {
  final dynamic data;
  final double textScale;
  ScopePaintHolder(this.data, this.textScale);
}

class ScopeChartLegendPainter {
  late Paint _legendPaint;

  ScopeChartLegendPainter() : super() {
    _legendPaint = Paint()..style = PaintingStyle.stroke;
  }

  void paint(
    CanvasWrapper canvasWrapper, {
    required ScopeLegendData legend,
    required Iterable<ScopeLegendChannel> channels,
    double textScale = 1.0,
  }) {
    if (legend.showLegend != false) {
      var bothY = legend.offset.dy;
      for (var channel in channels) {
        final span = TextSpan(style: legend.textStyle, text: channel.title);
        final tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          textScaleFactor: textScale,
        );
        tp.layout();
        final x1 = legend.offset.dx;
        final x2 = x1 + legend.size;
        var y = bothY;
        _legendPaint.color = channel.color;
        _legendPaint.strokeWidth = legend.width;
        canvasWrapper.save();
        canvasWrapper.drawLine(Offset(x1, y), Offset(x2, y), _legendPaint);
        y = bothY - (tp.height / 2) - (legend.width / 2);
        canvasWrapper.drawText(tp, Offset(x2 + 5, y));
        canvasWrapper.restore();
        bothY += tp.height;
      }
    }
  }
}

class ScopeChartPainter {
  late Paint _borderPaint;
  late Paint _backgroundPaint;
  late Paint _axesPaint;
  late Paint _barPaint;

  ScopeChartPainter() : super() {
    _borderPaint = Paint()..style = PaintingStyle.stroke;
    _backgroundPaint = Paint()..style = PaintingStyle.fill;
    _axesPaint = Paint()..style = PaintingStyle.stroke;
    _barPaint = Paint()..style = PaintingStyle.stroke;
  }

  void paint(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    ScopeChartData data = holder.data;

    // if (data.clipData.any) {
    //   canvasWrapper.saveLayer(
    //     Rect.fromLTWH(
    //       0,
    //       -40,
    //       canvasWrapper.size.width + 40,
    //       canvasWrapper.size.height + 40,
    //     ),
    //     Paint(),
    //   );

    //   _clipToBorder(canvasWrapper, holder);
    // }

    for (final channelData in data.channelsData) {
      if (!channelData.show || channelData.spots.isEmpty) continue;
      _drawChannel(canvasWrapper, data, channelData, holder);
    }

    // if (data.clipData.any) {
    //   canvasWrapper.restore();
    // }

    _drawBackground(canvasWrapper, holder);
    _drawViewBorder(canvasWrapper, holder);
    _drawAxes(canvasWrapper, holder);
  }

  Rect _getClipRect(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    final size = canvasWrapper.size;
    final clip = data.clipData;
    final usableSize = _getChartUsableDrawSize(size, holder);
    final border = data.borderData.showBorder ? data.borderData.border : null;
    final _leftOffset = _getLeftOffsetDrawSize(holder);

    var left = 0.0;
    var top = 0.0;
    var right = size.width;
    var bottom = size.height;

    if (clip.left) {
      final borderWidth = border?.left.width ?? 0;
      left = _leftOffset - (borderWidth / 2);
    }
    if (clip.top) {
      final borderWidth = border?.top.width ?? 0;
      top = -(borderWidth / 2);
    }
    if (clip.right) {
      final borderWidth = border?.right.width ?? 0;
      right = _leftOffset + usableSize.width + (borderWidth / 2);
    }
    if (clip.bottom) {
      final borderWidth = border?.bottom.width ?? 0;
      bottom = usableSize.height + (borderWidth / 2);
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  void _drawZoomArea(
    CanvasWrapper canvasWrapper,
    ScopePaintHolder holder,
  ) {}

  void _drawBackground(
    CanvasWrapper canvasWrapper,
    ScopePaintHolder holder,
  ) {
    ScopeChartData data = holder.data;
    if (data.backgroundColor.opacity == 0.0) {
      return;
    }

    final viewSize = canvasWrapper.size;
    final usableViewSize = _getChartUsableDrawSize(viewSize, holder);
    _backgroundPaint.color = data.backgroundColor;
    canvasWrapper.drawRect(
      Rect.fromLTWH(
        _getLeftOffsetDrawSize(holder),
        0.0,
        usableViewSize.width,
        usableViewSize.height,
      ),
      _backgroundPaint,
    );
  }

  void _drawViewBorder(
    CanvasWrapper canvasWrapper,
    ScopePaintHolder holder,
  ) {
    ScopeChartData data = holder.data;
    var borderData = data.borderData;
    if (borderData.showBorder != true) {
      return;
    }

    final viewSize = canvasWrapper.size;
    final chartViewSize = _getChartUsableDrawSize(viewSize, holder);

    final topLeft = Offset(_getLeftOffsetDrawSize(holder), 0.0);
    final topRight = Offset(
      _getLeftOffsetDrawSize(holder) + chartViewSize.width,
      0.0,
    );
    final bottomLeft = Offset(
      _getLeftOffsetDrawSize(holder),
      chartViewSize.height,
    );
    final bottomRight = Offset(
      _getLeftOffsetDrawSize(holder) + chartViewSize.width,
      chartViewSize.height,
    );

    /// Draw Top Line
    final topBorder = borderData.border.top;
    if (topBorder.width != 0.0) {
      _borderPaint.color = topBorder.color;
      _borderPaint.strokeWidth = topBorder.width;
      _borderPaint.transparentIfWidthIsZero();
      canvasWrapper.drawLine(topLeft, topRight, _borderPaint);
    }

    /// Draw Right Line
    final rightBorder = borderData.border.right;
    if (rightBorder.width != 0.0) {
      _borderPaint.color = rightBorder.color;
      _borderPaint.strokeWidth = rightBorder.width;
      _borderPaint.transparentIfWidthIsZero();
      canvasWrapper.drawLine(topRight, bottomRight, _borderPaint);
    }

    /// Draw Bottom Line
    final bottomBorder = borderData.border.bottom;
    if (bottomBorder.width != 0.0) {
      _borderPaint.color = bottomBorder.color;
      _borderPaint.strokeWidth = bottomBorder.width;
      _borderPaint.transparentIfWidthIsZero();
      canvasWrapper.drawLine(bottomRight, bottomLeft, _borderPaint);
    }

    /// Draw Left Line
    final leftBorder = borderData.border.left;
    if (leftBorder.width != 0.0) {
      _borderPaint.color = leftBorder.color;
      _borderPaint.strokeWidth = leftBorder.width;
      _borderPaint.transparentIfWidthIsZero();
      canvasWrapper.drawLine(bottomLeft, topLeft, _borderPaint);
    }
  }

  void _drawAxes(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    final viewSize = _getChartUsableDrawSize(canvasWrapper.size, holder);

    // Vertical Axis
    // title
    if (data.activeChannel != null) {
      var channel = data.activeChannel!;
      var verticalAxis = channel.axis;
      if (verticalAxis.showAxis != false && channel.spots.isNotEmpty) {
        // draw axis title
        if (verticalAxis.title.showTitle) {
          final title = verticalAxis.title;
          final span = TextSpan(
            style: title.colorize
                ? title.textStyle.copyWith(color: channel.color)
                : title.textStyle,
            text: title.titleText,
          );
          final tp = TextPainter(
            text: span,
            textAlign: title.textAlign,
            textDirection: title.textDirection,
            textScaleFactor: holder.textScale,
          );
          tp.layout(minWidth: viewSize.height);
          canvasWrapper.save();
          canvasWrapper.rotate(-math.pi * 0.5);
          canvasWrapper.drawText(
            tp,
            Offset(-viewSize.height, title.reservedSize - tp.height),
          );
          canvasWrapper.restore();
        }
        // draw axis grid and titles
        final verticalDiff = channel.maxY - channel.minY;
        final titles = verticalAxis.titles;
        final grid = verticalAxis.grid;
        final efficientInterval = utils.getEfficientInterval(
          viewSize.height,
          verticalDiff,
        );
        var interval = (verticalAxis.interval != null) &&
                (verticalAxis.interval! > efficientInterval)
            ? verticalAxis.interval!
            : efficientInterval;

        var verticalSeek = channel.minY;

        final count = verticalDiff ~/ interval;
        final lastPosition = count * verticalSeek;
        final lastPositionOverlapsWithBorder = lastPosition == channel.maxY;
        final end = lastPositionOverlapsWithBorder
            ? (channel.maxY - interval)
            : channel.maxY;
        double? lastTitleY;

        while (verticalSeek <= end) {
          if (grid.showGrid != false) {
            final flLine = grid.getDrawingLine(verticalSeek);
            _axesPaint.color = flLine.color;
            _axesPaint.strokeWidth = flLine.strokeWidth;
            _axesPaint.transparentIfWidthIsZero();

            final bothY = _getPixelY(
              verticalSeek,
              channel.minY,
              channel.maxY,
              viewSize,
              holder,
            );
            final x1 = 0 + _getLeftOffsetDrawSize(holder);
            final y1 = bothY;
            final x2 = viewSize.width + _getLeftOffsetDrawSize(holder);
            final y2 = bothY;
            canvasWrapper.drawDashedLine(
                Offset(x1, y1), Offset(x2, y2), _axesPaint, flLine.dashArray);
          }
          if (titles.showTitles != false) {
            final span = TextSpan(
                style: titles.colorize
                    ? titles.textStyle.copyWith(color: channel.color)
                    : titles.textStyle,
                text: titles.getTitles(verticalSeek));
            final tp = TextPainter(
              text: span,
              textAlign: TextAlign.center,
              textDirection: titles.textDirection,
              textScaleFactor: holder.textScale,
            );
            tp.layout();
            var x = 0 + _getLeftOffsetDrawSize(holder);
            var y = _getPixelY(
              verticalSeek,
              channel.minY,
              channel.maxY,
              viewSize,
              holder,
            );
            x -= tp.width + titles.margin;
            y -= tp.height / 2;
            final showTitle = _checkToShowTitle(
              channel.minY,
              channel.maxY,
              titles,
              interval,
              verticalSeek,
            );
            final skipTitle = lastTitleY != null && lastTitleY - tp.height <= y;
            if (showTitle != false && skipTitle != true) {
              lastTitleY = y;
              canvasWrapper.save();
              canvasWrapper.translate(x + tp.width / 2, y + tp.height / 2);
              canvasWrapper.rotate(utils.radians(titles.rotateAngle));
              canvasWrapper.translate(
                  -(x + tp.width / 2), -(y + tp.height / 2));
              y -= utils.translateRotatedPosition(tp.width, titles.rotateAngle);
              canvasWrapper.drawText(tp, Offset(x, y));
              canvasWrapper.restore();
            }
            verticalSeek += interval;
          }
        }
      }
    }

    final horizontalAxis = data.timeAxis;
    if (horizontalAxis.showAxis != false) {
      // draw axis title
      if (horizontalAxis.title.showTitle) {
        final title = horizontalAxis.title;
        final span = TextSpan(style: title.textStyle, text: title.titleText);
        final tp = TextPainter(
          text: span,
          textAlign: title.textAlign,
          textDirection: title.textDirection,
          textScaleFactor: holder.textScale,
        );
        tp.layout(minWidth: viewSize.width);
        canvasWrapper.drawText(
            tp,
            Offset(_getLeftOffsetDrawSize(holder),
                _getExtraNeededVerticalSpace(holder) + viewSize.height));
      }
      // draw grid and titles
      final titles = horizontalAxis.titles;
      final grid = horizontalAxis.grid;
      final min = horizontalAxis.min ?? 0;
      final max = horizontalAxis.max ?? 0;
      final horizontalDiff = max - min;
      final efficientInterval = utils.getEfficientInterval(
        viewSize.width,
        horizontalDiff,
      );
      var interval = horizontalAxis.interval != null &&
              horizontalAxis.interval! > efficientInterval
          ? horizontalAxis.interval!
          : efficientInterval;
      final delta = max - min;
      final count = delta ~/ interval;
      final lastPosition = count * interval;
      final lastPositionOverlapsWithBorder = lastPosition == max;
      final end = lastPositionOverlapsWithBorder ? max - interval : max;
      var horizontalSeek = min + (interval - (min % interval));
      var lastTitleX = 0.0;

      while (horizontalSeek <= end) {
        if (grid.showGrid) {
          final flLineStyle = grid.getDrawingLine(horizontalSeek);
          _axesPaint.color = flLineStyle.color;
          _axesPaint.strokeWidth = flLineStyle.strokeWidth;
          _axesPaint.transparentIfWidthIsZero();

          final bothX = _getPixelX(
            horizontalSeek,
            min,
            max,
            viewSize,
            holder,
          ).roundToDouble();
          final x1 = bothX;
          final y1 = 0.0;
          final x2 = bothX;
          final y2 = viewSize.height;
          canvasWrapper.drawDashedLine(
            Offset(x1, y1),
            Offset(x2, y2),
            _axesPaint,
            flLineStyle.dashArray,
          );
        }
        if (titles.showTitles) {
          final span = TextSpan(
              style: titles.textStyle, text: titles.getTitles(horizontalSeek));
          final tp = TextPainter(
            text: span,
            textAlign: TextAlign.center,
            textDirection: titles.textDirection,
            textScaleFactor: holder.textScale,
          );
          tp.layout();
          var x = _getPixelX(horizontalSeek, min, max, viewSize, holder);
          var y = viewSize.height;
          x -= tp.width / 2;
          y += titles.margin;
          final showTitle = _checkToShowTitle(
            min,
            max,
            titles,
            interval,
            horizontalSeek,
          );
          final skipTitle = lastTitleX + tp.width > x || x > viewSize.width;
          if (showTitle != false && skipTitle != true) {
            lastTitleX = x;
            canvasWrapper.save();
            canvasWrapper.translate(x + tp.width / 2, y + tp.height / 2);
            canvasWrapper.rotate(utils.radians(titles.rotateAngle));
            canvasWrapper.translate(-(x + tp.width / 2), -(y + tp.height / 2));
            x += utils.translateRotatedPosition(tp.width, titles.rotateAngle);
            canvasWrapper.drawText(tp, Offset(x, y));
            canvasWrapper.restore();
          }
        }
        horizontalSeek += interval;
      }
    }
  }

  void _drawChannel(
    CanvasWrapper canvasWrapper,
    ScopeChartData chartData,
    ScopeChannelData channelData,
    ScopePaintHolder holder,
  ) {
    // final path = _generatePath(viewSize, chartData, channelData, holder);
    final path =
        _generateStepPath(canvasWrapper, chartData, channelData, holder);
    _drawPath(canvasWrapper, path, channelData, holder);
  }

  Path _generateStepPath(
    CanvasWrapper canvasWrapper,
    ScopeChartData scopeData,
    ScopeChannelData channelData,
    ScopePaintHolder holder, {
    Path? appendToPath,
  }) {
    final clipRect = _getClipRect(canvasWrapper, holder);
    final path = appendToPath ?? Path();
    final spots = channelData.spots;

    var start = _clipXY(
        clipRect,
        _getPixelX(
          spots.first.x,
          scopeData.minX,
          scopeData.maxX,
          clipRect.size,
          holder,
        ),
        _getPixelY(
          spots.first.y,
          channelData.minY,
          channelData.maxY,
          clipRect.size,
          holder,
        ));

    if (appendToPath == null) {
      path.moveTo(start.dx, start.dy);
    } else {
      path.lineTo(start.dx, start.dy);
    }

    final iterator = spots.iterator;
    var curSpot = iterator.moveNext() ? iterator.current : null;
    var nextSpot = iterator.moveNext() ? iterator.current : curSpot;
    while (curSpot != null && nextSpot != null) {
      /// CurrentSpot
      final current = _clipXY(
        clipRect,
        _getPixelX(
          curSpot.x,
          scopeData.minX,
          scopeData.maxX,
          clipRect.size,
          holder,
        ),
        _getPixelY(
          curSpot.y,
          channelData.minY,
          channelData.maxY,
          clipRect.size,
          holder,
        ),
      );

      final next = _clipXY(
        clipRect,
        _getPixelX(
          nextSpot.x,
          scopeData.minX,
          scopeData.maxX,
          clipRect.size,
          holder,
        ),
        _getPixelY(
          nextSpot.y,
          channelData.minY,
          channelData.maxY,
          clipRect.size,
          holder,
        ),
      );

      if (current.dy == next.dy) {
        path.lineTo(next.dx, next.dy);
      } else {
        path.lineTo(next.dx, current.dy);
        path.lineTo(next.dx, next.dy);
      }

      curSpot = nextSpot;
      nextSpot = iterator.moveNext() ? iterator.current : null;
    }

    return path;
  }

  Path _generatePath(
    Size viewSize,
    ScopeChartData scopeData,
    ScopeChannelData channelData,
    ScopePaintHolder holder, {
    Path? appendToPath,
  }) {
    viewSize = _getChartUsableDrawSize(viewSize, holder);
    final path = appendToPath ?? Path();
    final spots = channelData.spots;

    var x = _getPixelX(
      spots.first.x,
      scopeData.minX,
      scopeData.maxX,
      viewSize,
      holder,
    );
    var y = _getPixelY(
      spots.first.y,
      channelData.minY,
      channelData.maxY,
      viewSize,
      holder,
    );

    if (appendToPath == null) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }

    final iterator = spots.iterator;
    while (iterator.moveNext()) {
      final curSpot = iterator.current;

      /// CurrentSpot
      final current = Offset(
        _getPixelX(
          curSpot.x,
          scopeData.minX,
          scopeData.maxX,
          viewSize,
          holder,
        ),
        _getPixelY(
          curSpot.y,
          channelData.minY,
          channelData.maxY,
          viewSize,
          holder,
        ),
      );

      path.lineTo(
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  /// draw the main bar line by the [barPath]
  void _drawPath(
    CanvasWrapper canvasWrapper,
    Path barPath,
    ScopeChannelData barData,
    ScopePaintHolder holder,
  ) {
    if (!barData.show) {
      return;
    }
    _barPaint.strokeCap = StrokeCap.butt;
    _barPaint.color = barData.color;
    _barPaint.shader = null;
    _barPaint.maskFilter = null;
    _barPaint.strokeWidth = barData.width;
    _barPaint.transparentIfWidthIsZero();
    canvasWrapper.drawPath(barPath, _barPaint);
  }

  Size _getChartUsableDrawSize(Size viewSize, ScopePaintHolder holder) {
    final usableWidth = viewSize.width - _getExtraNeededHorizontalSpace(holder);
    final usableHeight = viewSize.height - _getExtraNeededVerticalSpace(holder);
    return Size(usableWidth, usableHeight);
  }

  double _getExtraNeededHorizontalSpace(ScopePaintHolder holder) {
    final data = holder.data;
    var sum = 0.0;

    if (data.activeChannel != null) {
      final verticalAxis = data.activeChannel!.axis;
      if (verticalAxis.showAxis) {
        final title = verticalAxis.title;
        if (title.showTitle) {
          sum += title.reservedSize + title.margin;
        }

        final titles = verticalAxis.titles;
        if (titles.showTitles) {
          sum += titles.reservedSize + titles.margin;
        }
      }
    }
    return sum;
  }

  double _getExtraNeededVerticalSpace(ScopePaintHolder holder) {
    final data = holder.data;
    var sum = 0.0;
    final horizontalAxis = data.timeAxis;

    if (horizontalAxis.showAxis != false) {
      final title = horizontalAxis.title;
      if (title.showTitle != false) {
        sum += title.reservedSize + title.margin;
      }

      final titles = horizontalAxis.titles;
      if (titles.showTitles != false) {
        sum += titles.reservedSize + titles.margin;
      }
    }
    return sum;
  }

  double _getLeftOffsetDrawSize(ScopePaintHolder holder) {
    final data = holder.data;
    var sum = 0.0;

    if (data.activeChannel != null) {
      final axis = data.activeChannel!.axis;
      if (axis.showAxis != false) {
        final title = axis.title;
        if (title.showTitle != false) {
          sum += title.reservedSize + title.margin;
        }

        final titles = axis.titles;
        if (titles.showTitles != false) {
          sum += titles.reservedSize + titles.margin;
        }
      }
    }

    return sum;
  }

  double _getPixelX(
    double spotX,
    double minX,
    double maxX,
    Size chartUsableSize,
    ScopePaintHolder holder,
  ) {
    final deltaX = maxX - minX;
    final leftOffset = _getLeftOffsetDrawSize(holder);
    if (deltaX == 0.0) {
      return leftOffset.roundToDouble();
    }
    final x = (((spotX - minX) / deltaX) * chartUsableSize.width) + leftOffset;
    return x.roundToDouble();
  }

  /// With this function we can convert our [FlSpot] y
  /// to the view base axis y.
  double _getPixelY(
    double spotY,
    double minY,
    double maxY,
    Size chartUsableSize,
    ScopePaintHolder holder,
  ) {
    final deltaY = maxY - minY;
    if (deltaY == 0.0) {
      return chartUsableSize.height.roundToDouble();
    }

    var y = ((spotY - minY) / deltaY) * chartUsableSize.height;
    y = chartUsableSize.height - y;
    return y.roundToDouble();
  }

  bool _checkToShowTitle(
    double minValue,
    double maxValue,
    ScopeAxisTitles titles,
    double appliedInterval,
    double value,
  ) {
    if ((maxValue - minValue) % appliedInterval == 0) {
      return true;
    }
    return value > minValue && value < maxValue;
  }

  Offset _clipXY(Rect clipRect, double x, double y) {
    if (x < clipRect.left) {
      x = clipRect.left;
    } else if (x > clipRect.right) {
      x = clipRect.right;
    }

    if (y < clipRect.top) {
      y = clipRect.top;
    } else if (y > clipRect.bottom) {
      y = clipRect.bottom;
    }
    return Offset(x, y);
  }
}
