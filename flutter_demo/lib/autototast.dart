export 'package:flutter_demo/autototast.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';

typedef _HideCallback = Future Function();
const Color _bgColor = Colors.black87;
const Color _contentColor = Colors.white;
const double _textFontSize = 15.0;
const double _radius = 22;
const int _time = 1;
int backButtonIndex = 2;

class AutoToast {
  static Future showText(
    BuildContext context, {
    @required String msg,
    int closeTime = _time,
  }) {
    return _showToast(
        context: context, msg: msg, stopEvent: true, closeTime: closeTime);
  }

  static Future _showToast({
    @required BuildContext context,
    String msg,
    stopEvent = false,
    int closeTime,
  }) {
    var hide = _showJhToast(context: context, msg: msg, stopEvent: stopEvent);
    return Future.delayed(Duration(seconds: closeTime), hide);
  }

  static _HideCallback _showJhToast({
    @required BuildContext context,
    @required String msg,
    bool stopEvent = false,
  }) {
    Completer<VoidCallback> result = Completer<VoidCallback>();

    var backButtonName = 'JhToast$backButtonIndex';
    BackButtonInterceptor.add((stopDefaultButtonEvent) {
      result.future.then((hide) {
        hide();
      });
      return true;
    }, zIndex: backButtonIndex, name: backButtonName);
    backButtonIndex++;

    var overlay = OverlayEntry(
      maintainState: true,
      builder: (_) => WillPopScope(
        onWillPop: () async {
          var hide = await result.future;
          hide();
          return false;
        },
        child: JhToastWidget(
          msg: msg,
          stopEvent: stopEvent,
        ),
      ),
    );
    result.complete(() {
      if (overlay == null) {
        return;
      }
      overlay.remove();
      overlay = null;
      BackButtonInterceptor.removeByName(backButtonName);
    });
    Overlay.of(context).insert(overlay);
    return () async {
      var hide = await result.future;
      hide();
    };
  }
}

class JhToastWidget extends StatelessWidget {
  const JhToastWidget({
    Key key,
    @required this.msg,
    @required this.stopEvent,
  }) : super(key: key);

  final bool stopEvent;
  final String msg;

  @override
  Widget build(BuildContext context) {
    var widget = Material(
        color: Colors.red,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width - 64,
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(_radius),
              ),
              child: ClipRect(
                child: Wrap(
                  alignment: isExpansion(context, msg)
                      ? WrapAlignment.center
                      : WrapAlignment.start,
                  children: <Widget>[
                    Text(msg,
                        style: TextStyle(
                            fontSize: _textFontSize, color: _contentColor),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            )));
    return IgnorePointer(
      ignoring: !stopEvent,
      child: widget,
    );
  }

  bool isExpansion(BuildContext context, String text) {
    TextPainter _textPainter = TextPainter(
        maxLines: 1,
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: _textFontSize,
          ),
        ),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: MediaQuery.of(context).size.width - 64, minWidth: 50);
    return !_textPainter.didExceedMaxLines;
  }
}
