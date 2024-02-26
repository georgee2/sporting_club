import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:share/share.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/match.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/delegates/add_review_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/listeners/MatchDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/OfferServiceDetailsResponseListener.dart';
import 'package:sporting_club/network/repositories/matches_network.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/repositories/offers_services_network.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/restaurants/full_image.dart';
import 'package:sporting_club/ui/review/add_review.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:sporting_club/widgets/FullPhoto.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class MatchDetails extends StatefulWidget {
  String _id = "";
bool fromNotification = false;
  MatchDetails(this._id,this.fromNotification);

  @override
  State<StatefulWidget> createState() {
    return MatchDetailsState(this._id,this.fromNotification);
  }
}

class MatchDetailsState extends State<MatchDetails>
    implements MatchDetailsResponseListener, NoNewrokDelagate,AddReviewDelegate {
  String _id = "";
  bool _isloading = false;
  bool _isNoNetwork = false;
  bool _isSuccess = false;
  MatchesNetwork _matchNetwork = MatchesNetwork();
  Match _match = Match();

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer,_timer2;
  bool fromNotification = false;

  MatchDetailsState(this._id,this.fromNotification);

  @override
  void initState() {
    print(_id);
    _matchNetwork.getMatchDetails(_id,this);
    super.initState();
    _getAds();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    if (_timer2 != null) {
      _timer2?.cancel();
      _timer2 = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: Color(0xff212121),
          child: SafeArea(
            bottom: false,
            child: Material(
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: MatchDetailsSliverAppBar(
                        expandedHeight: 300, match: this._match,fromNotification:this.fromNotification,addReviewDelegate: this),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return _isNoNetwork
                          ? _buildImageNetworkError()
                          : _buildContent();
                    }, childCount: 1),
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

  Widget _buildContent() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: _isSuccess
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //if no image remove it
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 25, left: 10),
                  child: Align(
                    child: Text(
                      _match.location ?? "",
                      style: TextStyle(color: Color(0xffe21b1b), fontSize: 18),
                    ),
                    alignment: Alignment.center,
                  ),
                ),
                ads != null ? _buildAdsView() : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, left: 10),
                  child: Align(
                    child: Text(
                      _match.descriptions?? "",
//                    'هناك حقيقة مثبتة منذ زمن طويل وهي أن المحتوى المقروء لصفحة ما سيلهي القارئ عن التركيز على الشكل الخارجي للنص أو شكل توضع الفقرات في الصفحة التي يقرأها. ولذلك يتم استخدام طريقة لوريم إيبسوم لأنها تعطي توزيعاَ طبيعياَ -إلى حد ما- للأحرف عوضاً عن استخدام "هنا يوجد محتوى نصي، هنا يوجد محتوى نصي" فتجعلها تبدو (أي الأحرف) وكأنها نص مقروء. العديد من برامح النشر المكتبي وبرامح تحرير هناك حقيقة مثبتة منذ زمن طويل وهي أن المحتوى المقروء لصفحة ما سيلهي القارئ عن التركيز على الشكل الخارجي للنص أو شكل توضع الفقرات في الصفحة التي يقرأها. ولذلك يتم استخدام طريقة لوريم إيبسوم لأنها تعطي توزيعاَ طبيعياَ -إلى حد ما- للأحرف عوضاً عن استخدام "هنا يوجد محتوى نصي، هنا يوجد محتوى نصي" فتجعلها تبدو (أي الأحرف) وكأنها نص مقروء. العديد من برامح النشر المكتبي وبرامح تحرير هناك حقيقة مثبتة منذ زمن طويل وهي أن المحتوى المقروء لصفحة ما سيلهي القارئ عن التركيز على الشكل الخارجي للنص أو شكل توضع الفقرات في الصفحة التي يقرأها. ولذلك يتم استخدام طريقة لوريم إيبسوم لأنها تعطي توزيعاَ طبيعياَ -إلى حد ما- للأحرف عوضاً عن استخدام "هنا يوجد محتوى نصي، هنا يوجد محتوى نصي" فتجعلها تبدو (أي الأحرف) وكأنها نص مقروء. العديد من برامح النشر المكتبي وبرامح تحرير',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )
          : Container(),
    );
  }

  Widget _buildImageNetworkError() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 4;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: NoNetwork(this),
    );
  }

  Widget _buildAdsView() {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 20, left: 15, top: 20, bottom: 5),
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
        for (AdvertisementData adv in ads??[]) {
          if (adv.name == "inner_matches") {
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

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    String value = "";
    if (_match.home_team != null) {
      value = "${_match.home_team} ضد " ;
    }
    if (_match.away_team != null) {
      value += _match.away_team??"";
    }
    analytics.logEvent(
      name: 'match_details',
      parameters: <String, String>{
        'match_title': value,
      },
    );
  }
  void _shareAction() {
     if (LocalSettings.link != "") {

    Share.share(LocalSettings.link??"" , subject: "Sporting Club");
    _timer2 = Timer.periodic(new Duration(seconds: 5), (timer) {
      hideLoading();
      _timer2?.cancel();

    });

    // Share.share(match.url);
    }
  }
  @override
  void reloadAction() {
    _matchNetwork.getMatchDetails(_id, this);
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
  void showServerError(String? msg) {
    Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
  }

  @override
  void setMatch(match) {
    setState(() {
      _isSuccess = true;
      this._match = match??Match();
      _isNoNetwork = false;
      String value = "";
      if (_match.home_team != null) {
        value = "${_match.home_team} ضد " ;
      }
      if (_match.away_team != null) {
        value += _match.away_team??"";
      }
      setupBranchIO() ;

      if (ApiUrls.RELEASE_MODE) {
        _sendAnalyticsEvent();
      }
    });
  }
  setupBranchIO() async {
    String value = "";
    if (_match.home_team != null) {
      value = "${_match.home_team} ضد " ;
    }
    if (_match.away_team != null) {
      value += _match.away_team??"";
    }  BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: "content/12345",
      title: value,
      contentDescription: _match.descriptions??"",
      keywords: ['Sporting', 'club'],
      publiclyIndex: true,
      locallyIndex: true,
    );
    BranchLinkProperties lp = BranchLinkProperties(
      channel: 'facebook',
      feature: 'sharing',
      stage: 'new user',
      campaign: "content 123 launch",
    );
    lp.addControlParam('link', "match");
    lp.addControlParam('id', _id);
    BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      print('Link generated: ${response.result}');
      LocalSettings.link=response.result;
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  @override
  void addReviewSuccessfully(int reviewID) {
    // TODO: implement addReviewSuccessfully
  }

  @override
  void share() {
    showLoading();
    _shareAction();
    // TODO: implement share
  }
}

class MatchDetailsSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  Match match = Match();
  BuildContext? context;
  AddReviewDelegate addReviewDelegate;
  bool fromNotification = false;

  MatchDetailsSliverAppBar({ this.expandedHeight=0, required this.match,required this.addReviewDelegate,required this.fromNotification});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.context = context;
    print('shrinkOffset: ' + shrinkOffset.toString());
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
//        Container(
//          color: shrinkOffset < 170 ? Colors.transparent : Color(0xff43a047),
//          height: 80,
//        ),
        Image.asset(
          "assets/match_bg.png",
//          fit: shrinkOffset < 170 ? BoxFit.fill : BoxFit.cover,
          fit: BoxFit.fill,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset('assets/share_white.png'),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'مشاركة',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
            onTap: () {
              addReviewDelegate.share();
            },
          ),
        ),
        Align(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 0, top: 5),
            child: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () {
    if (fromNotification) {
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
        Center(
//          height: 100,
          child: Padding(
            padding: EdgeInsets.only(
//              right: shrinkOffset > 110 ? 40 : 20,
//              left: shrinkOffset > 110 ? 100 : 15,
                ),
            child: Align(
              child: match.id != null ? _buildMatchResult() : SizedBox(),
              alignment: Alignment.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchResult() {
    double width = MediaQuery.of(context!).size.width - 30;
    Validation _validation = Validation();

    //get time of match
    String clock = "";
    String time = "";
    if (match.time != null) {
      String a = match.time??"";
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
    if (match.home_points != null) {
      if (_validation.isNumeric(match.home_points??"0")) {
        if (match.away_points != null) {
          result = "${match.home_points} - ${match.away_points}";
        }
      } else {
        result = match.home_points??"0";
      }
    }

    return Container(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    'assets/sporting_club_logo.png',
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    match.home_team ??"",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              width: width / 3,
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    result,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: result.contains(' - ') ? 26 : 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: result.contains(' - ') ? 0 : 10,
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
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      clock,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 7,
                ),
                match.category_title != null
                    ? _buildTeamName(match.category_title??"")
                    : SizedBox(),
              ],
            ),
            width: width / 3,
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  match.away_logo != null
                      ? match.away_logo != ""
                          ?
                  // FadeInImage.assetNetwork(
                  //             placeholder: 'assets/team_ic.png',
                  //             image: match.away_logo,
                  //             height: 70,
                  //             width: 70,
                  //             fit: BoxFit.fitWidth,
                  //           )

                  InkWell(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => FullImage(  match.away_logo)));
                      Navigator.of(context!).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) => FullImage(
                            match.away_logo ??""                ),
                      ));
                    },
                    child: Container(
                      height: 70,
                      width: 70,
                      child: CachedNetworkImage(
                        imageUrl:  match.away_logo??"",

                        placeholder: (context, url) =>
                            Image.asset("assets/placeholder_2.png"),
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.fitWidth,
                      ),
                    ),
                  )

                          : Image.asset(
                              'assets/team_ic.png',
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            )
                      : Image.asset(
                          'assets/team_ic.png',
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    match.away_team ??"",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            width: width / 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamName(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 15, left: 15, top: 7, bottom: 7),
//          height: 35,
//          width: 100,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color(0xff76d275),
          ),
        ),
      ),
    );
  }



  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 240;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
