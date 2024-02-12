import 'dart:ui';
import 'package:flutter/material.dart';
import 'chart_calculator.dart';
import 'chart_model.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    required this.viewDataList,
    this.maxViewDataNum = 0,
    required this.lastData,
    required this.detailDataList,
    this.isShowDetails = true,
    this.isShowSubview = true,
    this.viewType = 0,
    this.subviewType = 0,
  });

  ///data list
  final List<ChartModel> viewDataList;
  final int maxViewDataNum;
  final List<String> detailDataList;
  final ChartModel lastData;
  final bool isShowDetails;
  final bool isShowSubview;
  final int viewType;
  final int subviewType;

  /// painter
  final Paint _paint = Paint();

  ///xy value list from scale lines
  final List<double> _verticalXList = [];
  final List<double> _horizontalYList = [];

  ///line start point
  double _leftStart = 0;
  double _rightEnd = 0;
  double _bottomEnd = 0;
  double _topStart = 0;

  ///colors
  Color scaleTextColor = Colors.grey;
  Color scaleLineColor = Colors.grey;
  Color riseColor = const Color.fromRGBO(3, 192, 134, 1);
  Color fallColor = const Color(0xFFff524a);
  Color ma5Color = const Color(0xFFF6DC93);
  Color ma10Color = const Color(0xFF61D1C0);
  Color ma30Color = const Color(0xFFCB92FE);

  ///detail text
  /// cn
  List detailTitleCN = ["时间", "开", "高", "收", "低", "涨跌额", "涨跌幅", "成交量"];

  /// en
  List detailTitleEN = ["time", "open", "hign", "close", "low", "up or down amount", "up or down rate", "volume"];

  /// main view variable
  double _maxPrice = 0;
  double _minPrice = 0;
  double _maxVolume = 0;
  double _maxPriceX = 0, _maxPriceY = 0, _minPriceX = 0, _minPriceY = 0;
  double _verticalSpace = 0;

  ///candlestick
  double _perPriceRectWidth = 0, _perPriceRectHeight = 0, _perVolumeRectHeight = 0;
  double _subViewTopY = 0;
  double _priceChartBottom = 0, _volumeChartBottom = 0;
  double _topPrice = 0;
  double _botPrice = 0;

  ///
  double _maxMACD = 0;
  double _minMACD = 0;
  double _perMACDHeight = 0;
  double _subviewCenterY = 0;
  double _perDEAHeight = 0;
  double _perDifHeight = 0;

  /// kdj
  double _maxK = 0;
  double _kHeight = 0;
  double _dHeight = 0;
  double _jHeight = 0;

  /// rsi
  double _rsiHeight = 0;

  ///
  final ChartCalculator _chartCalculator = ChartCalculator();
  List<Pointer> mainMa5PointList = [];
  List<Pointer> mainMa10PointList = [];
  List<Pointer> mainMa30PointList = [];
  List<Pointer> volumeMa5PointList = [];
  List<Pointer> volumeMa10PointList = [];
  List<Pointer> subviewMA5List = [];
  List<Pointer> subviewMA10List = [];
  List<Pointer> subviewMA30List = [];
  Path path = Path();

  /// draw
  @override
  void paint(Canvas canvas, Size size) {
    if (viewDataList.isEmpty) return;
    _leftStart = 5.0;
    _topStart = 20.0;
    _rightEnd = size.width;
    _bottomEnd = size.height;

    ///view
    _drawScaleLine(canvas); // 背景线
    _drawMainChartView(canvas); // 柱状图

    ///curve
    _drawBezierCurve(canvas); //均线

    ///text
    _drawMaxAndMinPriceText(canvas); //最高最低价
    _drawAbscissaText(canvas); //最底部的日期文字
    _drawOrdinateText(canvas); //最右侧的价格文字
    _drawTopText(canvas); //顶部的五日十日文字
    _drawVolumeText(canvas); // vol MA5文字  MA10文字

    /// details
    _drawCrossHairLine(canvas); //点击时十字星线
    _drawDetails(canvas); //点击时显示小框
    _drawLastData(canvas); //显示实时价格小蓝框
  }

  /// current price
  void _drawLastData(Canvas canvas) {
    if (isShowDetails) return;
    // horizontal line
    double moveY = lastData.closeY;

    if (moveY < _horizontalYList[0]) {
      moveY = _horizontalYList[0];
    } else if (moveY > _priceChartBottom) {
      moveY = _priceChartBottom;
    }
    resetPaintStyle(color: Colors.red, paintingStyle: PaintingStyle.fill);

    var max = _verticalXList[_verticalXList.length - 1]; // size获取到宽度
    var dashWidth = 5;
    var dashSpace = 5;
    double startX = _verticalXList[0];
    final space = (dashSpace + dashWidth);

    while (startX < max) {
      canvas.drawLine(Offset(startX, moveY), Offset(startX + dashWidth, moveY), _paint);
      startX += space;
    }

    resetPaintStyle(color: Colors.blue, paintingStyle: PaintingStyle.fill);
    // left label
    String movePrice = setPrecision(lastData.closePrice, 2);
    Rect leftRect = Rect.fromLTRB(_verticalXList[_verticalXList.length - 1], moveY + _getTextBounds(movePrice).height,
        _rightEnd, moveY - _getTextBounds(movePrice).height);
    canvas.drawRect(leftRect, _paint);
    _drawText(canvas, movePrice, Colors.black,
        Offset(_verticalXList[_verticalXList.length - 1] + dp2px(1.0), moveY - _getTextBounds(movePrice).height / 2));
  }

  ///draw lines for the background which uses to measures the spaces
  /// width is size of device's width and height is so on
  void _drawScaleLine(Canvas canvas) {
    resetPaintStyle(color: scaleLineColor, strokeWidth: 0.2, paintingStyle: PaintingStyle.fill);
    //vertical scale line
    _verticalXList.clear();
    double horizontalSpace = (_rightEnd - _leftStart - 50) / 4;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(Offset(_leftStart + horizontalSpace * i, _topStart),
          Offset(_leftStart + horizontalSpace * i, _bottomEnd - dp2px(6.0)), _paint);
      _verticalXList.add(_leftStart + horizontalSpace * i);
    }
    //horizontal scale line
    _horizontalYList.clear();
    _verticalSpace = (_bottomEnd - _topStart - dp2px(6.0)) / 5;
    double horizontalRightEnd;
    for (int i = 0; i < 6; i++) {
      if (i == 0 || i == 5 || i == 4 || (isShowSubview && i == 3)) {
        horizontalRightEnd = _rightEnd;
      } else {
        horizontalRightEnd = _verticalXList[_verticalXList.length - 1];
      }
      canvas.drawLine(Offset(_leftStart, _topStart + _verticalSpace * i),
          Offset(horizontalRightEnd, _topStart + _verticalSpace * i), _paint);
      _horizontalYList.add(_topStart + _verticalSpace * i);
    }
    //subview's top line
    _subViewTopY = _horizontalYList[4] + dp2px(5.0);
    double dx = _verticalXList[_verticalXList.length - 1];
    double dy = _horizontalYList[4] + _verticalSpace / 2 + dp2px(5.0);
    canvas.drawLine(Offset(_leftStart, dy), Offset(dx, dy), _paint);
    //value's middle scale line
    if (isShowSubview) {
      double dx = _verticalXList[_verticalXList.length - 1];
      double dy = _horizontalYList[3] + _verticalSpace / 2 + dp2px(5.0);
      canvas.drawLine(Offset(_leftStart, dy), Offset(dx, dy), _paint);
    }
  }

  /// main view
  void _drawMainChartView(Canvas canvas) {
    //perWidth =（leftStart - rightEnd） / maxViewData
    _perPriceRectWidth = (_verticalXList[_verticalXList.length - 1] - _verticalXList[0]) / maxViewDataNum;
    //max and min price
    _maxPrice = viewDataList[0].maxPrice;
    _minPrice = viewDataList[0].minPrice;
    _maxVolume = viewDataList[0].volume;
    _maxMACD = viewDataList[0].macd;
    _minMACD = viewDataList[0].macd;
    double maxDEA = viewDataList[0].dea;
    double minDEA = viewDataList[0].dea;
    double maxDIF = viewDataList[0].dif;
    double minDIF = viewDataList[0].dif;
    _maxK = viewDataList[0].k;
    double maxD = viewDataList[0].d;
    double maxJ = viewDataList[0].j;

    for (int i = 0; i < viewDataList.length; i++) {
      viewDataList[i].setLeftStartX(_verticalXList[_verticalXList.length - 1] - (viewDataList.length - i) * _perPriceRectWidth);
      viewDataList[i]
          .setRightEndX(_verticalXList[_verticalXList.length - 1] - (viewDataList.length - i - 1) * _perPriceRectWidth);
      // max price
      if (viewDataList[i].maxPrice >= _maxPrice) {
        _maxPrice = viewDataList[i].maxPrice;
        _maxPriceX = viewDataList[i].leftStartX + _perPriceRectWidth / 2;
      }
      // min price
      if (viewDataList[i].minPrice <= _minPrice) {
        _minPrice = viewDataList[i].minPrice;
        _minPriceX = viewDataList[i].leftStartX + _perPriceRectWidth / 2;
      }
      // max volume
      if (viewDataList[i].volume >= _maxVolume) {
        _maxVolume = viewDataList[i].volume;
      }

      if (isShowSubview && subviewType == 0) {
        if (viewDataList[i].macd >= _maxMACD) {
          _maxMACD = viewDataList[i].macd;
        }
        if (viewDataList[i].macd <= _minMACD) {
          _minMACD = viewDataList[i].macd;
        }
        if (viewDataList[i].dea >= maxDEA) {
          maxDEA = viewDataList[i].dea;
        }
        if (viewDataList[i].dea <= minDEA) {
          minDEA = viewDataList[i].dea;
        }
        if (viewDataList[i].dif >= maxDIF) {
          maxDIF = viewDataList[i].dif;
        }
        if (viewDataList[i].dif <= minDIF) {
          minDIF = viewDataList[i].dif;
        }
      } else if (isShowSubview && subviewType == 1) {
        if (viewDataList[i].k >= _maxK) {
          _maxK = viewDataList[i].k;
        }
        if (viewDataList[i].d >= maxD) {
          maxD = viewDataList[i].d;
        }
        if (viewDataList[i].j >= maxJ) {
          maxJ = viewDataList[i].j;
        }
      }
    }
    _topPrice = _maxPrice + (_maxPrice - _minPrice) * 0.1;
    _botPrice = _minPrice - (_maxPrice - _minPrice) * 0.1;
    //show the subview
    if (!isShowSubview) {
      _priceChartBottom = _horizontalYList[4];
      _volumeChartBottom = _horizontalYList[5];
    } else {
      _priceChartBottom = _horizontalYList[3];
      _volumeChartBottom = _horizontalYList[4];
    }
    //price data
    _perPriceRectHeight = (_priceChartBottom - _horizontalYList[0]) / (_topPrice - _botPrice);
    _maxPriceY = _horizontalYList[0] + (_topPrice - _maxPrice) * _perPriceRectHeight;
    _minPriceY = _horizontalYList[0] + (_topPrice - _minPrice) * _perPriceRectHeight;
    //volume data
    _perVolumeRectHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / _maxVolume;
    // subview
    if (isShowSubview && subviewType == 0) {
      // macd
      if (_maxMACD > 0 && _minMACD < 0) {
        _perMACDHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / (_maxMACD - _minMACD).abs();
        _subviewCenterY = _subViewTopY + _maxMACD * _perMACDHeight;
      } else if (_maxMACD <= 0) {
        _perMACDHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / _minMACD.abs();
        _subviewCenterY = _subViewTopY;
      } else if (_maxMACD >= 0) {
        _perMACDHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / _maxMACD.abs();
        _subviewCenterY = _horizontalYList[_horizontalYList.length - 1];
      }
      //dea
      if (maxDEA > 0 && minDEA < 0) {
        _perDEAHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / (maxDEA - minDEA);
      } else if (maxDEA <= 0) {
        _perDEAHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / minDEA.abs();
      } else if (minDEA >= 0) {
        _perDEAHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / maxDEA.abs();
      }
      //dif
      if (maxDIF > 0 && minDIF < 0) {
        _perDifHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / (maxDIF - minDIF);
      } else if (maxDIF <= 0) {
        _perDifHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / minDEA.abs();
      } else if (minDIF >= 0) {
        _perDifHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / maxDIF.abs();
      }
    } else if (isShowSubview && subviewType == 1) {
      _kHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / _maxK;
      _dHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / maxD;
      _jHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / maxJ;
    } else if (isShowSubview && subviewType == 2) {
      _rsiHeight = (_horizontalYList[_horizontalYList.length - 1] - _subViewTopY) / 100;
    }

    for (int i = 0; i < viewDataList.length; i++) {
      double openPrice = viewDataList[i].openPrice;
      double closePrice = viewDataList[i].closePrice;
      double higherPrice;
      double lowerPrice;
      if (openPrice >= closePrice) {
        higherPrice = openPrice;
        lowerPrice = closePrice;
        resetPaintStyle(color: const Color(0xFFff524a), paintingStyle: PaintingStyle.fill);
      } else {
        higherPrice = closePrice;
        lowerPrice = openPrice;
        resetPaintStyle(color: const Color.fromRGBO(3, 192, 134, 1), paintingStyle: PaintingStyle.fill);
      }
      viewDataList[i].setCloseY(_horizontalYList[0] + (_topPrice - closePrice) * _perPriceRectHeight);
      viewDataList[i].setOpenY(_horizontalYList[0] + (_topPrice - openPrice) * _perPriceRectHeight);
      // price rect
      Rect priceRect = Rect.fromLTRB(
          viewDataList[i].leftStartX + dp2px(0.2),
          _maxPriceY + (_maxPrice - higherPrice) * _perPriceRectHeight,
          viewDataList[i].rightEndX - dp2px(0.2),
          _maxPriceY + (_maxPrice - lowerPrice) * _perPriceRectHeight);
      canvas.drawRect(priceRect, _paint);
      // price line
      canvas.drawLine(
          Offset(viewDataList[i].leftStartX + _perPriceRectWidth / 2,
              _maxPriceY + (_maxPrice - viewDataList[i].maxPrice) * _perPriceRectHeight),
          Offset(viewDataList[i].leftStartX + _perPriceRectWidth / 2,
              _maxPriceY + (_maxPrice - viewDataList[i].minPrice) * _perPriceRectHeight),
          _paint);
      // volume rect
      Rect volumeRect = Rect.fromLTRB(
          viewDataList[i].leftStartX + dp2px(0.2),
          _volumeChartBottom - viewDataList[i].volume * _perVolumeRectHeight,
          viewDataList[i].rightEndX - dp2px(0.2),
          _volumeChartBottom);
      canvas.drawRect(volumeRect, _paint);
      // macd
      double w = (viewDataList[i].leftStartX + viewDataList[i].rightEndX) / 2;
      if (isShowSubview && subviewType == 0) {
        double macd = viewDataList[i].macd;
        if (macd > 0) {
          resetPaintStyle(color: riseColor);
          canvas.drawLine(Offset(w, _subviewCenterY - macd * _perMACDHeight), Offset(w, _subviewCenterY), _paint);
        } else {
          resetPaintStyle(color: fallColor);
          canvas.drawLine(Offset(w, _subviewCenterY), Offset(w, _subviewCenterY + macd.abs() * _perMACDHeight), _paint);
        }
      }
    }
  }

  /// draw bezier line
  void _drawBezierCurve(Canvas canvas) {
    mainMa5PointList.clear();
    mainMa10PointList.clear();
    mainMa30PointList.clear();
    volumeMa5PointList.clear();
    volumeMa10PointList.clear();
    subviewMA5List.clear();
    subviewMA10List.clear();
    subviewMA30List.clear();

    for (int i = 0; i < viewDataList.length; i++) {
      // volume
      Pointer volumeMa5Pointer = Pointer();
      volumeMa5Pointer.setX(viewDataList[i].leftStartX);
      volumeMa5Pointer.setY(_volumeChartBottom - viewDataList[i].volumeMA5 * _perVolumeRectHeight);
      volumeMa5PointList.add(volumeMa5Pointer);
      Pointer volumeMa10Pointer = Pointer();
      volumeMa10Pointer.setX(viewDataList[i].leftStartX);
      volumeMa10Pointer.setY(_volumeChartBottom - viewDataList[i].volumeMA10 * _perVolumeRectHeight);
      volumeMa10PointList.add(volumeMa10Pointer);
      switch (viewType) {
        case 0:
          // price
          Pointer priceMa5Pointer = Pointer();
          priceMa5Pointer.setX(viewDataList[i].leftStartX);
          priceMa5Pointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].priceMA5) * _perPriceRectHeight);
          mainMa5PointList.add(priceMa5Pointer);
          Pointer priceMa10Pointer = Pointer();
          priceMa10Pointer.setX(viewDataList[i].leftStartX);
          priceMa10Pointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].priceMA10) * _perPriceRectHeight);
          mainMa10PointList.add(priceMa10Pointer);
          Pointer priceMa30Pointer = Pointer();
          priceMa30Pointer.setX(viewDataList[i].leftStartX);
          priceMa30Pointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].priceMA30) * _perPriceRectHeight);
          mainMa30PointList.add(priceMa30Pointer);
          break;
        case 1:
          Pointer bollMBPointer = Pointer();
          bollMBPointer.setX(viewDataList[i].leftStartX);
          bollMBPointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].bollMB) * _perPriceRectHeight);
          mainMa5PointList.add(bollMBPointer);
          Pointer bollUPPointer = Pointer();
          bollUPPointer.setX(viewDataList[i].leftStartX);
          bollUPPointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].bollUP) * _perPriceRectHeight);
          mainMa10PointList.add(bollUPPointer);
          Pointer bollDNPointer = Pointer();
          bollDNPointer.setX(viewDataList[i].leftStartX);
          bollDNPointer.setY(_maxPriceY + (_maxPrice - viewDataList[i].bollDN) * _perPriceRectHeight);
          mainMa30PointList.add(bollDNPointer);
          break;
        case 2:
          break;
      }

      if (isShowSubview && subviewType == 0) {
        Pointer difPoint = Pointer();
        difPoint.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
        difPoint.setY(_subviewCenterY - viewDataList[i].dif * _perDifHeight);
        subviewMA5List.add(difPoint);

        Pointer deaPoint = Pointer();
        deaPoint.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
        deaPoint.setY(_subviewCenterY - viewDataList[i].dea * _perDEAHeight);
        subviewMA10List.add(deaPoint);
      } else if (isShowSubview && subviewType == 1) {
        Pointer kPoint = Pointer();
        if (viewDataList[i].k > 0) {
          kPoint.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
          kPoint.setY(_horizontalYList[5] - viewDataList[i].k * _kHeight);
          subviewMA5List.add(kPoint);
        }
        Pointer dPoint = Pointer();
        if (viewDataList[i].d > 0) {
          dPoint.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
          dPoint.setY(_horizontalYList[5] - viewDataList[i].d * _dHeight);
          subviewMA10List.add(dPoint);
        }
        Pointer jPoint = Pointer();
        if (viewDataList[i].j > 0) {
          jPoint.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
          jPoint.setY(_horizontalYList[5] - viewDataList[i].j * _jHeight);
          subviewMA30List.add(jPoint);
        }
      } else if (isShowSubview && subviewType == 2) {
        Pointer rs1Point = Pointer();
        rs1Point.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
        rs1Point.setY(_horizontalYList[5] - viewDataList[i].rs1 * _rsiHeight);
        subviewMA5List.add(rs1Point);
        Pointer rs2Point = Pointer();
        rs2Point.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
        rs2Point.setY(_horizontalYList[5] - viewDataList[i].rs2 * _rsiHeight);
        subviewMA10List.add(rs2Point);
        Pointer rs3Point = Pointer();
        rs3Point.setX(viewDataList[i].leftStartX + _perPriceRectWidth / 2);
        rs3Point.setY(_horizontalYList[5] - viewDataList[i].rs3 * _rsiHeight);
        subviewMA30List.add(rs3Point);
      }
    }
    _drawMainBezierCurve(canvas);
    _drawVolumeBezierCurve(canvas);
    if (isShowSubview) {
      _drawSubviewCurve(canvas);
    }
  }

  void _drawMainBezierCurve(Canvas canvas) {
    ///ma5
    _chartCalculator.setBezierPath(mainMa5PointList, path);
    resetPaintStyle(color: ma5Color, strokeWidth: 1);
    canvas.drawPath(path, _paint);

    ///ma10
    _chartCalculator.setBezierPath(mainMa10PointList, path);
    resetPaintStyle(color: ma10Color, strokeWidth: 1);
    canvas.drawPath(path, _paint);

    ///ma30
    _chartCalculator.setBezierPath(mainMa30PointList, path);
    resetPaintStyle(color: ma30Color, strokeWidth: 1);
    canvas.drawPath(path, _paint);
  }

  void _drawVolumeBezierCurve(Canvas canvas) {
    // ma5
    _chartCalculator.setBezierPath(volumeMa5PointList, path);
    resetPaintStyle(color: ma5Color, strokeWidth: 1);
    canvas.drawPath(path, _paint);
    // ma 10
    _chartCalculator.setBezierPath(volumeMa10PointList, path);
    resetPaintStyle(color: ma10Color, strokeWidth: 1);
    canvas.drawPath(path, _paint);
  }

  void _drawSubviewCurve(Canvas canvas) {
    // 5
    _chartCalculator.setLinePath(subviewMA5List, path);
    resetPaintStyle(color: ma5Color);
    canvas.drawPath(path, _paint);
    // 10
    _chartCalculator.setLinePath(subviewMA10List, path);
    resetPaintStyle(color: ma10Color);
    canvas.drawPath(path, _paint);
    // 30
    _chartCalculator.setLinePath(subviewMA30List, path);
    resetPaintStyle(color: ma30Color);
    canvas.drawPath(path, _paint);
  }

  /// draw max and min price text
  void _drawMaxAndMinPriceText(Canvas canvas) {
    resetPaintStyle(color: Colors.white);
    // max price text
    String maxPriceText = formatDataNum(_maxPrice);
    double maxPriceTextX;
    if (_maxPriceX + _getTextBounds(maxPriceText).width + dp2px(5.0) < _verticalXList[_verticalXList.length - 1]) {
      maxPriceTextX = _maxPriceX + dp2px(5.0);
      canvas.drawLine(Offset(_maxPriceX, _maxPriceY), Offset(maxPriceTextX, _maxPriceY), _paint);
    } else {
      maxPriceTextX = _maxPriceX - _getTextBounds(maxPriceText).width - dp2px(5);
      canvas.drawLine(Offset(_maxPriceX - dp2px(5.0), _maxPriceY), Offset(_maxPriceX, _maxPriceY), _paint);
    }
    // max text
    _drawText(canvas, maxPriceText, Colors.white, Offset(maxPriceTextX, _maxPriceY - _getTextBounds(maxPriceText).height / 2));
    // min price text
    String minPriceText = formatDataNum(_minPrice);
    double minPriceTextX;
    if (_minPriceX + _getTextBounds(minPriceText).width + dp2px(5.0) < _verticalXList[_verticalXList.length - 1]) {
      minPriceTextX = _minPriceX + dp2px(5.0);
      canvas.drawLine(Offset(minPriceTextX - dp2px(5.0), _minPriceY), Offset(minPriceTextX, _minPriceY), _paint);
    } else {
      minPriceTextX = _minPriceX - _getTextBounds(minPriceText).width - dp2px(5.0);
      canvas.drawLine(Offset(_minPriceX - dp2px(5.0), _minPriceY), Offset(_minPriceX, _minPriceY), _paint);
    }
    // min text
    _drawText(canvas, minPriceText, Colors.white, Offset(minPriceTextX, _minPriceY - _getTextBounds(minPriceText).height / 2));
  }

  /// draw abscissa scale text
  void _drawAbscissaText(Canvas canvas) {
    for (int i = 0; i < _verticalXList.length; i++) {
      if (i == 0 &&
          viewDataList[0].leftStartX <= _verticalXList[0] + _perPriceRectWidth / 2 &&
          viewDataList[0].rightEndX > _verticalXList[0]) {
        String timestamp = dateFormat(viewDataList[0].timestamp);
        _drawText(canvas, timestamp, scaleTextColor, Offset(_leftStart, _horizontalYList[_horizontalYList.length - 1]));
      } else if (i == _verticalXList.length - 1) {
        String dateTime = dateFormat(viewDataList[viewDataList.length - 1].timestamp);
        _drawText(canvas, dateTime, scaleTextColor,
            Offset(_verticalXList[_verticalXList.length - 1] - 10, _horizontalYList[_horizontalYList.length - 1]));
      } else {
        for (ChartModel data in viewDataList) {
          if (data.leftStartX <= _verticalXList[i] && data.rightEndX >= _verticalXList[i]) {
            String dateTime = dateFormat(data.timestamp);
            _drawText(canvas, dateTime, scaleTextColor,
                Offset(_verticalXList[i] - 10, _horizontalYList[_horizontalYList.length - 1]));
            break;
          }
        }
      }
    }
  }

  /// draw ordinate scale text
  void _drawOrdinateText(Canvas canvas) {
    // text start x point
    double rightX = _verticalXList[_verticalXList.length - 1] + dp2px(1.0);

    /// price scale text
    // max price
    String maxPriceText = formatDataNum(_topPrice);
    _drawText(canvas, maxPriceText, scaleTextColor, Offset(rightX, _horizontalYList[0]));
    // min price
    String minPriceText = formatDataNum(_botPrice);
    _drawText(canvas, minPriceText, scaleTextColor, Offset(rightX, _priceChartBottom - _getTextBounds(minPriceText).height));
    // average price
    if (!isShowSubview) {
      double avgPrice = (_topPrice - _botPrice) / 4;
      for (int i = 0; i < 3; i++) {
        String price = formatDataNum(_topPrice - avgPrice * (i + 1));
        _drawText(canvas, price, scaleTextColor, Offset(rightX, _horizontalYList[i + 1] - _getTextBounds(price).height / 2));
      }
    } else {
      double avgPrice = (_topPrice - _botPrice) / 3;
      for (int i = 0; i < 2; i++) {
        String price = formatDataNum(_topPrice - avgPrice * (i + 1));
        _drawText(canvas, price, scaleTextColor, Offset(rightX, _horizontalYList[i + 1] - _getTextBounds(price).height / 2));
      }
      String topSubviewText = "";
      String centerSubviewText = "";
      String botSubviewText = "";
      if (subviewType == 0) {
        if (_maxMACD > 0 && _minMACD < 0) {
          topSubviewText = setPrecision(_maxMACD, 2);
          centerSubviewText = setPrecision((_maxMACD - _minMACD) / 2, 2);
          botSubviewText = setPrecision(_minMACD, 2);
        } else if (_maxMACD <= 0) {
          topSubviewText = "0.0";
          centerSubviewText = setPrecision((_minMACD - _maxMACD) / 2, 2);
          botSubviewText = setPrecision(_minMACD, 2);
        } else if (_minMACD >= 0) {
          topSubviewText = setPrecision(_maxMACD, 2);
          centerSubviewText = setPrecision((_maxMACD - _minMACD) / 2, 2);
          botSubviewText = "0";
        }
      } else if (subviewType == 1) {
        topSubviewText = formatDataNum(_maxK);
        centerSubviewText = formatDataNum(_maxK / 2);
        botSubviewText = "0.0";
      } else if (subviewType == 2) {
        topSubviewText = "100.0";
        centerSubviewText = "50.0";
        botSubviewText = "0.0";
      }
      _drawText(canvas, topSubviewText, scaleTextColor,
          Offset(_verticalXList[_verticalXList.length - 1], _horizontalYList[_horizontalYList.length - 2]));
      _drawText(
          canvas,
          centerSubviewText,
          scaleTextColor,
          Offset(
              _verticalXList[_verticalXList.length - 1],
              _horizontalYList[_horizontalYList.length - 1] -
                  _verticalSpace / 2 -
                  _getTextBounds(centerSubviewText).height / 2 +
                  dp2px(5.0)));
      _drawText(
          canvas,
          botSubviewText,
          scaleTextColor,
          Offset(_verticalXList[_verticalXList.length - 1],
              _horizontalYList[_horizontalYList.length - 1] - _getTextBounds(centerSubviewText).height));
    }

    /// volume scale text
    // max volume
    String maxVolumeText = setPrecision(_maxVolume, 2);
    _drawText(
        canvas,
        maxVolumeText,
        scaleTextColor,
        Offset(
          rightX,
          _priceChartBottom,
        ));
    // middle volume
    String middleVolume = setPrecision(_maxVolume / 2, 2);
    _drawText(canvas, middleVolume, scaleTextColor,
        Offset(rightX, _volumeChartBottom - _verticalSpace / 2 - _getTextBounds(middleVolume).height / 2 + dp2px(5.0)));
    // bottom volume
    String bottomVolume = "0.00";
    _drawText(canvas, bottomVolume, scaleTextColor, Offset(rightX, _volumeChartBottom - _getTextBounds(bottomVolume).height));
  }

  /// draw top text
  void _drawTopText(Canvas canvas) {
    String indexTopTextOne = '';
    String indexTopTextTwo = '';
    String indexTopTextThree = '';
    switch (viewType) {
      case 0:
        indexTopTextOne = "MA5WW:${formatDataNum(lastData.priceMA5)}";
        indexTopTextTwo = "MA10WW:${formatDataNum(lastData.priceMA10)}";
        indexTopTextThree = "MA30WW:${formatDataNum(lastData.priceMA30)}";
        break;
      case 1:
        indexTopTextOne = "BOLL:${formatDataNum(lastData.bollMB)}";
        indexTopTextTwo = "UB:${formatDataNum(lastData.bollUP)}";
        indexTopTextThree = "LB:${formatDataNum(lastData.bollDN)}";
        break;
      case 2:
        break;
    }
    _drawText(canvas, indexTopTextOne, ma5Color, Offset(_leftStart, _topStart - _getTextBounds(indexTopTextOne).height - 1));
    _drawText(
        canvas,
        indexTopTextTwo,
        ma10Color,
        Offset(_leftStart + _getTextBounds(indexTopTextOne).width + dp2px(5.0),
            _topStart - _getTextBounds(indexTopTextOne).height - 1));
    _drawText(
        canvas,
        indexTopTextThree,
        ma30Color,
        Offset(_leftStart + _getTextBounds(indexTopTextOne).width + _getTextBounds(indexTopTextTwo).width + dp2px(10.0),
            _topStart - _getTextBounds(indexTopTextOne).height - 1));
  }

  /// draw volume text
  void _drawVolumeText(Canvas canvas) {
    String volumeText = "";
    String volumeMA5 = "";
    String volumeMA10 = "";
    volumeText = "VOL:${formatDataNum(lastData.volume)}";
    _drawText(canvas, volumeText, ma30Color, Offset(_verticalXList[0], _priceChartBottom));
    volumeMA5 = "MA5:${formatDataNum(lastData.volumeMA5)}";
    _drawText(canvas, volumeMA5, ma5Color,
        Offset(_verticalXList[0] + _getTextBounds(volumeText).width + dp2px(5.0), _priceChartBottom));
    volumeMA10 = "MA10:${formatDataNum(lastData.volumeMA10)}";
    _drawText(
        canvas,
        volumeMA10,
        ma10Color,
        Offset(_verticalXList[0] + _getTextBounds(volumeText).width + _getTextBounds(volumeMA5).width + dp2px(10.0),
            _priceChartBottom));

    String titleText = "";
    String firstText = "";
    String secondText = "";
    String thirdText = "";

    if (isShowSubview && subviewType == 0) {
      titleText = "MACD(12,26,9)";
      firstText = "MACD:" "${formatDataNum(lastData.macd)}";
      secondText = "DIF:" "${formatDataNum(lastData.dif)}";
      thirdText = "DEA:" "${formatDataNum(lastData.dea)}";
    } else if (isShowSubview && subviewType == 1) {
      titleText = "KDJ(9,3,3)";
      firstText = "K:${setPrecision(lastData.k, 2)}";
      secondText = "D:${setPrecision(lastData.d, 2)}";
      thirdText = "J:${setPrecision(lastData.j, 2)}";
    } else if (isShowSubview && subviewType == 2) {
      titleText = "RSI(6,12,24)";
      firstText = "RSI1:${setPrecision(lastData.rs1, 2)}";
      secondText = "RSI2:${setPrecision(lastData.rs2, 2)}";
      thirdText = "RSI3:${setPrecision(lastData.rs3, 2)}";
    }
    _drawText(canvas, titleText, scaleTextColor, Offset(_verticalXList[0], _horizontalYList[4]));

    _drawText(canvas, firstText, ma5Color,
        Offset(_verticalXList[0] + _getTextBounds(titleText).width + dp2px(5), _horizontalYList[4]));

    _drawText(
        canvas,
        secondText,
        ma10Color,
        Offset(_verticalXList[0] + _getTextBounds(titleText).width + _getTextBounds(firstText).width + dp2px(10),
            _horizontalYList[4]));

    _drawText(
        canvas,
        thirdText,
        ma30Color,
        Offset(
            _verticalXList[0] +
                _getTextBounds(titleText).width +
                _getTextBounds(firstText).width +
                _getTextBounds(secondText).width +
                dp2px(15),
            _horizontalYList[4]));
  }

  /// draw cross line
  void _drawCrossHairLine(Canvas canvas) {
    if (isShowDetails == false) {
      return;
    }
    // vertical line
    resetPaintStyle(color: Colors.blue, strokeWidth: 3);
    canvas.drawLine(Offset(lastData.leftStartX + _perPriceRectWidth / 2, _horizontalYList[0]),
        Offset(lastData.leftStartX + _perPriceRectWidth / 2, _horizontalYList[_horizontalYList.length - 1]), _paint);
    // horizontal line
    resetPaintStyle(color: Colors.blue, strokeWidth: 3);
    double moveY = lastData.closeY;

    if (moveY < _horizontalYList[0]) {
      moveY = _horizontalYList[0];
    } else if (moveY > _priceChartBottom) {
      moveY = _priceChartBottom;
    }

    canvas.drawLine(Offset(_verticalXList[0], moveY), Offset(_verticalXList[_verticalXList.length - 1], moveY), _paint);

    // bottom label
    Rect bottomRect = Rect.fromLTRB(lastData.leftStartX + _perPriceRectWidth / 2 - dp2px(15), _bottomEnd - 20,
        lastData.leftStartX + _perPriceRectWidth / 2 + dp2px(15), _bottomEnd);
    resetPaintStyle(color: Colors.black, paintingStyle: PaintingStyle.fill);
    canvas.drawRect(bottomRect, _paint);
    // bottom text
    String moveTime = dateFormat(lastData.timestamp);
    _drawText(
        canvas,
        moveTime,
        Colors.white,
        Offset(
            lastData.leftStartX + dp2px(1.0) + _perPriceRectWidth / 2 - _getTextBounds(moveTime).width / 2, _bottomEnd - 15));
    // right label
    String movePrice = setPrecision(lastData.closePrice, 2);
    Rect leftRect = Rect.fromLTRB(_verticalXList[_verticalXList.length - 1], moveY + _getTextBounds(movePrice).height,
        _rightEnd, moveY - _getTextBounds(movePrice).height);
    canvas.drawRect(leftRect, _paint);
    // right text
    _drawText(canvas, movePrice, Colors.white,
        Offset(_verticalXList[_verticalXList.length - 1] + dp2px(1.0), moveY - _getTextBounds(movePrice).height / 2));
  }

  /// draw details
  void _drawDetails(Canvas canvas) {
    if (!isShowDetails) {
      return;
    }
    Color detailTextColor = Colors.white;
    double rectWidth = 120;
    double detailRectHeight = 128;
    if (lastData.leftStartX + _perPriceRectWidth / 2 <= _verticalXList[_verticalXList.length - 1] / 2) {
      // right
      Rect rightRect = Rect.fromLTRB(_verticalXList[_verticalXList.length - 1] - rectWidth, _horizontalYList[0],
          _verticalXList[_verticalXList.length - 1], _horizontalYList[0] + detailRectHeight);
      canvas.drawRect(rightRect, _paint);
      // rect linec
      resetPaintStyle(color: Colors.blue, strokeWidth: 5);
      canvas.drawLine(Offset(_verticalXList[_verticalXList.length - 1], _horizontalYList[0]),
          Offset(_verticalXList[_verticalXList.length - 1], _horizontalYList[0] + detailRectHeight), _paint);
      canvas.drawLine(Offset(_verticalXList[_verticalXList.length - 1], _horizontalYList[0]),
          Offset(_verticalXList[_verticalXList.length - 1] - rectWidth, _horizontalYList[0]), _paint);
      canvas.drawLine(Offset(_verticalXList[_verticalXList.length - 1] - rectWidth, _horizontalYList[0]),
          Offset(_verticalXList[_verticalXList.length - 1] - rectWidth, _horizontalYList[0] + detailRectHeight), _paint);
      canvas.drawLine(Offset(_verticalXList[_verticalXList.length - 1], _horizontalYList[0] + detailRectHeight),
          Offset(_verticalXList[_verticalXList.length - 1] - rectWidth, _horizontalYList[0] + detailRectHeight), _paint);
      // detail title
      for (int i = 0; i < detailTitleCN.length; i++) {
        _drawText(canvas, detailTitleCN[i], detailTextColor,
            Offset(_verticalXList[_verticalXList.length - 1] - rectWidth + 3, _horizontalYList[0] + detailRectHeight / 8 * i));
      }
      // detail data
      double upDownAmount = lastData.closePrice - lastData.openPrice;
      for (int i = 0; i < detailDataList.length; i++) {
        if (i == 5 || i == 6) {
          if (upDownAmount > 0) {
            detailTextColor = riseColor;
          } else {
            detailTextColor = fallColor;
          }
        } else {
          detailTextColor = Colors.white;
        }
        _drawText(
            canvas,
            detailDataList[i],
            detailTextColor,
            Offset(_verticalXList[_verticalXList.length - 1] - _getTextBounds(detailDataList[i]).width - 3,
                _horizontalYList[0] + detailRectHeight / 8 * i));
      }
    } else {
      // left
      Rect leftRect = Rect.fromLTRB(
          _verticalXList[0], _horizontalYList[0], _verticalXList[0] + rectWidth, _horizontalYList[0] + detailRectHeight);
      canvas.drawRect(leftRect, _paint);
      // rect line
      resetPaintStyle(color: scaleLineColor);
      canvas.drawLine(Offset(_verticalXList[0], _horizontalYList[0]),
          Offset(_verticalXList[0], _horizontalYList[0] + detailRectHeight), _paint);
      canvas.drawLine(
          Offset(_verticalXList[0], _horizontalYList[0]), Offset(_verticalXList[0] + rectWidth, _horizontalYList[0]), _paint);
      canvas.drawLine(Offset(_verticalXList[0] + rectWidth, _horizontalYList[0]),
          Offset(_verticalXList[0] + rectWidth, _horizontalYList[0] + detailRectHeight), _paint);
      canvas.drawLine(Offset(_verticalXList[0], _horizontalYList[0] + detailRectHeight),
          Offset(_verticalXList[0] + rectWidth, _horizontalYList[0] + detailRectHeight), _paint);
      // detail title
      double upDownAmount = lastData.closePrice - lastData.openPrice;
      for (int i = 0; i < detailTitleCN.length; i++) {
        _drawText(canvas, detailTitleCN[i], detailTextColor,
            Offset(_verticalXList[0] + 3, _horizontalYList[0] + detailRectHeight / 8 * i));
      }
      // detail data
      for (int i = 0; i < detailDataList.length; i++) {
        if (i == 5 || i == 6) {
          if (upDownAmount > 0) {
            detailTextColor = riseColor;
          } else {
            detailTextColor = fallColor;
          }
        } else {
          detailTextColor = Colors.white;
        }
        _drawText(
            canvas,
            detailDataList[i],
            detailTextColor,
            Offset(_verticalXList[0] + rectWidth - _getTextBounds(detailDataList[i]).width - 3,
                _horizontalYList[0] + detailRectHeight / 8 * i));
      }
    }
  }

  /// draw text
  void _drawText(Canvas canvas, String text, Color textColor, Offset offset) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 10.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  ///draw style
  void resetPaintStyle({required Color color, double strokeWidth = 0, PaintingStyle? paintingStyle}) {
    _paint
      ..color = color
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true
      ..style = paintingStyle ?? PaintingStyle.stroke;
  }

  /// precision
  String setPrecision(double num, int scale) {
    return num.toStringAsFixed(scale);
  }

  String formatDataNum(double num) {
    if (num < 1) {
      return setPrecision(num, 6);
    } else if (num < 10) {
      return setPrecision(num, 5);
    } else if (num < 100) {
      return setPrecision(num, 4);
    } else {
      return setPrecision(num, 2);
    }
  }

  /// date format
  String dateFormat(int timestamp) {
    List<String> dateList = DateTime.fromMillisecondsSinceEpoch(timestamp).toString().split(" ");
    List<String> date = dateList[0].toString().split("-");
    List<String> time = dateList[1].toString().split(":");
    String format = "${date[1]}-${date[2]} ${time[0]}:${time[1]}";
    return format;
  }

  /// size of text
  Size _getTextBounds(String text, {double fontSize = 10}) {
    TextPainter _textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        textDirection: TextDirection.ltr);
    _textPainter.layout();
    return Size(_textPainter.width, _textPainter.height);
  }

  /// dp to px
  double dp2px(double dp) {
    double scale = window.devicePixelRatio;
    return dp * scale;
  }

  double px2dp(double px) {
    double scale = window.devicePixelRatio;
    return px / scale;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
