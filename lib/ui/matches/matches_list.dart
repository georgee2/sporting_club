import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/team.dart';
import 'package:sporting_club/data/model/teams_data.dart';
import 'package:sporting_club/delegates/interests_delegate.dart';
import 'package:sporting_club/delegates/news_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/MatchesResponseListener.dart';
import 'package:sporting_club/network/repositories/matches_network.dart';
import 'package:sporting_club/ui/interests/interests.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/search/search.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'match_details.dart';

class MatchesList extends StatefulWidget {
  bool isShowMyMatchesOnly = false;
  MatchesList(this.isShowMyMatchesOnly);
  @override
  State<StatefulWidget> createState() {
    return MatchesListState(this.isShowMyMatchesOnly);
  }
}

class MatchesListState extends State<MatchesList>
    implements NoNewrokDelagate, MatchesResponseListener, InterestsDeleagte ,NewsDeleagte{
  bool _isloading = false;
  bool _isMyMatches = true;

  MatchesNetwork _matchesNetwork = MatchesNetwork();
  Validation _validation = Validation();
  List<Team> _teams = [];

  bool _isNoNetwork = false;
  bool _isNoData = false;
  bool _isNoInterest = false;

  //0 for yesterday .. 1 for today .. 2 for tomorrow
  int _selectedDay = 1;
  int _selectedMyDay = 1;

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer;
  bool isShowMyMatchesOnly =false;

  MatchesListState(this.isShowMyMatchesOnly);

  @override
  void initState() {
    List<String> list = LocalSettings.interests??[];
//    if (!list.contains('teams')) {
//      _isMyMatches = false;
//    }

    _isMyMatches = isShowMyMatchesOnly;

    if (_isMyMatches) {
      _matchesNetwork.getInterestsMatches(_getDayType(), this);
    } else {
      _matchesNetwork.getMatches(_getDayType(), this);
    }
    LocalSettings.link = "";
    super.initState();
    if (ApiUrls.RELEASE_MODE) {
      _sendAnalyticsEvent();
    }
    _getAds();
    OneSignal.shared
        .setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent  notification) {
      print("setNotificationReceivedHandler in matches service ");
      LocalSettings.notificationsCount =  1;

      setState(() {

      });
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
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
                slivers: [
                  SliverPersistentHeader(
                    delegate: MatchesListSliverAppBar(
                        expandedHeight: 200, matchesList: this,isShowMyMatchesOnly: isShowMyMatchesOnly,newsDeleagte: this),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (_isNoNetwork) {
                          return _buildImageNetworkError();
                        } else if (_isNoData) {
                          return _buildNoData();
                        } else if (_isMyMatches && _isNoInterest) {
                          print('build _isNoInterest');
                          return _buildNoInterests();
                        } else {
                          return _buildSportItem(index);
                        }
                      },
                      childCount: _isNoData ||
                              _isNoNetwork ||
                              (_isMyMatches && _isNoInterest)
                          ? 1
                          : _teams.length,
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

  Widget _buildSportItem(int teamIndex) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Text(
          _teams[teamIndex].name?? "",
          style: TextStyle(
              color: Color(0xff646464),
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (teamIndex == 0) {
              return _getViewedItem(index, _teams[teamIndex]);
            } else {
              return _buildMatchItem(index, _teams[teamIndex]);
            }
          },
          itemCount: _teams[teamIndex].matches != null
              ? teamIndex == 0
                  ? (_teams[teamIndex].matches?.length??0) + 1
                  :( _teams[teamIndex].matches?.length??0)
              : 0,
        )
      ],
    );
  }

  Widget _buildMatchItem(int index, Team team) {
    double width = MediaQuery.of(context).size.width - 20;

    //get time of match
    String clock = "";
    String time = "";
    if (team.matches?[index].time != null) {
      String a = team.matches?[index].time??"";
      var ab = (a.split(' '));
      if (ab.length == 2) {
        print(ab[0]);
        print(ab[1]);
        clock = ab[0];
        time = ab[1];
      }
    }

    //get match result
    String result = "";
    if (team.matches?[index].home_points != null) {
      if (_validation.isNumeric(team.matches?[index].home_points??"0")) {
        if (team.matches?[index].away_points != null) {
          result = "${team.matches?[index].home_points} - ${team.matches?[index].away_points}";

        }
      } else {
        result = team.matches?[index].home_points??"0";
      }
    }

    return GestureDetector(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              right: 10, left: 10, top: index == 0 ? 10 : 5, bottom: 10),
          child: Container(
//            height: 110,
            padding: EdgeInsets.only(bottom: 10),
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
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Image.asset(
                          'assets/sporting_club_logo.png',
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        Text(
                          team.matches?[index].home_team ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  width: width / 3,
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        result,
                        style: TextStyle(
                            color: Color(0xff43a047),
                            fontSize: result.contains(' - ') ? 16 : 14,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            time + ' ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            clock,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: result.contains(' - ') ? 5 : 7,
                      ),
                      Center(
                        child: Text(
                          team.matches?[index].location ??"",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xffa70000),
                            fontSize: 14,

                          ),
                        ),
                      ),
                    ],
                  ),
                  width: width / 3,
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        team.matches?[index].away_logo != null
                            ? (team.matches?[index].away_logo??"" )!= ""
                                ? FadeInImage.assetNetwork(
                                    placeholder: 'assets/team_ic.png',
                                    image: team.matches?[index].away_logo??"",
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.fitWidth,
                                  )
                                : Image.asset(
                                    'assets/team_ic.png',
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  )
                            : Image.asset(
                                'assets/team_ic.png',
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                        SizedBox(
                          height: 0,
                        ),
                        Text(
                          team.matches?[index].away_team ??"",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  width: width / 3,
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  MatchDetails(team.matches?[index].id??"0",false))),
    );
  }

  Widget _buildNoData() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 50;
    }

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: NoData(_getNoDataText()),
    );
  }

  Widget _buildNoInterests() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
//          Image.asset('assets/eye-close-line.png'),
            Text(
              'حدد الفرق المفضلة من هنا',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Container(
                height: 50,
                padding:
                    EdgeInsets.only(bottom: 5, right: 20, left: 20, top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.2),
                      blurRadius: 8.0, // has the effect of softening the shadow
                      spreadRadius:
                          5.0, // has the effect of extending the shadow
                      offset: Offset(
                        0.0, // horizontal, move right 10
                        0.0, // vertical, move down 10
                      ),
                    ),
                  ],
                  color: Color(0xffff5c46),
                ),
                child: Text(
                  'اختار فرقك المفضلة',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          Interests(true, this, 1, updateInterestsNow: true,))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageNetworkError() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: NoNetwork(this),
    );
  }

  Widget _buildMatchesFilteration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildDayItem('أمس', 0),
        _buildDayItem('اليوم', 1),
        _buildDayItem('غداً', 2),
      ],
    );
  }

  Widget _buildDayItem(String title, int index) {
    return Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 15, left: 15),
          height: 35,
          width: 71,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: _isMyMatches
                    ? _selectedMyDay == index ? Colors.white : Color(0xffb1e6b1)
                    : _selectedDay == index ? Colors.white : Color(0xffb1e6b1),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: _isMyMatches
                  ? _selectedMyDay == index
                      ? Color(0xff43a047)
                      : Color(0xff76d275)
                  : _selectedDay == index
                      ? Color(0xff43a047)
                      : Color(0xff76d275),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _isMyMatches
                ? _selectedMyDay == index
                    ? Color(0xff43a047)
                    : Color(0xff5AB75C)
                : _selectedDay == index ? Color(0xff43a047) : Color(0xff5AB75C),
          ),
        ),
        onTap: () {
          setState(() {
            _isMyMatches ? _selectedMyDay = index : _selectedDay = index;
            _resetMatchesData();
          });
        },
      ),
    );
  }

  Widget _buildAdsView() {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, top: 5, bottom: 5),
      child: GestureDetector(
        child: Container(
          child: ( ads?[0].images?.length??0) > 0
              ? Image.network(
                  ads?[0].images?[viewedAdvIndex].large??"",
                  fit: BoxFit.cover,
                )
              : SizedBox(),
         // height: 75,
         //  width: width - 30,
        ),
        onTap: () => _adsAction(),
      ),
    );
  }

  Widget _getViewedItem(int index, Team team) {
    if ((team.matches?.length??0) >= 2) {
      if (index < 2) {
        return _buildMatchItem(index, team); //before 2 so events item
      } else if (index == 2) {
        return ads != null ? _buildAdsView() : SizedBox();
      } else {
        return _buildMatchItem(index - 1, team); //build events items after ads
      }
    } else {
      //less than 2 items
      if (index == (team.matches?.length??0)) {
        //ads
        return ads != null ? _buildAdsView() : SizedBox();
      } else {
        return _buildMatchItem(index, team);
      }
    }
  }

  void _adsAction() async {
    //log ads action event
    if (ads?.isNotEmpty??false) {
      if (ApiUrls.RELEASE_MODE) {
        if (ads?[0].images?[viewedAdvIndex].title != null) {
          if (ads?[0].images?[viewedAdvIndex].title?.isNotEmpty??false) {
            FirebaseAnalytics analytics = FirebaseAnalytics.instance;
            analytics.logEvent(
              name: 'advertisements',
              parameters: <String, String>{
                'ad_name': ads?[0].images?[viewedAdvIndex].title??"",
              },
            );
          }
        }
      }
      if (ads?[0].images?[viewedAdvIndex].link != null) {
        if (await UrlLauncher.canLaunch(ads?[0].images?[viewedAdvIndex].link??"")) {
          await UrlLauncher.launch(ads?[0].images?[viewedAdvIndex].link??"");
        } else {
          print("can't launch");
        }
      }
    }
  }

  void _getAds() {
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads = LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty??false) {
        for (AdvertisementData adv in ads??[]){
          if (adv.name == "list_matches") {
            setState(() {
              if (adv.data?.isNotEmpty??false) {
                if (adv.data?[0].date_from != null &&
                    adv.data?[0].date_to != null) {
                  _checkAdsTime(adv) ? this.ads = adv.data : this.ads = null;
                  _setAdsTimer();
                } else {
                  this.ads = adv.data;
                  _setAdsTimer();
                }
              }
            });
            break;
          }
        }
      }
    }
  }

  void _setAdsTimer() {
    int duration = 3;
    if (ads != null) {
      if (ads?[0].image_duration != null) {
        duration = int.parse(ads?[0].image_duration??"0");
      }
      _timer = Timer.periodic(new Duration(seconds: duration), (timer) {
        if ((ads?[0].images?.length??0) - 1 > viewedAdvIndex) {
          setState(() {
            viewedAdvIndex += 1;
          });
        } else {
          setState(() {
            viewedAdvIndex = 0;
          });
        }
      });
    }
  }

  bool _checkAdsTime(AdvertisementData adv) {
    final startTime = DateTime.parse(adv.data?[0].date_from??"2000-01-01");

    final endTime = DateTime.parse(adv.data?[0].date_to??"2000-01-01");

    final currentTime = DateTime.now();

    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      // do something
      print('valid date');
      return true;
    } else {
      return false;
    }
  }

  void _changeMatchesSelection(bool isMyMatches) {
    setState(() {
      _isMyMatches = isMyMatches;
      _resetMatchesData();
    });
  }

  void _resetMatchesData() {
    print('_resetMatchesData');
    _teams.clear();
    if (_isMyMatches) {
      _matchesNetwork.getInterestsMatches(_getDayType(), this);
    } else {
      _matchesNetwork.getMatches(_getDayType(), this);
    }
  }

  String _getNoDataText() {
    int selectedDay = 0;
    if (_isMyMatches) {
      selectedDay = this._selectedMyDay;
    } else {
      selectedDay = this._selectedDay;
    }

    switch (selectedDay) {
      case 0:
        return 'لا توجد مباريات بالأمس';
        break;
      case 1:
        return 'لا توجد مباريات اليوم';
        break;
      case 2:
        return 'لا توجد مباريات غداً';
        break;
    }
    return "";
  }

  String _getDayType() {
    int selectedDay = 0;
    if (_isMyMatches) {
      selectedDay = this._selectedMyDay;
    } else {
      selectedDay = this._selectedDay;
    }

    switch (selectedDay) {
      case 0:
        return 'yesterday';
        break;
      case 1:
        return 'today';
        break;
      case 2:
        return 'tomorrow';
        break;
    }
    return "";
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(name: 'matches_list');
  }

  @override
  void reloadAction() {
    if (_isMyMatches) {
      _matchesNetwork.getInterestsMatches(_getDayType(), this);
    } else {
      _matchesNetwork.getMatches(_getDayType(), this);
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
    Fluttertoast.showToast(msg:"حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(msg:
        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
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
    Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void addInterests() {
    //once success to add interest so we need to refresh events
    //reset data
    _teams.clear();
    if (_isMyMatches) {
      _matchesNetwork.getInterestsMatches(_getDayType(), this);
    } else {
      _matchesNetwork.getMatches(_getDayType(), this);
    }
  }

  @override
  void setTeams(TeamsData? teamsData) {
    if (teamsData?.teams != null) {
      setState(() {
        this._teams.addAll(teamsData?.teams??[]);
        _isNoNetwork = false;
      });
    }

    setState(() {
      if (this._teams.isEmpty) {
        if (_isMyMatches) {
          if (teamsData?.has_interest??false) {
            _isNoData = true;
            _isNoInterest = false;
          } else {
            _isNoInterest = true;
            _isNoData = false;
          }
        } else {
          _isNoInterest = false;
          _isNoData = true;
        }
      } else {
        _isNoInterest = false;
        _isNoData = false;
      }
    });
  }

  @override
  void onNotificationClicked() {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>  NotificationsList(),
          ));
    });
    // TODO: implement onNotificationClicked
  }

  @override
  void selectedSubCategory(Category category) {
    // TODO: implement selectedSubCategory
  }
}

class MatchesListSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  BuildContext? context;
  MatchesListState matchesList;
  bool isShowMyMatchesOnly  = false;
  NewsDeleagte newsDeleagte;

  MatchesListSliverAppBar({ this.expandedHeight=0, required this.matchesList,required this.isShowMyMatchesOnly,required this.newsDeleagte});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.context = context;
//    print('shrinkOffset: ' + shrinkOffset.toString());
    double width = MediaQuery.of(context).size.width;
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
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
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          alignment: Alignment.topRight,
        ),
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              LocalSettings.token != null? _buildNotificationIcon(
                LocalSettings.notificationsCount != null
                    ? (LocalSettings.notificationsCount??0 )> 0
                    ? 'assets/ic_not_ac.png'
                    : 'assets/ic_not_nr.png'
                    : 'assets/ic_not_nr.png',

              ):SizedBox(),
            ]
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: shrinkOffset > 90 ? 0 : 50,
//                right: shrinkOffset > 110 ? 0 : 0,
//                left: shrinkOffset > 110 ? 100 : 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                LocalSettings.token ==null
                    ? SizedBox():   Visibility(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      matchesList._isMyMatches
                          ? SizedBox()
                          : SizedBox(
                              height: 20,
                            ),
                      GestureDetector(
                        child: Text(
                          'فرقي',
                          style: TextStyle(
                              color: matchesList._isMyMatches
                                  ? Colors.white
                                  : Color(0xffb1e6b1),
                              fontSize: shrinkOffset > 90 ? 17 : 26,
                              fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          matchesList._changeMatchesSelection(true);
                        },
                      ),
                      Visibility(
                        child: Image.asset('assets/arrow_down_ic.png'),
                        visible: shrinkOffset < 90 && matchesList._isMyMatches,
                      )
                    ],
                  ),
                  visible: !isShowMyMatchesOnly?false:shrinkOffset > 90
                      ? matchesList._isMyMatches ? true : false
                      : true,
                ),
                LocalSettings.token ==null
                    ? SizedBox():   SizedBox(
                  width: shrinkOffset > 90 ? 0 : 30,
                ),
                Visibility(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      !matchesList._isMyMatches
                          ? SizedBox()
                          : SizedBox(
                              height: 20,
                            ),
                      GestureDetector(
                        child: Text(
                          'كل الفرق',
                          style: TextStyle(
                              color: matchesList._isMyMatches
                                  ? Color(0xffb1e6b1)
                                  : Colors.white,
                              fontSize: shrinkOffset > 90 ? 17 : 26,
                              fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          matchesList._changeMatchesSelection(false);
                        },
                      ),
                      Visibility(
                        child: Image.asset('assets/arrow_down_ic.png'),
                        visible: shrinkOffset < 90 && !matchesList._isMyMatches,
                      )
                    ],
                  ),
                  visible: isShowMyMatchesOnly?false: shrinkOffset > 90
                      ? !matchesList._isMyMatches ? true : false
                      : true,
                ),
              ],
            ),
          ),
        ),
        Visibility(
          child: Positioned.fill(
//            top: expandedHeight / 2 - shrinkOffset,
            top: 100,
            child: Opacity(
              opacity: (1 - shrinkOffset / (expandedHeight)),
              child: Align(
                child: GestureDetector(
                  child: Center(
                    child: matchesList._buildMatchesFilteration(),
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          visible: shrinkOffset < 20 ? true : false,
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
  Widget _buildNotificationIcon(
      String imageName) {
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 0, top: 15),
        child: Align(
          child: GestureDetector(
            child: Container(
              child: Column(
                children: <Widget>[

                  Image.asset(
                    imageName,
                    height: 30,
                    fit: BoxFit.fitHeight,
                  ),


                ],
              ),
            ),
            onTap: () {
              LocalSettings.notificationsCount = 0;
              newsDeleagte.onNotificationClicked();


            },
          ),
          alignment: Alignment.topLeft,
        ));
  }
}
