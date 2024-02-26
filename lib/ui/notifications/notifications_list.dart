import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/notifications_data.dart';
import 'package:sporting_club/data/model/notification.dart' as NotificationItem;
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/delegates/notification_delegate.dart';
import 'package:sporting_club/network/listeners/NotificationsResponseListener.dart';
import 'package:sporting_club/network/repositories/notifications_network.dart';
import 'package:sporting_club/ui/complaints/complaint_details.dart';
import 'package:sporting_club/ui/events/event_details.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/matches/match_details.dart';
import 'package:sporting_club/ui/news/news_details.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart';

import '../sos/screens/sos_details.dart';

class NotificationsList extends StatefulWidget {
  bool fromNotification;

  NotificationsList({this.fromNotification = false});

  @override
  State<StatefulWidget> createState() {
    return NotificationsListState(this.fromNotification);
  }
}

class NotificationsListState extends State<NotificationsList>
    implements
        NotificationsResponseListener,
        NotificationDelegate,
        NoNewrokDelagate {
  bool _isloading = false;
  ScrollController _scrollController = ScrollController();
  bool _isPerformingRequest = false;

  List<NotificationItem.NotificationModel> _notifications = [];
  int _page = 1;

  bool _isNoMoreData = false;
  bool _isNoNetwork = false;
  bool _isNoData = false;
  bool isdelete = false;
  int index_clicked = 0;
  bool fromNotification = false;

  NotificationsNetwork _notificationsNetwork = NotificationsNetwork();
  LocalSettings _localSettings = LocalSettings();

  NotificationsListState(this.fromNotification);

  @override
  void initState() {
    super.initState();

    _notificationsNetwork.getNotifications(_page, true, this);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        _getMoreData();
      }
    });
    _localSettings.setNotificationsCount(0);
    //OneSignal.shared.setNotificationReceivedHandler
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent notification) {
      print("setNotificationReceivedHandler in notifications list");
      // _localSettings.getNotificationsCount().then((count) {
      _localSettings.setNotificationsCount(1);
      //   });
      print('latest count: ' +
          "test" +
          "${_localSettings.getNotificationsCount().then((value) => 0)}");

      _resetData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: Color(0xff43a047),
          child: SafeArea(
            child: Material(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPersistentHeader(
                    delegate: NotificationsListSliverAppBar(
                        expandedHeight: 160,
                        notificationsListState: this,
                        notificationDelegate: this,
                        isnoData: _isNoData,
                        fromNotification: fromNotification),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (_isNoNetwork) {
                          return _buildImageNetworkError();
                        } else if (_isNoData) {
                          return _buildNoData();
                        } else {
                          if (_isNoMoreData) {
                            return _buildNotificationsItem(index);
                          } else {
                            return index == _notifications.length
                                ? _buildProgressIndicator()
                                : _buildNotificationsItem(index);
                          }
                        }
                      },
                      childCount: _isNoData || _isNoNetwork
                          ? 1
                          : _isNoMoreData
                              ? _notifications.length
                              : _notifications.length + 1,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      inAsyncCall: _isloading,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Color.fromRGBO(0, 112, 26, 1),
        valueColor:
            AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
      ),
    );
  }

  Widget _buildNotificationsItem(int index) {
    double width = MediaQuery.of(context).size.width;
    // var index_del = stocks[index];
    // var msg =
    //  _notifications[index].message != null? _notifications[index].message.replaceAll("\\", ""):"";  // strang

    String status = "unread";
    if (_notifications[index].status != null) {
      status = _notifications[index].status ?? "";
    }

    return Slidable(
      key: UniqueKey(), // actionPane: SlidableDrawerActionPane(),
      // actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(
                top: index == 0 ? 25 : 8, right: 15, left: 15, bottom: 8),
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top:  _notifications[index].icon == "doctor_icon"?12: 0),
                    child: Image.asset(
                      _getNotificationIconName(_notifications[index].icon ?? ""),
                      height: _notifications[index].icon == "doctor_icon"?null: 45,
                      fit:  _notifications[index].icon == "doctor_icon"?null: BoxFit.fitHeight,
                    ),
                  ),
                  Container(
                    width: width - 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10, left: 10, top: 5),
                          child: Align(
                            child: _notifications[index].icon == "admin_icon"
                                ? Text(
                                    _notifications[index].message ?? "",
                                    style: TextStyle(
                                        color: Color(0xff646464),
                                        fontWeight: status == "unread"
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 16),
                                  ):
                            _notifications[index].icon == "doctor_icon"
                                ?
                            Text(
                              _notifications[index].sosName ?? "",
                              style: TextStyle(
                                  color: Color(0xff646464),
                                  fontWeight: status == "unread"
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 16),
                            )
                                : Text(
                                    _notifications[index].message ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Color(0xff646464),
                                        fontWeight: status == "unread"
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 16),
                                  ),
                            alignment: Alignment.centerRight,
                          ),
                        ),
                        Align(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: 10, left: 10, top: 12, bottom: 5),
                            child: Text(
                              _notifications[index].date ?? "",
                              style: TextStyle(
                                  color: Color(0xffb6b9c0), fontSize: 14),
                            ),
                          ),
                          alignment: Alignment.bottomRight,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.2),
                    blurRadius: 8.0, // has the effect of softening the shadow
                    spreadRadius: 5.0, // has the effect of extending the shadow
                    offset: Offset(
                      0.0, // horizontal, move right 10
                      0.0, // vertical, move down 10
                    ),
                  ),
                ],
                color: status == "unread"
                    ? Color(0xffFCF4E1)
                    : Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          onTap: () {
            setState(() {
              _notifications[index].status = "read";
              if (_notifications[index].post_id != null) {
                _navigateToDetails(_notifications[index]);
              } else if (_notifications[index].icon == "doctor_icon") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            SOSDetailsScreen(_notifications[index], false)));
              } else {
                showNotificationDetailsDialoug(_notifications[index]);
              }
            });
          },
        ),
      ),
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {}),
        dragDismissible: false,
        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (c) {
              setState(() {
                showLoading();
                index_clicked = index;
                _notificationsNetwork.deleteSpecficNotification(
                    _notifications[index].id, this);
              });
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      // actions: <Widget>[
      //   IconSlideAction(
      //   //  caption: 'Delete',
      //    // color: Colors.red,
      //       iconWidget:  Image.asset('assets/notificcation_ic.png'),
      //
      //      onTap: () {
      //       setState(() {
      //         showLoading();
      //         index_clicked = index;
      //         _notificationsNetwork.deleteSpecficNotification(_notifications[index].id, this);
      //       });
      //      }
      //   ),
      // ],
    );
  }

  String _getNotificationIconName(String type) {
    switch (type) {
      case "team_icon":
        return "assets/results_ic.png";
        break;
      case "new_icon":
        return "assets/news_intersets.png";
        break;
      case "event_icon":
        return "assets/events_ic.png";
        break;
      case "trip_icon":
        return "assets/trips_ic.png";
        break;
      case "admin_icon":
        return "assets/admin_notif_ic.png";
        break;
      case "complaint_icon":
        return "assets/not_complain_ic.png";
        break;
      case "doctor_icon":
        return "assets/emergency_ic.png";
        break;
      default:
        return 'assets/not_complain_ic.png';
        break;
    }
  }

  void showNotificationDetailsDialoug(
      NotificationItem.NotificationModel notification) {
    print('add image click');

    // var title_msg =  "";
    // if( notification.message_title !=null) {
    //   title_msg = notification.message_title;
    //   title_msg =  notification.message_title.replaceAll("\\\"", "\"");
    //   title_msg = title_msg.replaceAll("\\\'", "\'");
    // }

    _notificationsNetwork.setNotificationsSeen(notification.id, this);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: SingleChildScrollView(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Align(
                    child: IconButton(
                      icon: new Image.asset('assets/close_green_ic.png'),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  Container(
                    //width: double.infinity,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(5),

                    padding: EdgeInsets.only(
                        right: 15, left: 20, bottom: 20, top: 20),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      border: new Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                            child: notification.image != null
                                ? notification.image != ""
                                    ? FadeInImage.assetNetwork(
                                        placeholder: 'assets/placeholder_2.png',
                                        image: notification.image ?? "",
                                        height: 250,
                                        width: 300,
                                        fit: BoxFit.cover,
                                      )
                                    : SizedBox()
                                : SizedBox()),
                        notification.message_title != null
                            ? Text(notification.message_title ?? "",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color.fromRGBO(67, 160, 71, 1)))
                            : SizedBox(),
                        SizedBox(
                          height: 10,
                        ),
                        notification.message != null
                            ? Text(notification.message ?? "",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color.fromRGBO(0, 0, 0, 1)))
                            : SizedBox(),

                        SizedBox(
                          height: 10,
                        ),

                        notification.link_data != null
                            ? GestureDetector(
                                child: Text(notification.link_data ?? "",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue)),
                                onTap: () async {
                                  _launchURL(notification.link_data ?? "");
                                })
                            : SizedBox(),

//                GestureDetector(
//                  onTap: () {
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (BuildContext context) =>
//                                UpdateInfoFirstStep(_controller.text)));
//                  },
//                  child: Text(
//                    'يرجى تحديث المعلومات',
//                    style: TextStyle(
//                        color: Color.fromRGBO(67, 160, 71, 1),
//                        fontSize: 15,
//                        fontWeight: FontWeight.w700,
//                        decorationThickness: 2,
//                        decoration: TextDecoration.underline),
//                  ),
//                ),
                      ],
                    ),
                  )
                ]),
              )),
          height: 50,
        );
      },
    );
  }

  void _navigateToDetails(NotificationItem.NotificationModel notification) {
    if (notification.post_id != null) {
      switch (notification.icon) {
        case "team_icon":
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MatchDetails(notification.post_id ?? "", false)));
          break;
        case "new_icon":
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => NewsDetails(
                      int.parse(notification.post_id ?? ""), false)));
          break;
        case "event_icon":
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      EventDetails(notification.post_id ?? "")));
          break;
        case "trip_icon":
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (BuildContext context) =>
          //             TripDetails(
          //               int.parse(notification.post_id??"0"),
          //               null,
          //               false,
          //             )));
          break;
        case "admin_icon":
          print('admin no action');
          break;
        case "complaint_icon":
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ComplaintDetails(int.parse(notification.post_id ?? ""))));
          break;
        case "doctor_icon":
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SOSDetailsScreen(notification, false)));
          break;
        default:
          break;
      }
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: _isPerformingRequest ? 1.0 : 0.0,
          child: new CircularProgressIndicator(
            backgroundColor: Color.fromRGBO(0, 112, 26, 1),
            valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    // const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildImageNetworkError() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
        padding: EdgeInsets.only(top: topPadding), child: NoNetwork(this));
  }

  Widget _buildNoData() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 50;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: NoData('لا توجد اشعارات'),
    );
  }

  void _resetData() {
    print('_resetData');
    _page = 1;
    _notifications.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
    });
    _notificationsNetwork.getNotifications(_page, true, this);
  }

  @override
  void reloadAction() {
    _notificationsNetwork.getNotifications(_page, true, this);
  }

  _getMoreData() async {
    if (!_isNoMoreData) {
      if (!_isPerformingRequest && !_isloading) {
        setState(() => _isPerformingRequest = true);
        _notificationsNetwork.getNotifications(_page, false, this);
      }
    }
  }

  @override
  void hideLoading() {
    setState(() {
      _isloading = false;
      _isPerformingRequest = false;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isloading = true;
    });
  }

  @override
  void showGeneralError() {
    Fluttertoast.showToast(
        msg: "حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(
        msg: "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
  }

  @override
  void showServerError(String? msg) {
    Fluttertoast.showToast(msg: msg ?? "", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void setNotifications(NotificationsData? data) {
    if (_page == 1) {
      _localSettings.setNotificationsCount(0);
      // _notificationsNetwork.setNotificationsSeen(this);
    }
    _page += 1;
    if (data?.notifications != null) {
      if (data?.notifications?.isEmpty ?? true) {
        setState(() {
          _isNoMoreData = true;
        });
      }
      setState(() {
        this._notifications.addAll(data?.notifications ?? []);

        _isPerformingRequest = false;
        _isNoNetwork = false;
      });
      if (this._notifications.isEmpty) {
        _isNoData = true;
      } else {
        _isNoData = false;
      }
    }
  }

  @override
  void showSucessDelete() {
    _notifications.removeAt(index_clicked);
    hideLoading();
    // TODO: implement showSucessDelete
  }

  @override
  void deleteAll() {
    showLoading();
    _notificationsNetwork.deleteAllNotification(this);
    // TODO: implement deleteAll
  }

  @override
  void showSucessDeleteAll() {
    hideLoading();
    _notifications.clear();
    _isNoData = true;
    // TODO: implement showSucessDeleteAll
  }
}

class NotificationsListSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  BuildContext? context;
  NotificationsListState notificationsListState;
  NotificationDelegate notificationDelegate;
  bool isnoData, fromNotification = false;

  NotificationsListSliverAppBar(
      {this.expandedHeight = 0,
      required this.notificationsListState,
      required this.notificationDelegate,
      required this.isnoData,
      required this.fromNotification});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.context = context;
//    print('shrinkOffset: ' + shrinkOffset.toString());
    double width = MediaQuery.of(context).size.width;
    return Stack(fit: StackFit.expand, overflow: Overflow.visible, children: [
      Container(
        color: shrinkOffset < 140 ? Colors.transparent : Color(0xff43a047),
        height: 80,
      ),

      Image.asset(
        "assets/background_category.png",
        fit: shrinkOffset < 140 ? BoxFit.fill : BoxFit.cover,
      ),
      Align(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 0, top: 5),
          child: IconButton(
            icon: new Image.asset('assets/back_white.png'),
            onPressed: () {
              if (fromNotification != null) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Home()),
                    (Route<dynamic> route) => false);
              } else {
                Navigator.of(context).pop(null);
              }
            },
          ),
        ),
        alignment: Alignment.topRight,
      ),

      //]
      //  ),
      Center(
//          height: 100,
        child: Padding(
          padding: EdgeInsets.only(
              right: shrinkOffset > 100 ? 40 : 20,
              bottom: shrinkOffset > 100 ? 0 : 20,
              left: shrinkOffset > 100 ? 100 : 15),
          child: Align(
            child: Text(
              'الاشعارات',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: shrinkOffset > 100 ? 20 : 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            alignment: Alignment.centerRight,
          ),
        ),
      ),
      Visibility(
        visible: !isnoData ? true : false,
        child: GestureDetector(
            onTap: () {
              notificationDelegate.deleteAll();
            },
            child: Center(
//          height: 100,
                child: Padding(
              padding: EdgeInsets.only(
                  right: shrinkOffset > 100 ? 40 : 20,
                  bottom: shrinkOffset > 100 ? 0 : 20,
                  left: shrinkOffset > 100 ? 40 : 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Image.asset(
                    "assets/del_notification.png",
                    width: 20,
                    fit: BoxFit.fitHeight,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  //  Align(
                  //  child:
                  Text(
                    'مسح كل الاشعارات',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w400),
                  ),
                  //    alignment: Alignment.centerRight,
                  //),
                ],
              ),
            ))),
      )
    ]);
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
