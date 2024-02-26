import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'base_view_model.dart';
import 'common/widgets/app_loader.dart';

class ScreenHandler<T extends BaseViewModel> extends StatelessWidget {
  // final T viewModel;
  final Widget? child;
  final Widget? networkWidget;
  final Widget? noDataWidget;
  final void Function()? onTapNoNetwork;
  final bool hasBack;
  const ScreenHandler({Key? key, this.child, this.networkWidget, this.onTapNoNetwork , this.noDataWidget, this.hasBack=false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Selector<T, bool>(
            builder: (context, noConnection, _) {
              return noConnection ? Container() : child ?? Container();
            },
            selector: (_, viewModel) => viewModel.noConnection),
        Selector<T, bool>(
            child: AppLoader(),
            builder: (context, isLoading, appLoader) {
              return isLoading ? appLoader??SizedBox(): SizedBox();
            },
            selector: (_, viewModel) => viewModel.isLoading),
        Selector<T, bool>(
            child: networkWidget
            ,
            builder: (context, noConnection, appNoConnection) {
              return noConnection ? appNoConnection??SizedBox() : SizedBox();
            },
            selector: (_, viewModel) => viewModel.noConnection),

        Selector<T, bool>(
            child: noDataWidget
            ,
            builder: (context, noData, appNoData) {
              return (noData) ? (appNoData??SizedBox()) : SizedBox();
            },
            selector: (_, viewModel) => viewModel.noData)
      ],
    );
  }
}
