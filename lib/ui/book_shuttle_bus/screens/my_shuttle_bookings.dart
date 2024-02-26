import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/base/screen_handler.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/traffic_line_screen.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/full_traffic_image.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/no_shuttle_dialog.dart';

import 'package:sporting_club/ui/book_shuttle_bus/widgets/shuttle_no_data.dart';

import 'package:provider/provider.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_details.dart';

import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:sporting_club/ui/book_shuttle_bus/view_model/shuttle_details_viewmodel.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/shuttle_no_network.dart';
import 'package:sporting_club/ui/swvl/screens/swvl_line_screen.dart';
import 'package:sporting_club/utilities/app_colors.dart';

import 'my_shuttle_details_screen.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/select_shuttle_package.dart';
import 'package:sporting_club/main.dart';

class MyShuttleBookingsScreen extends StatefulWidget {
  MyShuttleBookingsScreen();

  @override
  State<StatefulWidget> createState() {
    return MyShuttleBookingsScreenState();
  }
}

class MyShuttleBookingsScreenState extends State<MyShuttleBookingsScreen> {
  MyShuttleBookingsScreenState();

  BuildContext? mProviderContext = global.navigatorKey.currentContext;
  List<Shuttle> shuttleList = [];
  int _page = 1;

  @override
  void initState() {
    super.initState();
    getShuttleList(_page);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        if (shuttleList.length <
            Provider.of<ShuttleDetailsViewModel>(mProviderContext!,
                    listen: false)
                .bookingTotal) {
          _page += 1;
          getShuttleList(_page);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getShuttleList(int pageKey) async {
    try {
      Future.delayed(Duration.zero, () {
        try {
          Provider.of<ShuttleDetailsViewModel>(mProviderContext!, listen: false)
              .getShuttleList(pageKey);
        } catch (e) {
          print(e.toString());
        }
      });
    } catch (error) {
      print("erroe getShuttleList");
      // _pagingController.error = error;
    }
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShuttleDetailsViewModel>(
        create: (context) =>
            ShuttleDetailsViewModel(ShuttleBusNetwork(), context),
        child: Selector<ShuttleDetailsViewModel, List<Shuttle>>(
            selector: (_, viewModel) => viewModel.shuttleList,
            builder: (providerContext, viewModelShuttleData, child) {
              mProviderContext = providerContext;
              shuttleList.addAll(viewModelShuttleData);

              return new Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    title: Text(
                      "شاتل باص",
                      // fontWeight: FontWeight.w700,
                    ),
                    leading: IconButton(
                      icon: new Image.asset('assets/back_white.png'),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ),
                  backgroundColor: Color(0xfff9f9f9),
                  body: ScreenHandler<ShuttleDetailsViewModel>(
                    networkWidget: ShuttleNoNetwork(
                      onTapNoNetwork: () {
                        Provider.of<ShuttleDetailsViewModel>(mProviderContext!,
                                listen: false)
                            .getShuttleList(_page);
                      },
                    ),
                    noDataWidget: ShuttleNoData(
                        onTapNoData: () {
                          _navigateToNextAction();
                        },
                        showBusLine: true),
                    child: shuttleList.isEmpty ? SizedBox() : _buildContent(),
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
            _buildPackageList(),
            SizedBox(
              height: 100,
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildFooter(),
        )
      ],
    );
  }

  bool hasData = true;

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      color: AppColors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButton(
              title: "خطوط السير \nو المواعيد",
              icon: Image.asset(
                "assets/shuttle_ic.png",
                width: 25,
                height: 25,
              ),
              backgroundColor: Color(0xff29902d),
              onTap: () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            TrafficLineListScreen()));
              }),
          _buildButton(
              title: "قائمة\n الأسعار",
              icon: Icon(
                Icons.article_outlined,
                color: Colors.white,
              ),
              backgroundColor: AppColors.lightGreen,
              onTap: () async {
                Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) =>
                        FullTrafficImage(
                          imageUrl: "assets/shuttle_bus_prices.png",
                        )));
              }),
          _buildButton(
              title: 'حجز \n شاتل باص',
              icon: Icon(Icons.add, color: Colors.white),
              backgroundColor: Color(0xffff5c46),
              onTap: () async {
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            SelectShuttleBusPackageScreen()));
                if (result != null) {
                  getShuttleList(0);
                }
              }),
          _buildButton(
              title: ' تتبع\n رحلتك',
              icon: Image.asset(
                "assets/route_ic.png",
                fit: BoxFit.contain,
                width: 25,
                height: 25,
              ),
              backgroundColor: Color(0xfff5143b),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            SwvlLineListScreen()));
              }),
        ],
      ),
    );
  }

  Widget _buildButton({title, backgroundColor, icon, onTap}) {
    return Container(
      width: MediaQuery.of(context).size.width / 4.2,
      child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // height: 50,
                  padding: EdgeInsets.all(10),
                  child: icon,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: backgroundColor,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: backgroundColor),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          onTap: () {
            onTap();
          }),
    );
  }

  Widget _buildPackageList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shuttleList.length,
      itemBuilder: (context, i) {
        return _buildPackageListRow(shuttleList[i]);
      },
    )
        //   whenEmptyLoad: false,
        //   delegate: DefaultLoadMoreDelegate(),
        //   textBuilder: DefaultLoadMoreTextBuilder.english,
        // ),
        ;
  }

  Widget _buildPackageListRow(Shuttle shuttle) {
    return InkWell(
      onTap: () async {
        var result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ShuttleDetailsScreen(
                  suttleId: shuttle.id.toString(),
                )));
        if (result != null) {
          getShuttleList(0);
        }
      },
      child: new Container(
        margin: EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.2),
              blurRadius: 8.0,
              // has the effect of softening the shadow
              spreadRadius: 5.0,
              // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 0),
                child: Text(
                  shuttle.name ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff43a047),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Text(
                      "رقم الحجز",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff43a047),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      shuttle.bookingId ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                      size: 15,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      shuttle.date ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  Future<void> _navigateToNextAction() async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                SelectShuttleBusPackageScreen()));
    if (result != null) {
      getShuttleList(0);
    }
  }
}
