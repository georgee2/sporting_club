import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/base/screen_handler.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle.dart';
import 'package:sporting_club/data/model/shuttle_bus/traffic_line.dart';
import 'package:sporting_club/ui/book_shuttle_bus/view_model/traffic_line_viewmodel.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/full_traffic_image.dart';

import 'package:sporting_club/ui/book_shuttle_bus/widgets/shuttle_no_data.dart';

import 'package:provider/provider.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_details.dart';

import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:sporting_club/ui/book_shuttle_bus/view_model/shuttle_details_viewmodel.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/shuttle_no_network.dart';
import 'package:sporting_club/ui/complaints/complaints_list.dart';
import 'package:sporting_club/ui/restaurants/full_image.dart';

import 'my_shuttle_details_screen.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/select_shuttle_package.dart';
import 'package:sporting_club/main.dart';
import 'package:photo_view/photo_view.dart';

class TrafficLineListScreen extends StatefulWidget {
  TrafficLineListScreen();

  @override
  State<StatefulWidget> createState() {
    return TrafficLineListScreenScreenState();
  }
}

class TrafficLineListScreenScreenState extends State<TrafficLineListScreen> {
  TrafficLineListScreenScreenState();

  BuildContext? mProviderContext = global.navigatorKey.currentContext;
  List<TrafficLine> trafficLineList = [];

  @override
  void initState() {
    super.initState();
    getTrafficLineList(reset: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        getTrafficLineList();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getTrafficLineList({bool reset = false}) async {
    try {
      Future.delayed(Duration.zero, () {
        try {
          Provider.of<TrafficLineViewModel>(mProviderContext!, listen: false)
              .getTrafficLineList(reset: reset);
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
    return ChangeNotifierProvider<TrafficLineViewModel>(
        create: (context) => TrafficLineViewModel(ShuttleBusNetwork(), context),
        child: Selector<TrafficLineViewModel, List<TrafficLine>>(
            selector: (_, viewModel) => viewModel.trafficLineList,
            builder: (providerContext, viewModelTrafficLine, child) {
              mProviderContext = providerContext;
              trafficLineList = viewModelTrafficLine;

              return new Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    title: Text(
                      "خطوط شاتل باص",
                      // fontWeight: FontWeight.w700,
                    ),
                    leading: IconButton(
                      icon: new Image.asset('assets/back_white.png'),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ),
                  backgroundColor: Color(0xfff9f9f9),
                  body: ScreenHandler<TrafficLineViewModel>(
                    networkWidget: ShuttleNoNetwork(
                      onTapNoNetwork: () {
                        Provider.of<TrafficLineViewModel>(mProviderContext!,
                                listen: false)
                            .getTrafficLineList(reset: true);
                      },
                    ),
                    noDataWidget: ShuttleNoData(
                      onTapNoData: () {},
                    ),
                    child:
                        trafficLineList.isEmpty ? SizedBox() : _buildContent(),
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
              height: 20,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ComplaintsList()));
              },
              child: Padding(
                padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Text(
                  "لإقتراح خطوط أو محطات جديدة إضغط هنا",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
            SizedBox(
              height: 70,
            ),
          ],
        ),
      ],
    );
  }

  bool hasData = true;

  Widget _buildPackageList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trafficLineList.length,
      itemBuilder: (context, i) {
        return _buildtrafficLineRow(trafficLineList[i]);
      },
    );
  }

  Widget _buildtrafficLineRow(TrafficLine trafficLine) {
    return InkWell(
      onTap: () async {
        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => FullTrafficImage(
                  imageUrl: trafficLine.lineImage ?? "",
                )));
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
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset("assets/bus-route_ic.png"),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  trafficLine.name ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff43a047),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
