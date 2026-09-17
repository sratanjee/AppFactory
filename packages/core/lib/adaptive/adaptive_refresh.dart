import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/material.dart' show RefreshIndicator;
import 'package:flutter/widgets.dart';

class AdaptiveRefreshList extends StatelessWidget {
  const AdaptiveRefreshList({
    required this.onRefresh,
    required this.slivers,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOS) {
      return CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
          ...slivers,
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(slivers: slivers),
    );
  }
}
