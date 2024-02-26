import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/interest.dart';
import 'package:sporting_club/data/model/interests_data.dart';
import 'package:sporting_club/data/model/trips/trips_interests.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/listeners/NotificationsSettingsResponseListener.dart';
import 'package:sporting_club/network/repositories/notifications_network.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_network.dart';

class NotificationsSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotificationsSettingsState();
  }
}

class NotificationsSettingsState extends State<NotificationsSettings>
    implements NotificationsSettingsResponseListener, NoNewrokDelagate {
  bool _willReceive = true;
  bool _hasSound = true;
  bool _isloading = false;

  bool _isWillReceiveAction = true;
  List<Interest> _events = [];
  List<Interest> _teams = [];
  List<Interest> _news = [];
  List<Interest> _trips = [];

  List<Interest> alldata = [];
  bool _isOuterTrips = false;
  bool _isInnerTrips = false;
  bool _from_interst = false;
  int last_index = 0;
  bool _isNoNetwork = false;

  NotificationsNetwork _notificationsNetwork = NotificationsNetwork();
  LocalSettings _localSettings = LocalSettings();

  @override
  void initState() {
    super.initState();
    _setNotificationsSettings();
    _notificationsNetwork.getNotificationInterests(this);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              'ضبط الاشعارات',
            ),
            leading: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          backgroundColor: Color(0xfff9f9f9),
          body: _buildContent(),
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

  Widget _buildContent() {
    if (_isNoNetwork) {
      return _buildImageNetworkError();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildTilte('ضبط'),
          Divider(
            height: 1,
          ),
          Container(
            height: 5,
            color: Colors.white,
          ),
          GestureDetector(
            child: _buildItem('استلام اشعارات', true),
            onTap: () => null,
          ),
          Container(
            height: 5,
            color: Colors.white,
          ),
          Divider(
            height: 1,
          ),
//        Container(
//          height: 5,
//          color: Colors.white,
//        ),
          Visibility(
            child: Flexible(
              child: Padding(
                padding:
                    EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return _buildNotificationItem(index);
                  },
                  itemCount: alldata.length, //_interests.length,
                ),
              ),
            ),
            visible: (_willReceive && alldata.length > 0) ? true : false,
          ),
          Container(
            height: 5,
            color: Colors.white,
          ),
          _buildItem('تفعيل صوت الاشعارات', false),
          Container(
            height: 5,
            color: Colors.white,
          ),
          Divider(
            height: 1,
          ),
        ],
      );
    }
  }

  Widget _buildTilte(String title) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: EdgeInsets.only(top: 15, bottom: 15),
      color: Color(0xfff9f9f9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Align(
            child: Container(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
//              width: width - 40,
            ),
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, bool isWillReceive) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      color: Colors.white,
      padding: EdgeInsets.only(top: 7, bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Align(
              child: Container(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Color(0xff43a047)),
                ),
//              width: width - 80,
              ),
              alignment: Alignment.centerRight,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 25),
            child: Align(
              child: GestureDetector(
                child: Image.asset(
                  isWillReceive
                      ? _willReceive
                          ? 'assets/switch_on_light.png'
                          : 'assets/switch_off_light.png'
                      : _hasSound
                          ? 'assets/switch_on_light.png'
                          : 'assets/switch_off_light.png',
                  width: 45,
//                  height: 25,
                  fit: BoxFit.fitWidth,
                ),
                onTap: () {
                  setState(() {
                    if (isWillReceive) {
                      _isWillReceiveAction = true;
                      print(_isWillReceiveAction);

                      _notificationsNetwork.changeNotificationsStatus(
                          !_willReceive, _hasSound, this);
                    } else {
                      _isWillReceiveAction = false;
                      print(_isWillReceiveAction);
                      _notificationsNetwork.changeNotificationsStatus(
                          _willReceive, !_hasSound, this);
                    }
                  });
                },
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      // color: Colors.white,
      padding: EdgeInsets.only(top: 7, bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: Align(
                child: Container(
                  child: Text(
                    alldata[index].title ?? "",
                    style: TextStyle(fontSize: 16, color: Color(0xff43a047)),
                  ),
//              width: width - 80,
                ),
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 25),
            child: Align(
              child: GestureDetector(
                child: Image.asset(
                  (alldata[index].selected ?? false)
                      ? 'assets/switch_on_light.png'
                      : 'assets/switch_off_light.png',
                  width: 45,
//                  height: 25,
                  fit: BoxFit.fitWidth,
                ),
                onTap: () {
                  setState(() {
                    if (alldata[index].selected ?? false) {
                      alldata[index].selected = false;
                    } else {
                      alldata[index].selected = true;
                    }
                    if (alldata[index].id == "inner") {
                      _isInnerTrips = !_isInnerTrips;
                    } else if (alldata[index].id == "outer") {
                      _isOuterTrips = !_isOuterTrips;
                    }
                    _from_interst = true;
                    last_index = index;
                    _notificationsNetwork.updateInterestsNotification(
                        _getSelectedIds(_teams),
                        _getSelectedIds(_events),
                        _getSelectedIds(_news),
                        _getSelectedTrips(),
                        this);

//                    if (isWillReceive) {
//                      _isWillReceiveAction = true;
//                      _notificationsNetwork.changeNotificationsStatus(
//                          !_willReceive, _hasSound, this);
//                    } else {
//                      _isWillReceiveAction = false;
//                      _notificationsNetwork.changeNotificationsStatus(
//                          _willReceive, !_hasSound, this);
//                    }
                  });
                },
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }

  void _setNotificationsSettings() {
    if (LocalSettings.user?.notification_status != null) {
      setState(() {
        _willReceive =
            LocalSettings.user?.notification_status == "on" ? true : false;
      });
    } else {
      _localSettings.getUser().then((value) {
        setState(() {
          if (value.notification_status != null) {
            _willReceive = value.notification_status == "on" ? true : false;
          }
        });
      });
    }

    if (LocalSettings.user?.notification_sound != null) {
      setState(() {
        _hasSound =
            LocalSettings.user?.notification_sound == "on" ? true : false;
      });
    } else {
      _localSettings.getUser().then((value) {
        setState(() {
          if (value.notification_sound != null) {
            _hasSound = value.notification_sound == "on" ? true : false;
          }
        });
      });
    }
  }

  @override
  void hideLoading() {
    setState(() {
      _isloading = false;
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
    if (_from_interst) {
      errorInterest(last_index);
    }
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(
        msg: "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
    if (_from_interst) {
      errorInterest(last_index);
    }
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
    if (_from_interst) {
      errorInterest(last_index);
    }
  }

  @override
  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
    if (_from_interst) {
      errorInterest(last_index);
    }
  }

  @override
  void showChangeSoundSuccess() {
    // TODO: implement showChangeSoundSuccess
  }

  @override
  void showChangeStatusSuccess() {
    setState(() {
      if (_isWillReceiveAction) {
        _willReceive = !_willReceive;
        _localSettings.getUser().then((value) {
          value.notification_status = _willReceive ? "on" : "off";
          _localSettings.setUser(value);
        });
      } else {
        _hasSound = !_hasSound;
        _localSettings.getUser().then((value) {
          value.notification_sound = _hasSound ? "on" : "off";
          _localSettings.setUser(value);
        });
      }
    });
  }

  Widget _buildImageNetworkError() {
    return Padding(
      padding: EdgeInsets.only(top: 0),
      child: NoNetwork(this),
    );
  }

  @override
  void setInterests(InterestsData? data) {
    setState(() {
      _isNoNetwork = false;
      if (data?.events != null) {
        _events.addAll(data?.events ?? []);
      }
      print(_events.length);

      if (data?.news != null) {
        _news.addAll(data?.news ?? []);
//      _news.removeRange(30, _news.length - 1);
        print(_news.length);

        if (data?.teams != null) {
          _teams.addAll(data?.teams ?? []);
        }
//      _teams.removeRange(30, _teams.length - 1);
        print(_teams.length);

        if (data?.trips != null) {
          for (TripsInterest trip in data?.trips ?? []) {
            if (trip.value != null) {
              if (trip.value == "inner") {
                if (trip.selected != null) {
                  _trips.add(Interest(
                    title: "رحلات داخلية",
                    id: "inner",
                    selected: true,
                  ));
                  _isInnerTrips = true; //trip.selected;

                } else {
                  _trips.add(Interest(
                    title: "رحلات داخلية",
                    id: "inner",
                    selected: false,
                  ));
                  _isInnerTrips = false;
                }
              } else if (trip.value == "outer") {
                if (trip.selected != null) {
                  _trips.add(Interest(
                    title: "رحلات خارجية",
                    id: "outer",
                    selected: true,
                  ));
                  _isOuterTrips = true;
                } else {
                  _trips.add(Interest(
                    title: "رحلات خارجية",
                    id: "outer",
                    selected: false,
                  ));
                  _isOuterTrips = false;
                }
              }
            }
          }
        }

        alldata.addAll(_news);
        alldata.addAll(_events);
        alldata.addAll(_teams);
        alldata.addAll(_trips);
      }
    });
  }

  String _getSelectedIds(List<Interest> values) {
    String ids = "";
    for (Interest value in values) {
      if (value.selected ?? false) {
        ids += "${value.id},";
      }
    }
    if (ids.length > 1) {
      ids = ids.replaceRange(ids.length - 1, ids.length, "");
    }
    print(ids);
    return ids;
  }

  String _getSelectedTrips() {
    String trips = "";
    if (_isOuterTrips && _isInnerTrips) {
      trips = "outer,inner";
    } else if (_isOuterTrips && !_isInnerTrips) {
      trips = "outer";
    } else if (!_isOuterTrips && _isInnerTrips) {
      trips = "inner";
    }
    print("trips" + trips);
    return trips;
  }

  void errorInterest(int index) {
    _from_interst = false;

    if (alldata[index].selected ?? false) {
      alldata[index].selected = false;
    } else {
      alldata[index].selected = true;
    }
    if (alldata[index].id == "inner") {
      _isInnerTrips = !_isInnerTrips;
    } else if (alldata[index].id == "outer") {
      _isOuterTrips = !_isOuterTrips;
    }
  }

  @override
  void showUpdateSuccess() {
    setState(() {
      _isNoNetwork = false;
      _from_interst = false;
    });
    // TODO: implement showUpdateSuccess
  }

  @override
  void reloadAction() {
    _notificationsNetwork.getNotificationInterests(this);

    // TODO: implement reloadAction
  }
}
