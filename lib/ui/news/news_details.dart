import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/news.dart';
import 'package:sporting_club/delegates/add_review_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/NewsDetailsResponseListener.dart';
import 'package:sporting_club/network/repositories/news_network.dart';
import 'package:sporting_club/ui/menu_tabbar/menu_tabbar.dart';
import 'package:sporting_club/ui/restaurants/full_image.dart';
import 'package:sporting_club/ui/review/add_review.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/FullPhoto.dart';
import 'package:sporting_club/widgets/html_content.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:sporting_club/widgets/post_gallery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'dart:ui' as ui;

class NewsDetails extends StatefulWidget {
  int _newsID = 0;
  bool from_branch = false;

  NewsDetails(this._newsID, this.from_branch);

  @override
  State<StatefulWidget> createState() {
    return NewsDetailsState(this._newsID, this.from_branch);
  }
}

class NewsDetailsState extends State<NewsDetails>
    implements
        NewsDetailsResponseListener,
        NoNewrokDelagate,
        AddReviewDelegate {
  int _newsID = 0;
  bool _isloading = false;
  bool _isNoNetwork = false;
  bool _isSuccess = false;
  NewsNetwork _newsNetwork = NewsNetwork();
  News _news = News();

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer, _timer2;
  bool from_branch = false;

  NewsDetailsState(this._newsID, this.from_branch);

  @override
  void initState() {
    print(_newsID);
    _newsNetwork.getNewsDetails(_newsID, this);
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
        child: SafeArea(
          bottom: false,
          child: Material(
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: MySliverAppBar(
                      expandedHeight: 230,
                      news: this._news,
                      addReviewDelegate: this,
                      newsID: _newsID,
                      from_branch: from_branch),
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
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 25, left: 10),
                  child: Align(
                    child: _buildNewsImage(),
                    alignment: Alignment.center,
                  ),
                ),
                ads != null ? _buildAdsView() : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 25, left: 10),
                  child: Align(
                    child: Text(
                      _news.date ?? "",
                      style: TextStyle(color: Color(0xffb6b9c0), fontSize: 17),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 10, left: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: HtmlContent(_news.post_content??"")
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 10, left: 10),
                  child: Align(
                    child: (_news.post_gallery != null &&
                            (_news.post_gallery?.isNotEmpty??false))
                        ? PostGallery(_news.post_gallery??[])
                        : Container(),
                    alignment: Alignment.centerRight,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 10, left: 10),
                  child: Align(
                    child: _news.tags != null
                        ? Wrap(children: _buildTags())
                        : Container(),
                    alignment: Alignment.centerRight,
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

  Widget _buildCategoryItem(int index) {
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 12, left: 12, top: 5),
          height: 35,
//          child: Center(
          child: Text(
            _news.categories?[index].name ?? "",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
//            ),
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
        onTap: () {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildNewsImage() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        child: _news.image != null
            ? _news.image != ""
                ?
                // FadeInImage.assetNetwork(
                //             placeholder: 'assets/placeholder.png',
                //             image: _news.image,
                //             height: 200,
                //             width: width - 30,
                //             fit: BoxFit.cover,
                //           )
                InkWell(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             FullImage( _news.image)));
                      Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) => FullImage(
                            _news.image??""            ),
                      ));
                    },
                    child: Container(
                      height: 200,
                      width: width - 30,
                      child: CachedNetworkImage(
                        imageUrl: _news.image??"",
                        placeholder: (context, url) =>
                            Image.asset("assets/placeholder.png"),
                        errorWidget:  (context, o,t ) =>
                            Image.asset("assets/placeholder.png"),
                        height: 200,
                        width: width - 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Image.asset(
                    'assets/placeholder.png',
                    height: 200,
                    width: width - 30,
                    fit: BoxFit.cover,
                  )
            : Image.asset(
                'assets/placeholder.png',
                height: 200,
                width: width - 30,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  List<Widget> _buildTags() {
    List<Widget> tagsWidgets = [];
    for (Category tag in _news.tags??[]) {
      tagsWidgets.add(_buildTagItem(tag.name?? ""));
    }

    return tagsWidgets;
  }

  Widget _buildTagItem(String tagName) {
    return Container(
      child: Text(
        '#' + tagName,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      decoration: BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
          color: Color(0xff43a047)),
      padding: EdgeInsets.only(top: 4, bottom: 4, right: 15, left: 15),
      margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
    );
  }

  Widget _buildImageNetworkError() {
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: NoNetwork(this),
    );
  }

  Future<ui.Image> _getImage(String index) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    final String url = index;
    Image image = Image.network(url);

    image.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool isSync) {
      print(info.image.width);
      print(info.image.height);
      completer.complete(info.image);
    }));

    return completer.future;
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
          // height: snapshot.data.width.toDouble(),
          // width: width - 30,
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

  void _shareAction() {
    if (LocalSettings.link != "") {
      print(LocalSettings.link);

      //Share.share(LocalSettings.link??"");
      Share.share(LocalSettings.link??"", subject: "Sporting Club").then((value) {
        print("here-------");
      }).whenComplete(() {
        print("finish");
      });
      // Timer   _timer2;
      _timer2 = Timer.periodic(new Duration(seconds: 5), (timer) {
        hideLoading();
        _timer2?.cancel();
      });

      //  Share.share(localsettings.url);
    }
  }

  void _getAds() {
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads = LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty??false) {
        for (AdvertisementData adv in ads??[]){
          if (adv.name == "inner_news") {
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

  void _addReview() async {
    print('_submitReview');

//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (BuildContext context) => AddReview(
//                _newsID.toString(),
//                _news.check_commnet,
//                _news.comment_id != null ? _news.comment_id : "",
//                false,
//                this)));
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(
      name: 'news_details',
      parameters: <String, String>{
        'news_title': _news.post_title??"",
      },
    );
  }

  @override
  void reloadAction() {
    _newsNetwork.getNewsDetails(_newsID, this);
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
  void setNews(News? news) {
    setState(() {
      _isSuccess = true;
      this._news = news??News();
      _isNoNetwork = false;
      setupBranchIO();

//      var queryParameters = {
//        'link': 'news',
//        'id': _newsID.toString(),
//      };
//      var uri = Uri.https('sporting.app.link', '/7MALnBx4L', queryParameters);
//      print("urittt"+uri.toString());
      if (ApiUrls.RELEASE_MODE) {
        _sendAnalyticsEvent();
      }
    });
  }
  setupBranchIO() async {
  BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: "content/12345",
      title: this._news.title??"",
      imageUrl:_news.image??"",
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
    lp.addControlParam('link', "news");
    lp.addControlParam('id',  _news.id==null?_newsID.toString(): _news.id.toString());
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
    setState(() {
      _news.check_commnet = true;
      _news.comment_id = reviewID.toString();
    });
  }

  @override
  void share() {
    showLoading();
    _shareAction();
    // TODO: implement share
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  News news = News();
  AddReviewDelegate addReviewDelegate;
  BuildContext? context;
  int newsID = 0;
  bool from_branch = false;

  MySliverAppBar(
      { this.expandedHeight=0,
        required this.news,
        required this.addReviewDelegate,
        required this.newsID,
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
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset('assets/share_ic.png'),
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
                left: shrinkOffset > 110 ? 100 : 15),
            child: Align(
              child: Text(
                news.post_title ?? "",
                maxLines: shrinkOffset > 110 ? 1 : 3,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: shrinkOffset > 110 ? 18 : 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 155),
          child: Column(
            children: <Widget>[
              Visibility(
                child: Opacity(
                  opacity: (1 - shrinkOffset / (expandedHeight)),
                  child: Padding(
                    padding: EdgeInsets.only(right: 20, top: 10, left: 74),
                    child: Align(
                      child: Container(
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return _buildCategoryItem(index);
                          },
                          itemCount:(news.categories?.length??0),
                          scrollDirection: Axis.horizontal,
                        ),
                        height: 35,
                      ),
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
                visible: shrinkOffset < 20 ? true : false,
              ),
            ],
          ),
        ),
//        Visibility(
//          child: Positioned(
////            top: expandedHeight / 2 - shrinkOffset,
//            top: 130,
//            left: 10,
//            child: Opacity(
//              opacity: (1 - shrinkOffset / (expandedHeight??0)),
//              child: Align(
//                child: GestureDetector(
//                  child: Container(
//                    padding: EdgeInsets.only(top: 20, left: 10),
//                    child: news.check_commnet != null
//                        ? news.check_commnet
//                            ? Image.asset('assets/review_ic.png')
//                            : Image.asset('assets/review_nr.png')
//                        : Container(),
//                  ),
//                  onTap: () => _addReview(),
//                ),
//                alignment: Alignment.topLeft,
//              ),
//            ),
//          ),
//          visible: shrinkOffset < 20 ? true : false,
//        ),
      ],
    );
  }

  Widget _buildCategoryItem(int index) {
    print("categorey_id${news.categories?[index].id}");
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 12, left: 12, top: 5),
          height: 35,
          child: Text(
            news.categories?[index].name ?? "",
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
        onTap: () {
          if (from_branch) {
            print("here${news.categories?[index].id}");
            LocalSettings.newsId = news.categories?[index].id;
            Navigator.pushAndRemoveUntil(
                context!,
                MaterialPageRoute(
                    builder: (BuildContext context) => MenuTabBar(1, newsID)),
                (Route<dynamic> route) => false);
          } else {
            LocalSettings.newsId = null;

            Navigator.of(context!).pop(null);
          }
        },
      ),
    );
  }

  void _addReview() async {
    print('_submitReview');

    Navigator.push(
        context!,
        MaterialPageRoute(
            builder: (BuildContext context) => AddReview(
                newsID.toString(),
                news.check_commnet??false,
                news.comment_id ?? "",
                false,
                addReviewDelegate,
                true)));
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
