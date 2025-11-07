import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list_library_fast/model/status.dart';

import '../loading_more_list_fast.dart';

class IndicatorWidget extends StatelessWidget {
  const IndicatorWidget(
    this.status, {
    this.tryAgain,
    this.text,
    this.backgroundColor,
    this.isSliver = false,
    this.emptyWidget,
  });

  ///Status of indicator
  final IndicatorStatusModel status;

  ///call back of loading failed
  final Function? tryAgain;

  ///text to show
  final String? text;

  ///background color
  final Color? backgroundColor;

  ///whether it need sliver as container
  final bool isSliver;

  ///emppty widget
  final Widget? emptyWidget;
  @override
  @override
  Widget build(BuildContext context) {

    Widget widget = const SizedBox.shrink();
    switch(status){
      case IndicatorStatusModelWithNone():
        widget = Container(height: 0.0);
        break;
      case IndicatorStatusModelWithEmpty():
        Widget  w = EmptyWidget(
          text ?? 'nothing here',
          emptyWidget: emptyWidget,
        );
        w = _setbackground(true, w, double.infinity);
        if (isSliver) {
          w = SliverFillRemaining(
            child: w,
          );
        } else {
          w = CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: w,
              )
            ],
          );
        }
        widget = w;
        break;
      case IndicatorStatusModelWithLoadingMoreBusying():
        Widget w = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 5.0),
              height: 15.0,
              width: 15.0,
              child: getIndicator(context),
            ),
            Text(text ?? 'loading...')
          ],
        );
        w = _setbackground(false, w, 35.0);
        widget = w;
        break;
      case IndicatorStatusModelWithFullScreenBusying():
        Widget w = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 0.0),
              height: 30.0,
              width: 30.0,
              child: getIndicator(context),
            ),
            Text(text ?? 'loading...')
          ],
        );
        w = _setbackground(true, w, double.infinity);
        if (isSliver) {
          w = SliverFillRemaining(
            child: w,
          );
        } else {
          w = CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: w,
              )
            ],
          );
        }
        widget = w;
        break;
      case IndicatorStatusModelWithError():
        Widget  w = Text(
          text ?? 'load failed,try again.',
        );
        w = _setbackground(false, w, 35.0);
        if (tryAgain != null) {
          w = GestureDetector(
            onTap: () {
              tryAgain!();
            },
            child: w,
          );
        }
        widget = w;
        break;
      case IndicatorStatusModelWithFullScreenError():
        Widget w = Text(
          text ?? 'load failed,try again.',
        );
        w = _setbackground(true, w, double.infinity);
        if (tryAgain != null) {
          w = GestureDetector(
            onTap: () {
              tryAgain!();
            },
            child: w,
          );
        }
        if (isSliver) {
          w = SliverFillRemaining(
            child: w,
          );
        } else {
          w = CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: w,
              )
            ],
          );
        }
        widget = w;
        break;
      case IndicatorStatusModelWithNoMoreLoad():
        Widget w = Text(text ?? 'No more items.');
        w = _setbackground(false, w, 35.0);
        widget = w;
        break;
    }
    return widget;
  }

  Widget _setbackground(bool full, Widget widget, double height) {
    widget = Container(
        width: double.infinity,
        height: height,
        child: widget,
        color: backgroundColor ?? Colors.grey[200],
        alignment: Alignment.center);
    return widget;
  }

  Widget getIndicator(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.platform == TargetPlatform.iOS
        ? const CupertinoActivityIndicator(
            animating: true,
            radius: 16.0,
          )
        : CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          );
  }
}
