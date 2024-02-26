import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sporting_club/base/screen_handler.dart';
import 'package:sporting_club/data/model/swvl/swvl_ride.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/repositories/swvl_rides_network.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/main.dart';
import 'package:sporting_club/ui/swvl/view_model/swvl_line_viewmodel.dart';
import 'package:sporting_club/ui/swvl/widgets/swvl_line_row.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';

class SwvlLineListScreen extends StatefulWidget {
  SwvlLineListScreen();

  @override
  State<StatefulWidget> createState() {
    return SwvlLineListScreenScreenState();
  }
}

class SwvlLineListScreenScreenState extends State<SwvlLineListScreen>
    implements NoNewrokDelagate {
  BuildContext? mProviderContext = global.navigatorKey.currentContext;
  List<Rides> rideLineList = [];

  @override
  void initState() {
    super.initState();
    getSwvlLineList(reset: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        getSwvlLineList();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getSwvlLineList({bool reset = false}) async {
    try {
      Future.delayed(Duration.zero, () {
        try {
          Provider.of<SwvlLineViewModel>(mProviderContext!, listen: false)
              .getSwvlRideList(reset: reset);
        } catch (e) {
          print(e.toString());
        }
      });
    } catch (error) {
      print("erroe getSwvlLineList");
      // _pagingController.error = error;
    }
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SwvlLineViewModel>(
        create: (context) => SwvlLineViewModel(SwvlRidesNetwork(), context),
        child: Selector<SwvlLineViewModel, List<Rides>>(
            selector: (_, viewModel) => viewModel.rideList,
            builder: (providerContext, viewModelTrafficLine, child) {
              mProviderContext = providerContext;
              rideLineList = viewModelTrafficLine;

              return new Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    title: Text(
                    ' تتبع رحلتك',
                    ),
                    leading: IconButton(
                      icon: new Image.asset('assets/back_white.png'),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ),
                  backgroundColor: Color(0xfff9f9f9),
                  body: ScreenHandler<SwvlLineViewModel>(
                    networkWidget: NoNetwork(this),
                    noDataWidget: NoData("لا توجد رحلات"),
                    child: rideLineList.isEmpty ? SizedBox() : _buildContent(),
                  ),
                ),
              );
            }));
  }

  Widget _buildContent() {
    return Stack(
      children: <Widget>[
        ListView(
          controller: _scrollController,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rideLineList.length,
              itemBuilder: (context, i) {
                return SwvlLineRow(rideItem: rideLineList[i]);
              },
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void reloadAction() {
    Provider.of<SwvlLineViewModel>(mProviderContext!, listen: false)
        .getSwvlRideList(reset: true);
  }
}
