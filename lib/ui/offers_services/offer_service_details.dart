import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

// import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share/share.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/delegates/add_review_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/OfferServiceDetailsResponseListener.dart';
import 'package:sporting_club/network/repositories/offers_services_network.dart';
import 'package:sporting_club/ui/home/home.dart';
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
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'offers_services_list.dart';

class OfferServiceDetails extends StatefulWidget {
  int _id = 0;
  bool _isOffers = true;
  bool isFromShare = false;

  OfferServiceDetails(this._id, this._isOffers, {this.isFromShare = false});

  @override
  State<StatefulWidget> createState() {
    return OfferServiceDetailsState(this._id, this._isOffers);
  }
}

class OfferServiceDetailsState extends State<OfferServiceDetails>
    implements
        OfferServiceDetailsResponseListener,
        NoNewrokDelagate,
        AddReviewDelegate {
  int _id = 0;
  bool _isloading = false;
  bool _isNoNetwork = false;
  bool _isSuccess = false;
  OffersServicesNetwork _offersServicesNetwork = OffersServicesNetwork();
  Offer _data = Offer();

  bool _isOffers = true;
  StreamSubscription? subscription;

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer, _timer2;

  OfferServiceDetailsState(this._id, this._isOffers);

  @override
  void initState() {
    print(_id);
    _offersServicesNetwork.getOffersOrServicesDetails(_isOffers, _id, this);
    super.initState();
    _getAds();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!
      if (result == ConnectivityResult.none && _isloading) {
        print("no network listner");
        this.hideLoading();
        this.showNetworkError();
      }
    });
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
    return WillPopScope(
      onWillPop: () async{
        if (widget.isFromShare) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Home()),
              (Route<dynamic> route) => false);
        } else {
          Navigator.pop(context);
        }
        return true;
      },
      child: ModalProgressHUD(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            color: Color(0xff43a047),
            child: SafeArea(
              bottom: false,
              child: Material(
                child: CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      delegate: OfferServiceDetailsSliverAppBar(
                          expandedHeight: 230,
                          data: this._data,
                          addReviewDelegate: this,
                          isFromShare: widget.isFromShare),
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
                //if no image remove it
          (_data.image != null&&!_isOffers)
                    ? (_data.image?.isNotEmpty??false)
                        ? Padding(
                            padding:
                                EdgeInsets.only(right: 20, top: 25, left: 10),
                            child: Align(
                              child: _buildNewsImage(),
                              alignment: Alignment.center,
                            ),
                          )
                        : SizedBox()
                    : SizedBox(),
                ads != null ? _buildAdsView() : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 20, left: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: HtmlContent(_data.content??""),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20, top: 10, left: 10),
                  child: Align(
                    child: (_data.post_gallery != null &&
                            (_data.post_gallery?.isNotEmpty??false))
                        ? PostGallery(_data.post_gallery??[])
                        : Container(),
                    alignment: Alignment.centerRight,
                  ),
                ),
                Visibility(
                    child: _buildInterestedButton(),
                    visible:
                        (_isOffers && (_data.display_interest??false))
                    // !_isOffers || (_isOffers && _data.display_interest)
                    ),

                SizedBox(
                  height: 20,
                ),
//                (_data.url != null && _data.url != "")
//                    ? InkWell(
//                        onTap: (){
//                          _launchURL(_data.url);
//                        },
//                        child: Text(
//                          "معرفة لمزيد و التقديم",
//                          style: TextStyle(
//                            color: Colors.blue,
//                            fontSize: 15,
//                          ),
//                        ),
//                      )
//                    : SizedBox(),
              ],
            )
          : Container(),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
            _data.categories?[index].name ?? "",
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
        child: _data.image != null
            ? _data.image != ""
                ?
                // FadeInImage.assetNetwork(
                //             placeholder: 'assets/placeholder.png',
                //             image: _data.image,
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
                      //             FullImage( _data.image)));
                      Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) =>
                            FullImage(_data.image??""),
                      ));
                    },
                    child: Container(
                      height: 200,
                      width: width - 30,
                      child: CachedNetworkImage(
                        imageUrl: _data.image??"",
                        placeholder: (context, url) =>
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

  Widget _buildInterestedButton() {
    bool interested = false;
    if (_data.interest != null) {
      interested = _data.interest??false;
    }
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(left: 25, right: 25, top: 25),
        child: Container(
          child: Center(
            child: Text(
              interested
                  // ? _isOffers
                  ? 'لقد تم إبلاغ الادارة برغبتك بالعرض '
                  //     : "لقد تم إبلاغ الادارة برغبتك بالخدمة "
                  : 'أرغب بالاشتراك',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          margin: EdgeInsets.only(bottom: 20, top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 8.0, // has the effect of softening the shadow
                spreadRadius: 0.0, // has the effect of extending the shadow
                offset: Offset(
                  0.0, // horizontal, move right 10
                  0.0, // vertical, move down 10
                ),
              ),
            ],
            color: interested ? Colors.grey : Color(0xffff5c46),
          ),
          height: 50,
        ),
      ),
      onTap: interested ? null : _setInterest,
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
    String adsName = _isOffers ? "inner_offers" : "inner_services";
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads = LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty??false) {
        for (AdvertisementData adv in ads??[]){
          if (adv.name == adsName) {
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

  void _setInterest() {
    print('_setInterest');
    if (LocalSettings.token == null) {
      Fluttertoast.showToast(msg:"يجب عليك تسجيل الدخول اولا",
          toastLength: Toast.LENGTH_LONG);
    } else {
      if (!_isOffers && _data.service_url != null) {
        print("hhhhh");
        print(_data.service_url);
        _launchURL(_data.service_url??"");
      } else {
        _offersServicesNetwork.interestOfferOrServices(_isOffers, _id, this);
      }
    }
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    if (_isOffers) {
      analytics.logEvent(
        name: 'offer_details',
        parameters: <String, String>{
          'offer_title': _data.title??"",
        },
      );
    } else {
      analytics.logEvent(
        name: 'service_details',
        parameters: <String, String>{
          'service_title': _data.title??"",
        },
      );
    }
  }

  void _shareAction() {
    if (LocalSettings.link != "") {
      //Share.share(LocalSettings.link??"");
      Share.share(LocalSettings.link??"", subject: "Sporting Club");

      _timer2 = Timer.periodic(new Duration(seconds: 5), (timer) {
        hideLoading();
        _timer2?.cancel();
      });
      // }
    } else {
      hideLoading();
    }
  }

  @override
  void reloadAction() {
    _offersServicesNetwork.getOffersOrServicesDetails(
        this._isOffers, _id, this);
  }

  @override
  void hideLoading() {
    print("hide Loading");
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
    print("showNetworkError");
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
  void setData(Offer? data) {
    setState(() {
      _isSuccess = true;
      this._data = data??Offer();
      _isNoNetwork = false;
      String title = "", content = "";
      if (_isOffers) {
        title = "offer";
      } else {
        title = "service";
      }
      setupBranchIO();

      if (ApiUrls.RELEASE_MODE) {
        _sendAnalyticsEvent();
      }
    });
  }
  setupBranchIO() async {
    String title = "", content = "";
    if (_isOffers) {
      title = "offer";
    } else {
      title = "service";
    }  BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: "content/12345",
      title: _data.title??"",
      imageUrl:_data.image??"",
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
    lp.addControlParam('link',title);
    lp.addControlParam('id',  _data.id==null?_id.toString(): _data.id.toString());
    BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      print('Link generated: ${response.result}');
      LocalSettings.link=response.result;
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  @override
  void showInterestedSuccessfully() {
    setState(() {
      _data.interest = true;
    });
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

class OfferServiceDetailsSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  Offer data = Offer();
  BuildContext? context;
  AddReviewDelegate addReviewDelegate;
  bool isFromShare;

  OfferServiceDetailsSliverAppBar(
      { this.expandedHeight=0,
        required this.data,
        required this.addReviewDelegate,
         this.isFromShare = false});

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
                onPressed: () {
                  if (isFromShare) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Home()),
                        (Route<dynamic> route) => false);
                  } else {
                    Navigator.of(context).pop(null);
                  }
                }),
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
                data.title?? "",
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
                          itemCount: data.categories?.length ?? 0,
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
      ],
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
            data.categories?[index].name??"",
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
