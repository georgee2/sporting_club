import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/restaurant.dart';
import 'package:sporting_club/data/model/restaurants_data.dart';
import 'package:sporting_club/delegates/add_review_delegate.dart';
import 'package:sporting_club/delegates/news_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/RestaurantsResponseListener.dart';
import 'package:sporting_club/network/repositories/restaurants_network.dart';
import 'package:sporting_club/ui/news/news_sub_categories.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
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
import 'full_image.dart';

class RestaurantsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RestaurantsListState();
  }
}

class RestaurantsListState extends State<RestaurantsList>
    implements
        NoNewrokDelagate,
        RestaurantResponseListener,
        AddReviewDelegate,
        NewsDeleagte {
  bool _isloading = false;
  RestaurantsNetwork _restaurantsNetwork = RestaurantsNetwork();

  String _selectedRestaurantId = "";
  int _selecgtedItem = 0;
  List<Category> _restaurants = [];

  bool _isNoNetwork = false;
  Restaurant _restaurant = Restaurant();
  Restaurant _firstRestaurant = Restaurant();

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _restaurantsNetwork.getRestaurants(this);
    if (ApiUrls.RELEASE_MODE) {
      _sendAnalyticsEvent();
    }
    _getAds();
    OneSignal.shared
        .setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent  notification) {
      print("setNotificationReceivedHandler in restaurants service ");
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
  void selectedSubCategory(Category category) {
    setState(() {
      print('selectedSubCategory');
      _selectedRestaurantId = category.id??"";
      // if(_selectedRestaurantId=="0"){
      //   for (var i = 0; i < _myCategories.length-1; i++) {
      //     Map<int, Category> item = {i: _myCategories[i]};
      //     _selectedRestaurantId=selectedSubCategory+_myCategories[i].id+",";
      //   }
      //   _selectedRestaurantId = _selectedRestaurantId.substring(1);
      //   _selectedRestaurantId = _selectedRestaurantId.substring(0, _selectedRestaurantId.length - 1);
      // }
      _selecgtedItem = _restaurants.indexOf(category);
      _resetData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
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
                    delegate: RestaurantsListSliverAppBar(
                        expandedHeight: 220,
                        restaurantsList: this,
                        newsDeleagte: this),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return _isNoNetwork
                          ? _buildImageNetworkError()
                          : _restaurant.id != null
                              ? _buildContent()
                              : Container();
//                        if (_isNoNetwork) {
//                          return _buildImageNetworkError();
//                        } else if (_isNoData) {
//                          return _buildNoData();
//                        } else {
//                          if (_isNoMoreData) {
//                            return _buildItem(index);
//                          } else {
//                            return index == _items.length
//                                ? _buildProgressIndicator()
//                                : _buildItem(index);
//                          }
//                        }
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
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: <Widget>[
        _buildTitleText('قائمة الطعام'),
        Padding(
          padding: EdgeInsets.only(right: 0, top: 20, left: 0),
          child: Align(
            child: Container(
              child:
                  (_restaurant.menus != null &&( _restaurant.menus?.length??0) != 0)
                      ? ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return _buildMenuItem(index);
                          },
                          itemCount: _restaurant.menus?.length ?? 0,
                          scrollDirection: Axis.horizontal,
                        )
                      : Padding(
                          padding: EdgeInsets.only(right: 20, left: 10),
                          child: Image.asset(
                            'assets/placeholder_2.png',
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
              height: 150,
            ),
            alignment: Alignment.centerRight,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 20, top: 25, left: 10),
          child: Align(
            alignment: Alignment.centerRight,
            child: HtmlContent(_restaurant.description??""),
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.only(right: 20, top: 25, left: 10),
        //   child: Align(
        //     child: Text(
        //       _restaurant.description != null ? _restaurant.description : "",
        //       style: TextStyle(color: Colors.black, fontSize: 16),
        //     ),
        //     alignment: Alignment.centerRight,
        //   ),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                _restaurant.managers != null
                    ? (_restaurant.managers?.length ??0)> 0
                        ? _buildTitleText('المدير المسؤول')
                        : Container()
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(right: 0, top: 0, left: 0),
                  child: Align(
                    child: Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return _buildManager(index);
                        },
                        itemCount: _restaurant.managers != null
                            ? (_restaurant.managers?.length??0)
                            : 0,
                      ),
                      width: width - 100,
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
              ],
            ),
            Align(
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(top: 0, left: 10),
                  child: _restaurant.comment_id != null
                      ? (_restaurant.comment_id?.isNotEmpty??false)
                          ? Image.asset(
                              'assets/review_ic.png',
                              width: 90,
                              fit: BoxFit.fitWidth,
                            )
                          : Image.asset(
                              'assets/review_nr.png',
                              width: 90,
                              fit: BoxFit.fitWidth,
                            )
                      : Container(),
                ),
                onTap: () => _addReview(),
              ),
              alignment: Alignment.topLeft,
            ),
          ],
        ),
        SizedBox(
          height: _restaurant.managers != null
              ? (_restaurant.managers?.length??0) > 0 ? 0 : 0
              : 0,
        ),
        _buildTitleText('مكان المطعم'),
        Padding(
          padding: EdgeInsets.only(right: 20, top: 2, left: 10),
          child: Align(
            child: Text(
              _restaurant.location?? "",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            alignment: Alignment.centerRight,
          ),
        ),
        ads != null ? _buildAdsView() : SizedBox(),
        SizedBox(
          height: 30,
        ),
        _restaurant.suitable_for_kids != null
            ? _restaurant.suitable_for_kids == "1"
                ? _buildFeature('مناسب لاصطحاب الأطفال', true)
                : _buildFeature('مناسب لاصطحاب الأطفال', false)
            : _buildFeature('مناسب لاصطحاب الأطفال', false),
        SizedBox(
          height: 10,
        ),
        _restaurant.available_for_birthdays != null
            ? _restaurant.available_for_birthdays == "1"
                ? _buildFeature('مناسب لاقامة أعياد الميلاد', true)
                : _buildFeature('مناسب لاقامة أعياد الميلاد', false)
            : _buildFeature('مناسب لاقامة أعياد الميلاد', false),

        Padding(
          padding: EdgeInsets.only(right: 20, top: 10, left: 10),
          child: Align(
            child: (_restaurant.post_gallery != null &&
                    (_restaurant.post_gallery?.isNotEmpty??false))
                ? PostGallery(_restaurant.post_gallery??[])
                : Container(),
            alignment: Alignment.centerRight,
          ),
        ),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget _buildTitleText(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 20, top: 10, left: 10),
      child: Align(
        child: Text(
          title,
          style: TextStyle(color: Color(0xff43a047), fontSize: 18),
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    return Padding(
      padding: EdgeInsets.only(right: index == 0 ? 20 : 0, left: 10),
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          child: _restaurant.menus?[index].small != null
              ?( _restaurant.menus?[index].small ??"")!= ""
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder_2.png',
                      image: _restaurant.menus?[index].small??"",
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      'assets/placeholder_2.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    )
              : Image.asset(
                  'assets/placeholder_2.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
        ),
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => FullImage(
                _restaurant.menus?[index].large ?? "",
                  index: index,
              gallery: _restaurant.menus??[],

            ),
          ));
        },
      ),
    );
  }

  Widget _buildManager(int index) {
    String value = "";

    if (_restaurant.managers?[index].name != null) {
      value += _restaurant.managers?[index].name??"";
    }
    if (_restaurant.managers?[index].phone != null) {
      value += "     ${_restaurant.managers?[index].phone??''}"  ;
    }
    return Padding(
      padding: EdgeInsets.only(right: 20, top: 2, left: 10),
      child: Align(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _buildFeature(String feature, bool isValid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 20,
        ),
        Icon(
          isValid ? Icons.check_box : Icons.check_box_outline_blank,
          color: Color(0xffff5c46),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          feature,
          style: TextStyle(color: Color(0xffff5c46), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(int index) {
    return Padding(
      padding: EdgeInsets.only(right: index == 0 ? 20 : 0, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 12, left: 12, top: 5),
          height: 35,
//          child: Center(
          child: Text(
            _restaurants[index].name ?? "",
            style: TextStyle(
              color: _restaurants[index].id == _selectedRestaurantId
                  ? Colors.white
                  : Color(0xffb1e6b1),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
//            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: _restaurants[index].id == _selectedRestaurantId
                  ? Color(0xff43a047)
                  : Color(0xff76d275),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _restaurants[index].id == _selectedRestaurantId
                ? Color(0xff43a047)
                : Colors.transparent,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedRestaurantId = _restaurants[index].id??"";
            _resetData();
          });
        },
      ),
    );
  }

  Widget _builddrop() {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(right: 15, left: 15, top: 0),
        height: 40,
        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                _restaurants[_selecgtedItem].name??"",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Image.asset(
              'assets/arrow_down_ic.png',
              width: 8,
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Color(0xff00701a),
            ),
            borderRadius: BorderRadius.circular(20),
            color: Color(0xff00701a)),
      ),
      onTap: () {
        print("rest1");
        setState(() {
//              _viewSubCategories = true;
          Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                NewsSubCategories(_restaurants, this, _selectedRestaurantId),
          ));
        });
      },
    );
  }

  Widget _buildDropDownmeu() {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Color(0xff00701a),
          ),
          borderRadius: BorderRadius.circular(20),
          color: Color(0xff00701a)),

      // dropdown below..
      child: DropdownButton<String>(
          value: 'One',
          icon: Image.asset(
            'assets/arrow_down_ic.png',
            width: 8,
            fit: BoxFit.fitWidth,
          ),
          iconSize: 42,
          underline: SizedBox(),
          onChanged: (String? newValue) {
//          setState(() {
//              _selectedRestaurantId = _restaurants[0].id;
//              _resetData();
//          });
//    setState(() {
//    dropdownValue = newValue;
//    });
          },
          items: <String>['One', 'Two', 'Three', 'Four']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10),
                child: Text(
                  value,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }).toList()),
    );
  }

  Widget _buildImageNetworkError() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 3;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
        padding: EdgeInsets.only(top: topPadding), child: NoNetwork(this));
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

    if (ads?[0].images?[viewedAdvIndex].link != null) {
      if (await UrlLauncher.canLaunch(ads?[0].images?[viewedAdvIndex].link??"")) {
        await UrlLauncher.launch(ads?[0].images?[viewedAdvIndex].link??"");
      } else {
        print("can't launch");
      }
    }
  }

  void _getAds() {
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads = LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty??false) {
        for (AdvertisementData adv in ads??[]){
          if (adv.name == "in_restuarant") {
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

  void _addReview() {
    print('_submitReview');
    bool hasReview = false;
    if (_restaurant.comment_id != null) {
      if (_restaurant.comment_id?.isNotEmpty??false) {
        hasReview = true;
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AddReview(
                _restaurant.id.toString(),
                hasReview,
                _restaurant.comment_id ?? "",
                false,
                this,
                true)));
  }

  void _resetData() {
    print('_resetData');
    if (_selectedRestaurantId == _firstRestaurant.id.toString()) {
      setState(() {
        _restaurant = Restaurant();
        _restaurant = _firstRestaurant;
      });
    } else {
      setState(() {
        _restaurant = Restaurant();
      });
      _restaurantsNetwork.getRestaurantDetails(_selectedRestaurantId, this);
    }
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(name: 'restaurants_list');
  }

  @override
  void reloadAction() {
    if (_restaurants.isEmpty) {
      _restaurantsNetwork.getRestaurants(this);
    } else {
      _restaurantsNetwork.getRestaurantDetails(_selectedRestaurantId, this);
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
  void setRestaurants(RestaurantsData? restaurantsData) {
    if (restaurantsData?.restaurants != null) {
      setState(() {
        this._isNoNetwork = false;
        this._restaurants.clear();
        this._restaurants = restaurantsData?.restaurants??[];
        if (_restaurants.length > 0) {
          this._selectedRestaurantId = _restaurants[0].id??"0";
        }
      });
    }

    if (restaurantsData?.singleRestaurant != null) {
      setState(() {
        _firstRestaurant = restaurantsData?.singleRestaurant??Restaurant();
      });
      setRestaurantData(restaurantsData?.singleRestaurant);
    }
  }

  @override
  void setRestaurantData(Restaurant? restaurant) {
    setState(() {
      this._isNoNetwork = false;
      _restaurant = restaurant?? Restaurant();
    });
  }

  @override
  void addReviewSuccessfully(int reviewID) {
    setState(() {
      _restaurant.comment_id = reviewID.toString();
    });
  }

  @override
  void share() {
    // TODO: implement share
  }

  @override
  void onNotificationClicked() {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NotificationsList(),
          ));
    });
    // TODO: implement onNotificationClicked
  }
}

class RestaurantsListSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  BuildContext? context;
  RestaurantsListState restaurantsList;
  NewsDeleagte newsDeleagte;

  RestaurantsListSliverAppBar(
      { this.expandedHeight=0,required this.restaurantsList,required this.newsDeleagte});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.context = context;
    print('shrinkOffset: ' + shrinkOffset.toString());
    double height = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Container(
          color: shrinkOffset < 140 ? Colors.transparent : Color(0xff43a047),
          height: 80,
        ),
        Image.asset(
//          "assets/intersection_3.png",
          "assets/offer_bg.png",

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
              LocalSettings.token != null
                  ? _buildNotificationIcon(
                      LocalSettings.notificationsCount != null
                          ? (LocalSettings.notificationsCount??0) > 0
                              ? 'assets/ic_not_ac.png'
                              : 'assets/ic_not_nr.png'
                          : 'assets/ic_not_nr.png',
                    )
                  : SizedBox(),
            ]),
        Center(
//          height: 100,
          child: Padding(
            padding: EdgeInsets.only(
                right: shrinkOffset > 100 ? 40 : 20,
                bottom: shrinkOffset > 100 ? 0 : 30,
                left: shrinkOffset > 100 ? 100 : 15),
            child: Align(
              child: Text(
                shrinkOffset > 100
                    ? (restaurantsList._restaurant.name??"")
                    : 'المطاعم',
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
        Padding(
          padding: EdgeInsets.only(top: 125),
          child: Column(
            children: <Widget>[
//              Visibility(
//                child: Opacity(
//                  opacity: (1 - shrinkOffset / (expandedHeight??0)),
//                  child: Padding(
//                    padding: EdgeInsets.only(right: 0, top: 0, left: 0),
//                    child: Align(
//                      child: Container(
//                        child: ListView.builder(
//                          itemBuilder: (BuildContext context, int index) {
//                            return restaurantsList._buildCategoryItem(index);
//                          },
//                          itemCount: restaurantsList._restaurants.length,
//                          scrollDirection: Axis.horizontal,
//                        ),
//                        height: 35,
//                      ),
//                      alignment: Alignment.centerRight,
//                    ),
//
//
//                  ),
//                ),
//                visible: shrinkOffset < 20 ? true : false,
//              ),
              restaurantsList._restaurants.length > 0
                  ? Align(
                      child: Visibility(
                        child: restaurantsList._builddrop(),
                        visible: shrinkOffset < 20 ? true : false,
                      ),
                      alignment: Alignment.center,
                    )
                  : SizedBox(),

//
            ],
          ),
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

  Widget _buildNotificationIcon(String imageName) {
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
