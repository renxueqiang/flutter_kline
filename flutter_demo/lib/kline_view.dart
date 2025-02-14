import 'dart:math';
import 'package:flutter/material.dart';
import 'chart_model.dart';
import 'chart_painter.dart';
import 'chart_utils.dart';

class KlineView extends StatefulWidget {
  const KlineView(
      {super.key,
      required this.dataList,
      this.isShowSubview = false,
      this.viewType = 0,
      this.subviewType = 0,
      this.currentDataType = ''});

  final List<ChartModel> dataList;
  final bool isShowSubview;
  final int viewType;
  final int subviewType;
  final String currentDataType;

  @override
  State createState() => _KlineViewState();
}

class _KlineViewState extends State<KlineView> {
  int _startDataNum = 0;
  int _maxViewDataNum = 50;
  final int _viewDataMin = 10;
  final int _viewDataMax = 100;
  double _velocityX = 0;
  bool _isShowDetail = false;
  ChartModel? _lastData;
  final ChartUtils _chartUtils = ChartUtils();
  final List<ChartModel> _totalDataList = [];
  final List<ChartModel> _viewDataList = [];
  final List<String> _detailDataList = [];

  @override
  void initState() {
    super.initState();
    initDataList();
  }

  void initDataList() {
    _totalDataList.clear();
    _totalDataList.addAll(widget.dataList);
    _startDataNum = _totalDataList.length - _maxViewDataNum;
    setState(() {
      _resetViewData();
    });
  }

  void _resetViewData() {
    _viewDataList.clear();
    int currentViewDataNum = min(_maxViewDataNum, _totalDataList.length);
    if (_startDataNum >= 0) {
      for (int i = 0; i < currentViewDataNum; i++) {
        if (i + _startDataNum < _totalDataList.length) {
          _viewDataList.add(_totalDataList[i + _startDataNum]);
        }
      }
    } else {
      for (int i = 0; i < currentViewDataNum; i++) {
        _viewDataList.add(_totalDataList[i]);
      }
    }
    if (_viewDataList.isNotEmpty && !_isShowDetail) {
      _lastData = _viewDataList[_viewDataList.length - 1];
    } else if (_viewDataList.isEmpty) {
      _lastData = null;
    }
  }

  void _getClickData(double clickX) {
    if (_isShowDetail) {
      _detailDataList.clear();
      for (int i = 0; i < _viewDataList.length; i++) {
        if (_viewDataList[i].leftStartX <= clickX && _viewDataList[i].rightEndX >= clickX) {
          _lastData = _viewDataList[i];
          _detailDataList.add(_chartUtils.dateFormat(_lastData!.timestamp, year: true));
          _detailDataList.add(_lastData!.openPrice.toString());
          _detailDataList.add(_lastData!.maxPrice.toString());
          _detailDataList.add(_lastData!.closePrice.toString());
          _detailDataList.add(_lastData!.minPrice.toString());
          double upDownAmount = _lastData!.closePrice - _lastData!.openPrice;
          String upDownRate = _chartUtils.setPrecision(upDownAmount / _lastData!.openPrice * 100, 2);
          if (upDownAmount > 0) {
            _detailDataList.add("+${_chartUtils.formatDataNum(upDownAmount)}");
            _detailDataList.add("+$upDownRate%");
          } else {
            _detailDataList.add(_chartUtils.formatDataNum(upDownAmount));
            _detailDataList.add("$upDownRate%");
          }
          _detailDataList.add(_chartUtils.formatDataNum(_lastData!.volume));
          break;
        } else {
          _lastData = null;
        }
      }
    } else {
      _lastData = _viewDataList[_viewDataList.length - 1];
    }
  }

  void _onTapDown(TapDownDetails details) {
    print('--------_onTapDown----------');
    double moveX = details.globalPosition.dx;
    if (_viewDataList[0].leftStartX <= moveX && _viewDataList[_viewDataList.length - 1].rightEndX >= moveX) {
      setState(() {
        _isShowDetail = true;
        _getClickData(moveX);
      });
    }
  }

  void _onLongPress(LongPressMoveUpdateDetails details) {
    print('--------_onLongPress----------');

    double moveX = details.globalPosition.dx;
    if (_viewDataList[0].leftStartX <= moveX && _viewDataList[_viewDataList.length - 1].rightEndX >= moveX) {
      setState(() {
        _isShowDetail = true;
        _getClickData(moveX);
      });
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    print('--------_onScaleUpdate----------${details.scale}');

    if (details.scale > 1) {
      if (_maxViewDataNum <= _viewDataMin) {
        _maxViewDataNum = _viewDataMin;
      } else if (_viewDataList.length < _maxViewDataNum) {
        _maxViewDataNum -= 2;
        _startDataNum = _totalDataList.length - _maxViewDataNum;
      } else {
        _maxViewDataNum -= 2;
        _startDataNum += 1;
      }
    } else if (details.scale < 1) {
      if (_maxViewDataNum >= _viewDataMax) {
        _maxViewDataNum = _viewDataMax;
      } else if (_startDataNum + _maxViewDataNum >= _totalDataList.length) {
        _maxViewDataNum += 2;
        _startDataNum = _totalDataList.length - _maxViewDataNum;
      } else if (_startDataNum <= 0) {
        _startDataNum = 0;
        _maxViewDataNum += 2;
      } else {
        _maxViewDataNum += 2;
        _startDataNum -= 1;
      }
    }
    setState(() {
      _isShowDetail = false;
      _resetViewData();
    });
  }

  void _moveHorizontal(DragUpdateDetails details) {
    double _distanceX = details.delta.dx * -1;
    print('--------_moveHorizontal----------:$_distanceX');

    if ((_startDataNum == 0 && _distanceX < 0) ||
        (_startDataNum == _totalDataList.length - _maxViewDataNum && _distanceX > 0) ||
        _startDataNum < 0 ||
        _viewDataList.length < _maxViewDataNum) {
      if (_isShowDetail) {
        setState(() {
          _isShowDetail = false;
          if (_viewDataList.isNotEmpty) {
            _lastData = _viewDataList[_viewDataList.length - 1];
          }
        });
      }
    } else {
      setState(() {
        _isShowDetail = false;
        if (_distanceX.abs() > 1) {
          _moveData(_distanceX);
        }
      });
    }
  }

  void _moveData(double distanceX) {
    if (_maxViewDataNum < 50) {
      _setSpeed(distanceX, 10);
    } else {
      _setSpeed(distanceX, 3.5);
    }
    if (_startDataNum < 0) {
      _startDataNum = 0;
    }
    if (_startDataNum > _totalDataList.length - _maxViewDataNum) {
      _startDataNum = _totalDataList.length - _maxViewDataNum;
    }
    _resetViewData();
  }

  /// move speed
  void _setSpeed(double distanceX, double num) {
    if (distanceX.abs() > 1 && distanceX.abs() < 2) {
      _startDataNum += (distanceX * 10 - (distanceX * 10 ~/ 2) * 2).round();
    } else if (distanceX.abs() < 10) {
      _startDataNum += (distanceX - (distanceX ~/ 2) * 2).toInt();
    } else {
      _startDataNum += distanceX ~/ num;
    }
    print('------------->$_startDataNum');
  }

  /// move velocity
  void _moveVelocity(DragEndDetails details) {
    print('--------_moveVelocity----------');

    if (_startDataNum > 0 && _startDataNum < _totalDataList.length - _maxViewDataNum) {
      if (details.velocity.pixelsPerSecond.dx > 6000) {
        _velocityX = 8000;
      } else if (details.velocity.pixelsPerSecond.dx < -6000) {
        _velocityX = -8000;
      } else {
        _velocityX = details.velocity.pixelsPerSecond.dx;
      }
      _moveAnimation();
    }
  }

  /// move animation
  void _moveAnimation() {
    if (_velocityX < -200) {
      if (_velocityX < -6000) {
        _startDataNum += 6;
      } else if (_velocityX < -4000) {
        _startDataNum += 5;
      } else if (_velocityX < -2500) {
        _startDataNum += 4;
      } else if (_velocityX < -1000) {
        _startDataNum += 3;
      } else {
        _startDataNum++;
      }
      _velocityX += 200;
      if (_startDataNum > _totalDataList.length - _maxViewDataNum) {
        _startDataNum = _totalDataList.length - _maxViewDataNum;
      }
    } else if (_velocityX > 200) {
      if (_velocityX > 6000) {
        _startDataNum -= 6;
      } else if (_velocityX > 4000) {
        _startDataNum -= 5;
      } else if (_velocityX > 2500) {
        _startDataNum -= 4;
      } else if (_velocityX > 1000) {
        _startDataNum -= 3;
      } else {
        _startDataNum--;
      }
      _velocityX -= 200;
      if (_startDataNum < 0) {
        _startDataNum = 0;
      }
    }
    setState(() {
      _resetViewData();
    });
    if (_velocityX.abs() > 200) {
      Future.delayed(const Duration(milliseconds: 15), () => _moveAnimation());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onLongPressMoveUpdate: _onLongPress,
      onHorizontalDragUpdate: _moveHorizontal,
      onHorizontalDragEnd: _moveVelocity,
      onScaleUpdate: _onScaleUpdate,
      child: Container(
          // color: Colors.orange[100],
          width: MediaQuery.of(context).size.width,
          height: 368.0,
          child: CustomPaint(
            painter: ChartPainter(
              viewDataList: _viewDataList,
              maxViewDataNum: _maxViewDataNum,
              lastData: _lastData ?? ChartModel(0, 0, 0, 0, 0, 0),
              detailDataList: _detailDataList,
              isShowDetails: _isShowDetail,
              isShowSubview: widget.isShowSubview,
              viewType: widget.viewType,
              subviewType: widget.subviewType,
            ),
          )),
    );
  }
}
