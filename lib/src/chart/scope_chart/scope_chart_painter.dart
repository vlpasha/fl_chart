import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../fl_chart.dart';
import '../../extensions/canvas_extension.dart';
import '../../extensions/paint_extension.dart';
import '../../utils/canvas_wrapper.dart';
import '../../utils/utils.dart' as utils;

import 'common/scope_axis.dart';
import 'common/scope_channel.dart';
import 'scope_chart_data.dart';
import 'common/scope_legend.dart';

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

class ScopeChartDmensions {
  late Rect canvasRect;
  late Rect chartRect;
  Rect? zoomRect;
  Rect? verticalAxisRect;
  Rect? horizontalAxisRect;
  Rect? clipRect;

  ScopeChartDmensions(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    canvasRect = Rect.fromLTWH(
        0, 0, canvasWrapper.size.width, canvasWrapper.size.height);
    chartRect = _getChartRect(holder);
    clipRect = _getClipRect(holder);
    zoomRect = _getZoomAreRect(holder);
  }

  double _getExtraNeededVerticalSpace(ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    var sum = 0.0;
    final horizontalAxis = data.timeAxis;
    final zoomArea = data.zoomAreaData;
    final cursor = data.cursorData;

    if (cursor.show && cursor.titlePosition == CursorTitlePosition.top) {
      sum += cursor.reservedSize;
    }

    if (zoomArea != null && zoomArea.show) {
      sum += zoomArea.height;
    }

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

  double _getExtraNeededLeftSpace(ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
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

  double _getExtraNeededTopSpace(ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    var sum = 0.0;
    final cursor = data.cursorData;

    if (cursor.show && cursor.titlePosition == CursorTitlePosition.top) {
      sum += cursor.reservedSize;
    }

    return sum;
  }

  Size _getChartUsableDrawSize(Size viewSize, ScopePaintHolder holder) {
    final usableWidth = viewSize.width - _getExtraNeededLeftSpace(holder);
    final usableHeight = viewSize.height - _getExtraNeededVerticalSpace(holder);
    return Size(usableWidth, usableHeight);
  }

  Rect _getChartRect(ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    final size = canvasRect.size;
    final usableSize = _getChartUsableDrawSize(size, holder);
    final leftOffset = _getExtraNeededLeftSpace(holder);
    final topOffset = _getExtraNeededTopSpace(holder);
    final border = data.borderData.showBorder ? data.borderData.border : null;
    var left = leftOffset - (border?.left.width ?? 0) / 2;
    var top = topOffset - (border?.top.width ?? 0) / 2;
    var right = left + usableSize.width + (border?.right.width ?? 0) / 2;
    var bottom = usableSize.height + (border?.bottom.width ?? 0) / 2;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _getClipRect(ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    final clip = data.clipData;

    var left = canvasRect.left;
    var top = canvasRect.right;
    var right = canvasRect.right;
    var bottom = canvasRect.bottom;

    if (clip.left) {
      left = chartRect.left;
    }
    if (clip.top) {
      top = chartRect.top;
    }
    if (clip.right) {
      right = chartRect.right;
    }
    if (clip.bottom) {
      bottom = chartRect.bottom;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect? _getZoomAreRect(ScopePaintHolder holder) {
    final ScopeChartData data = holder.data;
    final zoomArea = data.zoomAreaData;
    if (zoomArea != null && zoomArea.show) {
      return Rect.fromLTWH(
        chartRect.left,
        canvasRect.height - zoomArea.height,
        chartRect.width,
        zoomArea.height,
      );
    }
    return null;
  }
}

class ScopeChartPainter {
  late Paint _fillPainter;
  late Paint _strokePainter;

  late ScopeChartDmensions _dimensions;

  ScopeChartPainter() : super() {
    _strokePainter = Paint()..style = PaintingStyle.stroke;
    _fillPainter = Paint()..style = PaintingStyle.fill;
  }

  Rect get viewRect => _dimensions.canvasRect;
  Rect get chartRect => _dimensions.chartRect;
  Rect? get zoomRect => _dimensions.zoomRect;
  Rect? get verticalAxisRect => _dimensions.verticalAxisRect;
  Rect? get horizontalAxisRect => _dimensions.horizontalAxisRect;

  void paint(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    _dimensions = ScopeChartDmensions(canvasWrapper, holder);

    for (final channelData in data.channelsData) {
      if (!channelData.show || channelData.spots.isEmpty) continue;
      _drawChannel(canvasWrapper, data, channelData, holder);
    }

    _drawBackground(canvasWrapper, holder);
    _drawViewBorder(canvasWrapper, holder);
    _drawAxes(canvasWrapper, holder);
    _drawZoomArea(canvasWrapper, holder);
    _drawCursor(canvasWrapper, holder);
  }

  ScopePointerEventTarget? getTouchedElement(PointerEvent event) {
    if (_dimensions.chartRect.contains(event.localPosition)) {
      return ScopePointerEventTarget.chart;
    }

    if (_dimensions.zoomRect != null &&
        _dimensions.zoomRect!.contains(event.localPosition)) {
      return ScopePointerEventTarget.zoomarea;
    }

    return null;
  }

  void _drawCursor(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    final ScopeChartData data = holder.data;
    final cursor = data.cursorData;
    final value = data.cursorValue;
    if (value != null &&
        cursor.show &&
        value >= data.minX &&
        value <= data.maxX) {
      final x = _getPixelX(value, data.minX, data.maxX, holder);
      _strokePainter
        ..style = PaintingStyle.stroke
        ..strokeWidth = cursor.width
        ..color = cursor.color;
      canvasWrapper.drawLine(Offset(x, _dimensions.chartRect.bottom),
          Offset(x, _dimensions.chartRect.top), _strokePainter);
    }
  }

  void _drawZoomArea(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    final ScopeChartData data = holder.data;
    final zoomArea = data.zoomAreaData;
    if (zoomArea != null && zoomArea.show) {
      final viewSize = canvasWrapper.size;
      final startX = _getPixelX(data.minX, zoomArea.min, zoomArea.max, holder);
      final endX = _getPixelX(data.maxX, zoomArea.min, zoomArea.max, holder);

      _fillPainter.color = zoomArea.backgroundColor;

      canvasWrapper.drawRect(_dimensions.zoomRect!, _fillPainter);

      final cursorRect = Rect.fromLTWH(
        startX,
        viewSize.height - zoomArea.height,
        (endX - startX).clamp(zoomArea.minWidth, double.infinity),
        zoomArea.height,
      );

      _strokePainter
        ..color = zoomArea.borderColor
        ..strokeWidth = zoomArea.borderWidth;
      {
        final path = Path();
        var x1 = cursorRect.topLeft.dx;
        var y1 = cursorRect.topLeft.dy - 2;
        var x2 = cursorRect.bottomLeft.dx - 2;
        var y2 = cursorRect.bottomLeft.dy + 2;
        path.moveTo(x1, y1);
        path.lineTo(x2, y1);
        path.lineTo(x2, y2);
        path.lineTo(x1, y2);
        canvasWrapper.drawPath(path, _strokePainter);
      }

      {
        final path = Path();
        var x1 = cursorRect.topRight.dx;
        var y1 = cursorRect.topRight.dy - 2;
        var x2 = cursorRect.bottomRight.dx + 2;
        var y2 = cursorRect.bottomRight.dy + 2;
        path.moveTo(x1, y1);
        path.lineTo(x2, y1);
        path.lineTo(x2, y2);
        path.lineTo(x1, y2);
        canvasWrapper.drawPath(path, _strokePainter);
      }

      _fillPainter.color = zoomArea.color;
      canvasWrapper.drawRect(cursorRect, _fillPainter);

      final cursor = zoomArea.cursor;
      if (cursor.show && data.cursorValue != null) {
        final x =
            _getPixelX(data.cursorValue!, zoomArea.min, zoomArea.max, holder);
        _strokePainter
          ..strokeWidth = cursor.width
          ..color = cursor.color;
        _fillPainter.color = cursor.color;
        canvasWrapper.drawLine(Offset(x, _dimensions.zoomRect!.bottom),
            Offset(x, _dimensions.zoomRect!.top), _strokePainter);
        {
          final path = Path();
          path.moveTo(x, _dimensions.zoomRect!.top);
          path.lineTo(x - 3, _dimensions.zoomRect!.top - 3);
          path.lineTo(x + 3, _dimensions.zoomRect!.top - 3);
          path.close();
          canvasWrapper.drawPath(path, _fillPainter);
        }
        {
          final path = Path();
          path.moveTo(x, _dimensions.zoomRect!.bottom);
          path.lineTo(x - 3, _dimensions.zoomRect!.bottom + 3);
          path.lineTo(x + 3, _dimensions.zoomRect!.bottom + 3);
          path.close();
          canvasWrapper.drawPath(path, _fillPainter);
        }
      }
    }
  }

  void _drawBackground(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    if (data.backgroundColor.opacity == 0.0) {
      return;
    }

    _fillPainter.color = data.backgroundColor;
    canvasWrapper.drawRect(_dimensions.chartRect, _fillPainter);
  }

  void _drawViewBorder(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    ScopeChartData data = holder.data;
    var borderData = data.borderData;
    if (borderData.showBorder != true) {
      return;
    }

    /// Draw Top Line
    final topBorder = borderData.border.top;
    if (topBorder.width != 0.0) {
      _strokePainter.color = topBorder.color;
      _strokePainter.strokeWidth = topBorder.width;
      _strokePainter.transparentIfWidthIsZero();
      canvasWrapper.drawLine(_dimensions.chartRect.topLeft,
          _dimensions.chartRect.topRight, _strokePainter);
    }

    /// Draw Right Line
    final rightBorder = borderData.border.right;
    if (rightBorder.width != 0.0) {
      _strokePainter.color = rightBorder.color;
      _strokePainter.strokeWidth = rightBorder.width;
      _strokePainter.transparentIfWidthIsZero();
      canvasWrapper.drawLine(
        _dimensions.chartRect.topRight,
        _dimensions.chartRect.bottomRight,
        _strokePainter,
      );
    }

    /// Draw Bottom Line
    final bottomBorder = borderData.border.bottom;
    if (bottomBorder.width != 0.0) {
      _strokePainter.color = bottomBorder.color;
      _strokePainter.strokeWidth = bottomBorder.width;
      _strokePainter.transparentIfWidthIsZero();
      canvasWrapper.drawLine(
        _dimensions.chartRect.bottomRight,
        _dimensions.chartRect.bottomLeft,
        _strokePainter,
      );
    }

    /// Draw Left Line
    final leftBorder = borderData.border.left;
    if (leftBorder.width != 0.0) {
      _strokePainter.color = leftBorder.color;
      _strokePainter.strokeWidth = leftBorder.width;
      _strokePainter.transparentIfWidthIsZero();
      canvasWrapper.drawLine(_dimensions.chartRect.bottomLeft,
          _dimensions.chartRect.topLeft, _strokePainter);
    }
  }

  void _drawAxes(CanvasWrapper canvasWrapper, ScopePaintHolder holder) {
    ScopeChartData data = holder.data;

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
          tp.layout(minWidth: _dimensions.chartRect.height);
          canvasWrapper.save();
          canvasWrapper.rotate(-math.pi * 0.5);
          canvasWrapper.drawText(
            tp,
            Offset(
                -_dimensions.chartRect.height, title.reservedSize - tp.height),
          );
          canvasWrapper.restore();
        }
        // draw axis grid and titles
        final verticalDiff = channel.maxY - channel.minY;
        final titles = verticalAxis.titles;
        final grid = verticalAxis.grid;
        final efficientInterval = utils.getEfficientInterval(
          _dimensions.chartRect.height,
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
        Rect? lastTitleRect;

        while (verticalSeek <= end) {
          if (grid.showGrid != false) {
            final flLine = grid.getDrawingLine(verticalSeek);
            _strokePainter.color = flLine.color;
            _strokePainter.strokeWidth = flLine.strokeWidth;
            _strokePainter.transparentIfWidthIsZero();

            final bothY = _getPixelY(
              verticalSeek,
              channel.minY,
              channel.maxY,
              holder,
            );
            final x1 = _dimensions.chartRect.left;
            final x2 = _dimensions.chartRect.right;
            canvasWrapper.drawDashedLine(
              Offset(x1, bothY),
              Offset(x2, bothY),
              _strokePainter,
              flLine.dashArray,
            );
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
            final textHeight = tp.height + titles.padding;
            var x = _dimensions.chartRect.left;
            var y = _getPixelY(
              verticalSeek,
              channel.minY,
              channel.maxY,
              holder,
            );

            canvasWrapper.drawLine(
                Offset(x, y), Offset(x - titles.margin / 2, y), _strokePainter);

            x -= tp.width + titles.margin;
            y -= textHeight / 2;
            final showTitle = _checkToShowTitle(
              channel.minY,
              channel.maxY,
              titles,
              interval,
              verticalSeek,
            );
            final titleRect = Rect.fromLTWH(x, y, tp.width, textHeight);
            final skipTitle =
                lastTitleRect != null && lastTitleRect.overlaps(titleRect);
            if (showTitle != false && skipTitle != true) {
              lastTitleRect = titleRect;
              canvasWrapper.save();
              canvasWrapper.translate(x + tp.width / 2, y + textHeight / 2);
              canvasWrapper.rotate(utils.radians(titles.rotateAngle));
              canvasWrapper.translate(
                  -(x + tp.width / 2), -(y + textHeight / 2));
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
        tp.layout(minWidth: _dimensions.chartRect.width);
        canvasWrapper.drawText(tp,
            Offset(_dimensions.chartRect.left, _dimensions.chartRect.bottom));
      }
      // draw grid and titles
      final titles = horizontalAxis.titles;
      final grid = horizontalAxis.grid;
      final min = horizontalAxis.min ?? 0;
      final max = horizontalAxis.max ?? 0;
      final horizontalDiff = max - min;
      final efficientInterval = utils.getEfficientInterval(
        _dimensions.chartRect.width,
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
      Rect? lastTitleRect;
      Rect? cursorRect;

      final cursor = data.cursorData;
      if (cursor.show && data.cursorValue != null) {
        var x = _getPixelX(data.cursorValue!, data.minX, data.maxX, holder)
            .clamp(_dimensions.chartRect.left, _dimensions.chartRect.right);
        final span = TextSpan(
            style: cursor.textStyle, text: titles.getTitles(data.cursorValue!));
        final tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: titles.textDirection,
          textScaleFactor: holder.textScale,
        );
        tp.layout();
        final textWidth = tp.width + titles.padding;
        if (cursor.titlePosition == CursorTitlePosition.bottom) {
          var y = _dimensions.chartRect.bottom;
          canvasWrapper.drawLine(
              Offset(x, y), Offset(x, y + titles.margin / 2), _strokePainter);
          x -= textWidth / 2;
          y += titles.margin;
          cursorRect = Rect.fromLTWH(x, y, textWidth, tp.height);

          canvasWrapper.save();
          canvasWrapper.translate(x + textWidth / 2, y + tp.height / 2);
          canvasWrapper.rotate(utils.radians(titles.rotateAngle));
          canvasWrapper.translate(-(x + textWidth / 2), -(y + tp.height / 2));
          x += utils.translateRotatedPosition(textWidth, titles.rotateAngle);
          canvasWrapper.drawText(tp, Offset(x, y));
          canvasWrapper.restore();
        }
        if (cursor.titlePosition == CursorTitlePosition.top) {
          var y = _dimensions.chartRect.top;
          canvasWrapper.drawLine(
              Offset(x, y), Offset(x, y - titles.margin / 2), _strokePainter);
          x -= textWidth / 2;
          y -= titles.margin + tp.height;
          cursorRect = Rect.fromLTWH(x, y, textWidth, tp.height);

          canvasWrapper.save();
          canvasWrapper.translate(x + textWidth / 2, y - tp.height / 2);
          canvasWrapper.rotate(utils.radians(titles.rotateAngle));
          canvasWrapper.translate(-(x + textWidth / 2), -(y - tp.height / 2));
          x += utils.translateRotatedPosition(textWidth, titles.rotateAngle);
          canvasWrapper.drawText(tp, Offset(x, y));
          canvasWrapper.restore();
        }
      }

      while (horizontalSeek <= end) {
        if (grid.showGrid) {
          final flLineStyle = grid.getDrawingLine(horizontalSeek);
          _strokePainter.color = flLineStyle.color;
          _strokePainter.strokeWidth = flLineStyle.strokeWidth;
          _strokePainter.transparentIfWidthIsZero();

          final bothX = _getPixelX(
            horizontalSeek,
            min,
            max,
            holder,
          );
          canvasWrapper.drawDashedLine(
            Offset(bothX, _dimensions.chartRect.top),
            Offset(bothX, _dimensions.chartRect.bottom),
            _strokePainter,
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
          final textWidth = tp.width + titles.padding;
          var x = _getPixelX(horizontalSeek, min, max, holder);
          var y = _dimensions.chartRect.bottom;

          canvasWrapper.drawLine(
              Offset(x, y), Offset(x, y + titles.margin / 2), _strokePainter);

          x -= textWidth / 2;
          y += titles.margin;
          final showTitle = _checkToShowTitle(
            min,
            max,
            titles,
            interval,
            horizontalSeek,
          );
          final titleRect = Rect.fromLTWH(x, y, textWidth, tp.height);
          final skipTitle =
              (lastTitleRect != null && titleRect.overlaps(lastTitleRect)) ||
                  (cursorRect != null && titleRect.overlaps(cursorRect)) ||
                  x > (_dimensions.chartRect.width);
          if (showTitle != false && skipTitle != true) {
            lastTitleRect = titleRect;
            canvasWrapper.save();
            canvasWrapper.translate(x + textWidth / 2, y + tp.height / 2);
            canvasWrapper.rotate(utils.radians(titles.rotateAngle));
            canvasWrapper.translate(-(x + textWidth / 2), -(y + tp.height / 2));
            x += utils.translateRotatedPosition(textWidth, titles.rotateAngle);
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
    final path = appendToPath ?? Path();
    final ScopeChartData data = holder.data;
    final spots = channelData.spots;

    final iterator = spots.iterator;
    var curSpot = iterator.moveNext() ? iterator.current : null;
    var nextSpot = iterator.moveNext() ? iterator.current : curSpot;
    while (curSpot != null &&
        nextSpot != null &&
        curSpot.x < data.minX &&
        nextSpot.x < data.minX) {
      curSpot = nextSpot;
      nextSpot = iterator.moveNext() ? iterator.current : null;
    }

    if (curSpot == null) {
      return path;
    }

    var start = _clipXY(
        _dimensions.chartRect,
        _getPixelX(
          curSpot.x,
          scopeData.minX,
          scopeData.maxX,
          holder,
        ),
        _getPixelY(
          curSpot.y,
          channelData.minY,
          channelData.maxY,
          holder,
        ));

    if (appendToPath == null) {
      path.moveTo(start.dx, start.dy);
    } else {
      path.lineTo(start.dx, start.dy);
    }

    Offset? prevCoords;
    double? minY;
    double? maxY;
    while (curSpot != null && nextSpot != null) {
      final currentCoords = Offset(
        _getPixelX(
          curSpot.x,
          scopeData.minX,
          scopeData.maxX,
          holder,
        ),
        _getPixelY(
          curSpot.y,
          channelData.minY,
          channelData.maxY,
          holder,
        ),
      );

      final nextCoords = Offset(
        _getPixelX(
          nextSpot.x,
          scopeData.minX,
          scopeData.maxX,
          holder,
        ),
        _getPixelY(
          nextSpot.y,
          channelData.minY,
          channelData.maxY,
          holder,
        ),
      );

      if (prevCoords != null &&
          prevCoords.dx.round() == nextCoords.dx.round()) {
        if (maxY == null || nextCoords.dy > maxY) {
          maxY = nextCoords.dy;
        }
        if (minY == null || nextCoords.dy < minY) {
          minY = nextCoords.dy;
        }

        prevCoords = currentCoords;
        curSpot = nextSpot;
        nextSpot = iterator.moveNext() ? iterator.current : null;
        continue;
      }

      /// CurrentSpot
      final current =
          _clipXY(_dimensions.chartRect, currentCoords.dx, currentCoords.dy);

      /// Next Spot
      final next = _clipXY(_dimensions.chartRect, nextCoords.dx, nextCoords.dy);

      if (minY != null && maxY != null) {
        path.lineTo(next.dx, minY);
        path.lineTo(next.dx, maxY);
        minY = null;
        maxY = null;
      }

      if (current.dy == next.dy) {
        path.lineTo(next.dx, next.dy);
      } else {
        path.lineTo(next.dx, current.dy);
        path.lineTo(next.dx, next.dy);
      }

      prevCoords = currentCoords;
      curSpot = nextSpot;
      nextSpot = iterator.moveNext() ? iterator.current : null;

      if (nextSpot != null && nextSpot.x > data.maxX) {
        break;
      }
    }

    return path;
  }

  // ignore: unused_element
  Path _generatePath(
    Size viewSize,
    ScopeChartData scopeData,
    ScopeChannelData channelData,
    ScopePaintHolder holder, {
    Path? appendToPath,
  }) {
    final path = appendToPath ?? Path();
    final spots = channelData.spots;

    var x = _getPixelX(
      spots.first.x,
      scopeData.minX,
      scopeData.maxX,
      holder,
    );
    var y = _getPixelY(
      spots.first.y,
      channelData.minY,
      channelData.maxY,
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
          holder,
        ),
        _getPixelY(
          curSpot.y,
          channelData.minY,
          channelData.maxY,
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

  /// draw the main line by the [path]
  void _drawPath(
    CanvasWrapper canvasWrapper,
    Path path,
    ScopeChannelData data,
    ScopePaintHolder holder,
  ) {
    if (!data.show) {
      return;
    }
    _strokePainter.strokeCap = StrokeCap.butt;
    _strokePainter.color = data.color;
    _strokePainter.shader = null;
    _strokePainter.maskFilter = null;
    _strokePainter.strokeWidth = data.width;
    _strokePainter.transparentIfWidthIsZero();
    canvasWrapper.drawPath(path, _strokePainter);
  }

  double _getPixelX(
    double spotX,
    double minX,
    double maxX,
    ScopePaintHolder holder,
  ) {
    final deltaX = maxX - minX;
    final leftOffset = _dimensions.chartRect.left;
    if (deltaX == 0.0) {
      return leftOffset;
    }
    final x =
        (((spotX - minX) / deltaX) * _dimensions.chartRect.width) + leftOffset;
    return x;
  }

  /// With this function we can convert our [FlSpot] y
  /// to the view base axis y.
  double _getPixelY(
    double spotY,
    double minY,
    double maxY,
    ScopePaintHolder holder,
  ) {
    final deltaY = maxY - minY;
    if (deltaY == 0.0) {
      return _dimensions.chartRect.height;
    }

    var y = ((spotY - minY) / deltaY) * _dimensions.chartRect.height;
    y = _dimensions.chartRect.height - y;
    return y;
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
