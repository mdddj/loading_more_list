import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';

import 'package:loading_more_list_library_fast/loading_more_list_library_fast.dart';
import 'package:loading_more_list_library_fast/model/status.dart';
import 'package:provider/provider.dart';

import '../loading_more_list_fast.dart';

//loading more for listview and gridview
class LoadingMoreList<T> extends StatefulWidget {
  const LoadingMoreList(this.listConfig, {Key? key, this.onScrollNotification})
      : super(key: key);
  final ListConfig<T> listConfig;

  /// Called when a ScrollNotification of the appropriate type arrives at this
  /// location in the tree.
  final NotificationListenerCallback<ScrollNotification>? onScrollNotification;

  @override
  State<LoadingMoreList<T>> createState() => _LoadingMoreListState<T>();
}

class _LoadingMoreListState<T> extends State<LoadingMoreList<T>> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final LoadingMoreBase<T> sourceList = widget.listConfig.sourceList;
    final bool useProviderValue = widget.listConfig.useProviderValue;

    final Selector<LoadingMoreBase<T>, IList<T>> child =
        Selector<LoadingMoreBase<T>, IList<T>>(
            builder: (BuildContext context, IList<T> value, Widget? child) {
              return Selector<LoadingMoreBase<T>, IndicatorStatusModel>(
                  builder: (BuildContext context, IndicatorStatusModel value,
                          Widget? child) =>
                      widget.listConfig.buildContent(context, sourceList),
                  selector: (BuildContext p0, LoadingMoreBase<T> p1) =>
                      p1.indicatorStatus);
            },
            selector: (BuildContext p0, LoadingMoreBase<T> p1) => p1.array);
    final ChangeNotifierProvider<LoadingMoreBase<T>> widgetChild = useProviderValue
        ? ChangeNotifierProvider<LoadingMoreBase<T>>.value(
            value: sourceList,
            child: child,
          )
        : ChangeNotifierProvider<LoadingMoreBase<T>>(
            create: (BuildContext context) => sourceList, child: child);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: GlowNotificationWidget(
        widgetChild,
        showGlowLeading: widget.listConfig.showGlowLeading,
        showGlowTrailing: widget.listConfig.showGlowTrailing,
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (widget.onScrollNotification != null) {
      widget.onScrollNotification!(notification);
    }

    if (notification.depth != 0) {
      return false;
    }

    //reach the pixels to loading more
    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent) {
      if (widget.listConfig.hasMore && !widget.listConfig.hasError && !widget.listConfig.isLoading) {
        if (widget.listConfig.sourceList.isEmpty) {
          if (widget.listConfig.autoRefresh) {
            widget.listConfig.sourceList.refresh();
          }
        } else if (widget.listConfig.autoLoadMore) {
          widget.listConfig.sourceList.loadMore();
        }
      }
    }
    return false;
  }

  @override
  bool get wantKeepAlive => true;
}
