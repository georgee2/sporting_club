import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/news.dart';
import 'package:sporting_club/delegates/add_review_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/listeners/NewsDetailsResponseListener.dart';
import 'package:sporting_club/ui/sos/view_model/emergency_categories_viewmodel.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/notification.dart' ;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/main.dart';

import '../../../base/screen_handler.dart';
import '../../../data/model/emergency/emergency_category.dart';
import '../../../data/model/notification.dart';
import '../../../network/repositories/emergency_network.dart';
import '../widgets/emergency_no_data.dart';
import '../widgets/emergency_no_network.dart';

class SOSDetailsScreen extends StatefulWidget {
  bool fromNotification = false;
  NotificationModel notification;

  SOSDetailsScreen(this.notification, this.fromNotification);

  @override
  State<StatefulWidget> createState() {
    return NewsDetailsState();
  }
}

class NewsDetailsState extends State<SOSDetailsScreen> {
  // NewsDetailsState( this.fromNotification);
  BuildContext? mProviderContext = global.navigatorKey.currentContext;

  @override
  void initState() {
    // _newsNetwork.getNewsDetails(_newsID, this);
    super.initState();
    getEmergencyCategoryDetails();
  }

  getEmergencyCategoryDetails() async {
    try {
      Future.delayed(Duration.zero, () {
        try {
          Provider.of<EmergencyCategoriesViewModel>(mProviderContext!,
                  listen: false)
              .getEmergencyCategoryDetails(widget.notification.id);
        } catch (e) {
          print(e.toString());
        }
      });
    } catch (error) {
      print("erroe getShuttleList");
      // _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          bottom: false,
          child: Material(
            child: ChangeNotifierProvider<EmergencyCategoriesViewModel>(
              create: (context) =>
                  EmergencyCategoriesViewModel(EmergencyNetwork(), context),
              child:
              Selector<EmergencyCategoriesViewModel, NotificationModel>(
                  selector: (_, viewModel) => viewModel.sosNotification,
                  builder: (providerContext, _sosNotification, child) {
                    mProviderContext = providerContext;
                    sosNotification = _sosNotification;
                    return
                   CustomScrollView(
                    slivers: [
                      SliverPersistentHeader(
                        delegate: MySliverAppBar(
                            expandedHeight: 230,
                            notification:sosNotification??NotificationModel(),
                            from_branch: widget.fromNotification),
                        pinned: true,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return _buildContent();
                        }, childCount: 1),
                      )
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
      inAsyncCall: false,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 112, 26, 1),
        valueColor:
            AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
      ),
    );
  }
  NotificationModel? sosNotification;
  Widget _buildContent() {
    return
      ScreenHandler<EmergencyCategoriesViewModel>(
          networkWidget: EmergencyNoNetwork(
            onTapNoNetwork: () {
              getEmergencyCategoryDetails();
            },
          ),
          noDataWidget: EmergencyNoData(
            onTapNoData: () {
              getEmergencyCategoryDetails();
            },
          ),
          child: Selector<EmergencyCategoriesViewModel, NotificationModel>(
          selector: (_, viewModel) => viewModel.sosNotification,
          builder: (providerContext, _emergencyCategory, child) {
            mProviderContext = providerContext;
            sosNotification = _emergencyCategory;
            return _emergencyCategory.id==null
                ? SizedBox()
                : _buildSosCategoryDetails();
          }),
    );
  }
  Widget _buildSosCategoryDetails() {
    print("sosNotification.sosAccept ${sosNotification?.sosAccept} ");
    print("sosNotification.sosUnique ${sosNotification?.sosUnique} ");
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 10 , vertical: 20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/directions_ic.png"),
                  Padding(
                    padding: EdgeInsets.only(right: 20, top: 0),
                    child: InkWell(
                      onTap: () async {
                        String location = sosNotification?.location ?? ",";
                        var latitude = location.split(",")[0];
                        var longitude = location.split(",")[1];
                        String googleUrl =
                            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                        if (await canLaunch(googleUrl)) {
                          await launch(googleUrl);
                        } else {
                          throw 'Could not open the map.';
                        }
                      },
                      child: Text(
                        "الاتجاهات",
                        style: TextStyle(
                            color: Color(0xff43A047),
                            fontSize: 17,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 25),
              child: InkWell(
                onTap: () async {
                  if (await launch("tel://${sosNotification?.phone}")) {
                    await launch(sosNotification?.phone ?? "");
                  } else {
                    throw 'Could not open the call.';
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/phone_alt_ic.png"),
                    Padding(
                      padding: EdgeInsets.only(right: 20, top: 0),
                      child: Text(
                        sosNotification?.phone ?? "",
                        style: TextStyle(
                            color: Color(0xffb6b9c0),
                            fontSize: 17,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),

           ( sosNotification?.sosAccept=="not_accept")?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(
                      title: 'انا متوجه للحاله',
                      backgroundColor: Color(0xff43A047),
                      onTap: ()  {
                        Provider.of<EmergencyCategoriesViewModel>(mProviderContext!,
                            listen: false)
                            .acceptSos(
                          sosId: "${sosNotification?.sosId}",
                          uniqueId:  "${sosNotification?.sosUnique}",
                          emergencyCategoryId: widget.notification.id.toString()
                        );

                      }),

                  _buildButton(
                      title: 'غير متاح حاليا',
                      backgroundColor: Color(0xff43A047),
                      onTap: ()  {
                        Provider.of<EmergencyCategoriesViewModel>(mProviderContext!,
                            listen: false)
                            .rejectSos(
                            sosId: "${sosNotification?.sosId}",
                            emergencyCategoryId: widget.notification.id.toString()
                        );
                      })
                ],
              ),
            )


               :SizedBox(),
          ],
        ),
      ),
    );
  }
  Widget _buildButton({title, backgroundColor, onTap}) {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   color: backgroundColor,
      // ),
      child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight:FontWeight.bold,
                      color: backgroundColor,
                  ),
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

}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  NotificationModel notification = NotificationModel();

  BuildContext? context;
  bool from_branch = false;

  MySliverAppBar(
      {this.expandedHeight = 0,
      required this.notification,
      required this.from_branch});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.context = context;
    print('shrinkOffset: ' + shrinkOffset.toString());
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Container(
          color: shrinkOffset < 170 ? Colors.transparent : Color(0xff43a047),
          height: 80,
        ),
        Image.asset(
          "assets/intersection_3.png",
          fit: shrinkOffset < 170 ? BoxFit.fill : BoxFit.cover,
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 0, top: 5),
            child: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          alignment: Alignment.topRight,
        ),
        Center(
//          height: 100,
          child: Padding(
            padding: EdgeInsets.only(
                right: shrinkOffset > 110 ? 40 : 20,
                left: shrinkOffset > 110 ? 100 : 15,
                top: 50),
            child: Align(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.sosName ?? "",
                    maxLines: shrinkOffset > 110 ? 1 : 3,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: shrinkOffset > 110 ? 18 : 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          notification.date ?? "",
                          maxLines: shrinkOffset > 110 ? 1 : 3,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: shrinkOffset > 110 ? 14 : 16,
                            color: Colors.white,
                          ),
                        ),
                        Visibility(
                          child: Opacity(
                            opacity: (1 - shrinkOffset / (expandedHeight)),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: 0, top: 10, left: 0),
                              child: Container(
                                child: _buildCategoryItem(),
                                height: 35,
                              ),
                            ),
                          ),
                          visible: shrinkOffset < 20 ? true : false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              alignment: Alignment.topRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem() {
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 12, left: 12, top: 5),
          height: 35,
          child: Text(
            notification.category ?? "",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Color(0xff76d275),
            ),
            borderRadius: BorderRadius.circular(20),
            color: Color(0xff76d275),
          ),
        ),
        onTap: () {},
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
