import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/advertisement.dart';
import 'package:sporting_club/data/model/advertisement_data.dart';
import 'package:sporting_club/data/model/categories_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/news.dart';
import 'package:sporting_club/data/model/news_data.dart';
import 'package:sporting_club/delegates/interests_delegate.dart';
import 'package:sporting_club/delegates/news_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/api_urls.dart';
import 'package:sporting_club/network/listeners/NewsResponseListener.dart';
import 'package:sporting_club/network/repositories/news_network.dart';
import 'package:sporting_club/ui/interests/interests.dart';
import 'package:sporting_club/ui/notifications/notifications_list.dart';
import 'package:sporting_club/ui/search/search.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'news_details.dart';
import 'news_sub_categories.dart';

class NewsList extends StatefulWidget {
  bool isShowMyNewsOnly;
  int selected_id;

  NewsList(this.isShowMyNewsOnly, this.selected_id);

  @override
  State<StatefulWidget> createState() {
    return NewsListState(isShowMyNewsOnly, selected_id);
  }
}

class NewsListState extends State<NewsList>
    implements
        NewsResponseListener,
        NewsDeleagte,
        NoNewrokDelagate,
        InterestsDeleagte {
  bool _isloading = false;
  bool _isMyNews = false;
  NewsNetwork _newsNetwork = NewsNetwork();
  bool _viewSubCategories = false;
  ScrollController _scrollController = ScrollController();
  bool _isPerformingRequest = false;

  int _selectedCategoryIndex = 0;
  List<Category> _categories = [];
  Category _selectedSubCategory = Category();
  List<Map<int, Category?>> _selectedCategories = [];
  List<News> _news = [];
  int _newsPage = 1;

  List<Category> _myCategories = [];
  List<Map<int, Category?>> _selectedMyCategories = [];
  int _selectedMyCategoryIndex = 0;

  bool _isNoMoreData = false;
  bool _isNoNetwork = false;
  bool _isNoData = false;
  bool _isNoInterest = false;
  bool isShowMyNewsOnly = false;

  //ads
  List<Advertisement>? ads;
  int viewedAdvIndex = 0, selected_id = 0;
  Timer? _timer;

  NewsListState(bool isMyNews, int selected_id) {
    this.isShowMyNewsOnly = isMyNews;
    //  this.selected_id = selected_id;
  }

  @override
  void initState() {
    _newsNetwork.getNewsCategories(this);
    List<String> list = LocalSettings.interests ?? [];
    LocalSettings.link = "";

    if (!list.contains('news')) {
      _isMyNews = false;
    }
    if (isShowMyNewsOnly) {
      _isMyNews = true;
    }
    if (LocalSettings.token == null) {
      _isMyNews = false;
//      _newsNetwork.getNews(_newsPage, _getSelectedSubCategoryId(), true, this);

    }

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        _getMoreData();
      }
    });
    if (ApiUrls.RELEASE_MODE) {
      _sendAnalyticsEvent();
    }
    _getAds();
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent notification) {
      print("setNotificationReceivedHandler in news  ");
      LocalSettings.notificationsCount = 1;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
//        child: Stack(
//          children: <Widget>[
//            Container(
//              color: Color(0xff43a047),
//            ),
//            Scaffold(
//              backgroundColor: Color(0xfff9f9f9),
//              body: _buildContent(),
//            )
//          ],
//        ),
        child: Container(
          color: Color(0xff43a047),
          child: SafeArea(
            bottom: false,
            child: Material(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPersistentHeader(
                    delegate: NewsListSliverAppBar(
                        expandedHeight: 240,
                        newsList: this,
                        isShowMyNewsOnly: isShowMyNewsOnly,
                        newsDeleagte: this),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return _buildSliverBody(index);
                      },
                      childCount: _isNoData ||
                              _isNoNetwork ||
                              (_isMyNews && _isNoInterest)
                          ? 1
                          : _news.isEmpty
                              ? 0
                              : _isNoMoreData
                                  ? _news.length + 1 //data + ads
                                  : _news.length + 2, //data + ad
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

  Widget _buildSliverBody(int index) {
    if (_isNoNetwork) {
      return _buildImageNetworkError();
    } else if (_isMyNews && _isNoInterest) {
      print('build _isNoInterest');
      return _buildNoInterests();
    } else if (_isNoData) {
      return _buildNoData();
    } else {
      return _getViewedItem(index);
    }
  }

  Widget _getViewedItem(int index) {
    if (_news.length >= 2) {
      if (index < 2) {
        return _buildNewsItem(index); //before 2 so news item
      } else if (index == 2) {
        return ads != null ? _buildAdsView() : SizedBox();
      } else if (!_isNoMoreData && index == _news.length + 1) {
        //we still have pages so build loader
        return _buildProgressIndicator();
      } else {
        return _buildNewsItem(index - 1); //build news items after ads
      }
    } else {
      //less than 2 items
      if (index == _news.length) {
        //ads
        return ads != null ? _buildAdsView() : SizedBox();
      } else if (index == _news.length + 1) {
        //loader
        return _buildProgressIndicator();
      } else {
        return _buildNewsItem(index);
      }
    }
  }

  Widget _buildCategoryItem(int index) {
    return Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.only(right: 10, left: 10),
          height: 35,
          child: Center(
            child: Text(
              _isMyNews
                  ? _myCategories[index].name ?? ""
                  : _categories[index].name ?? "",
              style: TextStyle(
                color: _isMyNews
                    ? _selectedMyCategoryIndex == index
                        ? Colors.white
                        : Color(0xffb1e6b1)
                    : _selectedCategoryIndex == index
                        ? Colors.white
                        : Color(0xffb1e6b1),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: _isMyNews
                  ? _selectedMyCategoryIndex == index
                      ? Color(0xff43a047)
                      : Color(0xff76d275)
                  : _selectedCategoryIndex == index
                      ? Color(0xff43a047)
                      : Color(0xff76d275),
            ),
            borderRadius: BorderRadius.circular(20),
            color: _isMyNews
                ? _selectedMyCategoryIndex == index
                    ? Color(0xff43a047)
                    : Color(0xff5AB75C)
                : _selectedCategoryIndex == index
                    ? Color(0xff43a047)
                    : Color(0xff5AB75C),
          ),
        ),
        onTap: () {
          setState(() {
            _isMyNews
                ? _selectedMyCategoryIndex = index
                : _selectedCategoryIndex = index;
            _resetNewsData();
          });
        },
      ),
    );
  }

  Widget _buildSelectedSubCategory() {
    return Visibility(
      child: Padding(
        padding: EdgeInsets.only(right: 15, left: 5),
        child: GestureDetector(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(),
              ), // remove 1

              Container(
                padding: EdgeInsets.only(right: 15, left: 15, top: 0),
                height: 40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _isMyNews
                          ? _selectedMyCategories.length > 0
                              ? (_selectedMyCategories[_selectedMyCategoryIndex]
                                          [_selectedMyCategoryIndex]
                                      ?.name ??
                                  "")
                              : ""
                          : _selectedCategories.length > 0
                              ? (_selectedCategories[_selectedCategoryIndex]
                                          [_selectedCategoryIndex]
                                      ?.name ??
                                  "")
                              : "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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

              Expanded(
                flex: 1,
                child: Container(),
              ), // remove 2
            ],
          ),
          onTap: () {
            setState(() {
//              _viewSubCategories = true;
              Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => NewsSubCategories(
                  _isMyNews
                      ? _myCategories.length > 0
                          ? (_myCategories[_selectedMyCategoryIndex]
                                  .subCategories ??
                              [])
                          : []
                      : _categories.length > 0
                          ? _categories[_selectedCategoryIndex].subCategories ??
                              []
                          : [],
                  this,
                  _getSelectedSubCategoryId(),
                  isNews: true,
                ),
              ));
            });
          },
        ),
      ),
      visible: _isMyNews
          ? _selectedMyCategories.length > 0
              ? true
              : false
          : _selectedCategories.length > 0
              ? true
              : false,
    );
  }

  Widget _buildNewsItem(int index) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 10),
          child: Container(
            height: 112,
//          width: 300,
//          padding: EdgeInsets.only(bottom: 5, right: 10, left: 10, top: 5),
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
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: _news[index].image != null
                      ? _news[index].image != ""
                          ? FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder_2.png',
                              imageErrorBuilder: (c, o, t) {
                                return Image.asset('assets/placeholder_2.png');
                              },
                              image: _news[index].image ?? "",
                              height: 110,
                              width: 110,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/placeholder_2.png',
                              height: 110,
                              width: 110,
                              fit: BoxFit.fill,
                            )
                      : Image.asset(
                          'assets/placeholder_2.png',
                          height: 110,
                          width: 110,
                          fit: BoxFit.fill,
                        ),
                ),
                Container(
                  width: width - 140,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10, left: 10, top: 12),
                        child: Align(
                          child: Text(
                            _news[index].title ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff43a047),
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      Align(
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: 10, left: 10, top: 12),
                          child: Text(
                            _news[index].date ?? "",
                            style: TextStyle(
                                color: Color(0xffb6b9c0), fontSize: 15),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  NewsDetails(_news[index].id ?? 0, false))),
    );
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

  Widget _buildNoData() {
    return Padding(
      padding: EdgeInsets.only(top: 60),
      child: NoData('لا يوجد أخبار'),
    );
  }

  Widget _buildNoInterests() {
    return Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
//          Image.asset('assets/eye-close-line.png'),
            Text(
              'حدد اخبارك المفضلة من هنا',
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
                  color: Color(0xffff5c46),
                ),
                child: Text(
                  'اختار اخبارك المفضلة',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Interests(
                            true,
                            this,
                            0,
                            updateInterestsNow: true,
                          ))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageNetworkError() {
    return Padding(
      padding: EdgeInsets.only(top: 60),
      child: NoNetwork(this),
    );
  }

  Widget _buildAdsView() {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, top: 5, bottom: 5),
      child: GestureDetector(
        child: Container(
          child: (ads?[0].images?.length ?? 0) > 0
              ? Image.network(
                  ads?[0].images?[viewedAdvIndex].large ?? "",
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
    if (ads?.isNotEmpty ?? false) {
      if (ApiUrls.RELEASE_MODE) {
        if (ads?[0].images?[viewedAdvIndex].title != null) {
          if (ads?[0].images?[viewedAdvIndex].title?.isNotEmpty ?? false) {
            FirebaseAnalytics analytics = FirebaseAnalytics.instance;
            analytics.logEvent(
              name: 'advertisements',
              parameters: <String, String>{
                'ad_name': ads?[0].images?[viewedAdvIndex].title ?? "",
              },
            );
          }
        }
      }
      if (ads?[0].images?[viewedAdvIndex].link != null) {
        if (await UrlLauncher.canLaunch(
            ads?[0].images?[viewedAdvIndex].link ?? "")) {
          await UrlLauncher.launch(ads?[0].images?[viewedAdvIndex].link ?? "");
        } else {
          print("can't launch");
        }
      }
    }
  }

  void _getAds() {
    if (LocalSettings.advertisements != null) {
      List<AdvertisementData>? ads =
          LocalSettings.advertisements?.advertisement;
      if (ads?.isNotEmpty ?? false) {
        for (AdvertisementData adv in ads ?? []) {
          if (adv.name == "list_news") {
            setState(() {
              if (adv.data?.isNotEmpty ?? false) {
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
      if (ads?.isNotEmpty ?? false) {
        if (ads?[0].image_duration != null) {
          duration = int.parse(ads?[0].image_duration ?? "0");
        }
        _timer = Timer.periodic(new Duration(seconds: duration), (timer) {
          if ((ads?[0].images?.length ?? 0) - 1 > viewedAdvIndex) {
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
  }

  bool _checkAdsTime(AdvertisementData adv) {
    final startTime = DateTime.parse(adv.data?[0].date_from ?? "2000-01-01");

    final endTime = DateTime.parse(adv.data?[0].date_to ?? "2000-01-01");

    final currentTime = DateTime.now();

    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      // do something
      print('valid date');
      return true;
    } else {
      return false;
    }
  }

  String _getSelectedSubCategoryId() {
    String selectedSubCategory = "";
    if (_isMyNews) {
      if (_selectedMyCategories.length > 0) {
        selectedSubCategory = _selectedMyCategories[_selectedMyCategoryIndex]
                    [_selectedMyCategoryIndex]
                ?.id ??
            "";
      }
    } else {
      if (_selectedCategories.length > 0) {
        selectedSubCategory = _selectedCategories[_selectedCategoryIndex]
                    [_selectedCategoryIndex]
                ?.id ??
            "";
      }
    }

    return selectedSubCategory;
  }

  void _changeNewsSelection(bool isMyNews) {
    setState(() {
      _isMyNews = isMyNews;
      _resetNewsData();
    });
  }

  void _resetNewsData() {
    print('_resetNewsData');
    _newsPage = 1;
    _news.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
    });
    if (_isMyNews) {
      if (!_isNoInterest) {
        _newsNetwork.getInterestsNews(
            _newsPage, _getSelectedSubCategoryId(), true, this);
      }
    } else {
      _newsNetwork.getNews(_newsPage, _getSelectedSubCategoryId(), true, this);
    }
  }

  _getMoreData() async {
    if (!_isNoMoreData) {
      if (!_isPerformingRequest && !_isloading) {
        setState(() => _isPerformingRequest = true);
        if (_isMyNews) {
          _newsNetwork.getInterestsNews(
              _newsPage, _getSelectedSubCategoryId(), false, this);
        } else {
          _newsNetwork.getNews(
              _newsPage, _getSelectedSubCategoryId(), false, this);
        }
      }
    }
  }

  void _sendAnalyticsEvent() {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    analytics.logEvent(name: 'news_list');
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
  void setCategories(CategoriesData? categoriesData) {
    if (categoriesData?.categories != null) {
      setState(() {
        this._categories = categoriesData?.categories ?? [];
        for (var i = 0; i < _categories.length; i++) {
          if (_categories[i].subCategories?.isNotEmpty ?? false) {
            Map<int, Category?> item = {i: _categories[i].subCategories?[0]};
            _selectedCategories.add(item);
          } else {
            this._categories[i].subCategories?.add(this._categories[i]);
            Map<int, Category> item = {i: _categories[i]};
            _selectedCategories.add(item);
          }
        }
      });
    }
    _isMyNews ? setMyCategories() : setAllCategories();
    if (_isMyNews) {
      print("selected_id$selected_id");

      if (!_isNoInterest) {
        _newsNetwork.getInterestsNews(
            _newsPage,
            LocalSettings.newsId != null
                ? LocalSettings.newsId.toString()
                : _getSelectedSubCategoryId(),
            true,
            this);
      }
    } else {
      _newsNetwork.getNews(_newsPage, _getSelectedSubCategoryId(), true, this);
    }
    print(_selectedCategories.length);
  }

//  void setMyCategories() {
//    List<Category> categoriesList = [];
//    categoriesList.addAll(_categories);
//    for (Category category in categoriesList) {
//      Category myCategory = Category();
//      myCategory.subCategories = [];
//      for (Category subCategory in category.subCategories) {
//        if (subCategory.selected) {
//          myCategory.subCategories.add(subCategory);
//        }
//      }
//      if (myCategory.subCategories.isNotEmpty) {
//        myCategory.id = category.id;
//        myCategory.name = category.name;
//        _myCategories.add(myCategory);
//      }
//    }
//    for (var i = 0; i < _myCategories.length; i++) {
//      if (_myCategories[i].subCategories.isNotEmpty) {
//        Map<int, Category> item = {i: _myCategories[i].subCategories[0]};
//        _selectedMyCategories.add(item);
//      } else {
//        this._myCategories[i].subCategories.add(this._myCategories[i]);
//        Map<int, Category> item = {i: _myCategories[i]};
//        _selectedMyCategories.add(item);
//      }
//    }
//    print('_selectedMyCategories');
//    if (_selectedMyCategories.isEmpty) {
//      setState(() {
//        _isNoInterest = true;
//      });
//    } else {
//      setState(() {
//        _isNoInterest = false;
//      });
//    }
//  }

  void setMyCategories() {
    List<Category> categoriesList = [];
    categoriesList.addAll(_categories);

    for (Category category in categoriesList) {
      // for (Category subCategory in category.subCategories) {
      List<Category> subcategoriesList = [];
      subcategoriesList = category.subCategories?.where((element) {
            return element.selected ?? false;
          }).toList() ??
          [];
      category.subCategories = subcategoriesList;
      if (subcategoriesList.length > 0) {
        _myCategories.add(category);
      }
    }
    for (var i = 0; i < _myCategories.length; i++) {
      Map<int, Category?> item = {i: _myCategories[i].subCategories?[0]};
      _selectedMyCategories.add(item);
    }

    print('_selectedMyCategories');
    if (_selectedMyCategories.isEmpty) {
      setState(() {
        _isNoInterest = true;
      });
    } else {
      setState(() {
        _isNoInterest = false;
      });
    }
  }

  void setAllCategories() {
    List<Category> categoriesList = [];
    categoriesList.addAll(_categories);

    for (Category category in categoriesList) {
      for (Category subCategory in category.subCategories ?? []) {
        //   List<Category> subcategoriesList = [];
        //   subcategoriesList= category.subCategories.where((element) {
        //     return  element.selected;
        //     }).toList();
        //   category.subCategories=subcategoriesList;
        if (subCategory.selected ?? false) {
          _myCategories.add(subCategory);
        }
      }
    }
    for (var i = 0; i < _myCategories.length; i++) {
      Map<int, Category> item = {i: _myCategories[i]};
      _selectedMyCategories.add(item);
    }

    print('_selectedMyCategories');
    if (_selectedMyCategories.isEmpty) {
      setState(() {
        _isNoInterest = true;
      });
    } else {
      setState(() {
        _isNoInterest = false;
      });
    }
  }

  @override
  void selectedSubCategory(Category category) {
    setState(() {
      print('selectedSubCategory');
      _viewSubCategories = false;
      if (_isMyNews) {
        _selectedMyCategories[_selectedMyCategoryIndex]
            [_selectedMyCategoryIndex] = category;
      } else {
        _selectedCategories[_selectedCategoryIndex][_selectedCategoryIndex] =
            category;
      }
      _resetNewsData();
    });
  }

  @override
  void setNews(NewsData? newsData) {
    _newsPage += 1;
    if (newsData?.news != null) {
      if (newsData?.news?.isEmpty ?? true) {
        setState(() {
          _isNoMoreData = true;
        });
      }
      setState(() {
        this._news.addAll(newsData?.news ?? []);
        _isPerformingRequest = false;
        _isNoNetwork = false;
      });
    }
//    this._news.clear();
    if (this._news.isEmpty) {
      _isNoData = true;
    } else {
      _isNoData = false;
    }
  }

  @override
  void reloadAction() {
    if (_categories.isEmpty) {
      _newsNetwork.getNewsCategories(this);
    } else {
      if (_isMyNews) {
        _newsNetwork.getInterestsNews(
            _newsPage, _getSelectedSubCategoryId(), true, this);
      } else {
        _newsNetwork.getNews(
            _newsPage, _getSelectedSubCategoryId(), true, this);
      }
    }
  }

  @override
  void addInterests() {
    //once success to add interest so we need to refresh news
    //reset data
    _newsPage = 1;
    _news.clear();
    _categories.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
    });
    // get categories
    _newsNetwork.getNewsCategories(this);
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

class NewsListSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  BuildContext? context;
  NewsListState newsList;
  bool isShowMyNewsOnly = false;
  NewsDeleagte newsDeleagte;

  NewsListSliverAppBar(
      {this.expandedHeight = 0,
      required this.newsList,
      required this.isShowMyNewsOnly,
      required this.newsDeleagte});

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
              Align(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, right: 0, top: 5),
                  child: IconButton(
                    icon: new Image.asset('assets/ic_search_white.png'),
//              onPressed: () => Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (BuildContext context) => Search('EVENTS'))),
                    onPressed: () => Navigator.of(context).push(
                        PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                Search('NEWS',
                                    isShowMyNewsOnly ? "user" : "all", null))),
                  ),
                ),
                alignment: Alignment.topLeft,
              ),
              LocalSettings.token != null
                  ? _buildNotificationIcon(
                      LocalSettings.notificationsCount != null
                          ? (LocalSettings.notificationsCount ?? 0) > 0
                              ? 'assets/ic_not_ac.png'
                              : 'assets/ic_not_nr.png'
                          : 'assets/ic_not_nr.png',
                    )
                  : SizedBox(),
            ]),
        Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: shrinkOffset > 90 ? 0 : 90,
//                right: shrinkOffset > 110 ? 0 : 0,
//                left: shrinkOffset > 110 ? 100 : 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                LocalSettings.token == null
                    ? SizedBox()
                    : Visibility(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            newsList._isMyNews
                                ? SizedBox()
                                : SizedBox(
                                    height: 20,
                                  ),
                            GestureDetector(
                              child: Text(
                                'أخباري',
                                style: TextStyle(
                                    color: newsList._isMyNews
                                        ? Colors.white
                                        : Color(0xffb1e6b1),
                                    fontSize: shrinkOffset > 90 ? 17 : 26,
                                    fontWeight: FontWeight.w700),
                              ),
                              onTap: () {
                                newsList._changeNewsSelection(true);
                              },
                            ),
                            Visibility(
                              child: Image.asset('assets/arrow_down_ic.png'),
                              visible: shrinkOffset < 90 && newsList._isMyNews,
                            )
                          ],
                        ),
                        visible: !isShowMyNewsOnly
                            ? false
                            : shrinkOffset > 90
                                ? newsList._isMyNews
                                    ? true
                                    : false
                                : true,
                      ),
                LocalSettings.token == null
                    ? SizedBox()
                    : SizedBox(
                        width: shrinkOffset > 90 ? 0 : 30,
                      ),
                Visibility(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      !newsList._isMyNews
                          ? SizedBox()
                          : SizedBox(
                              height: 20,
                            ),
                      GestureDetector(
                        child: Text(
                          'كل الأخبار',
                          style: TextStyle(
                              color: newsList._isMyNews
                                  ? Color(0xffb1e6b1)
                                  : Colors.white,
                              fontSize: shrinkOffset > 90 ? 17 : 26,
                              fontWeight: FontWeight.w700),
                        ),
                        onTap: () {
                          newsList._changeNewsSelection(false);
                        },
                      ),
                      Visibility(
                        child: Image.asset('assets/arrow_down_ic.png'),
                        visible: shrinkOffset < 90 && !newsList._isMyNews,
                      )
                    ],
                  ),
                  visible: isShowMyNewsOnly
                      ? false
                      : shrinkOffset > 90
                          ? !newsList._isMyNews
                              ? true
                              : false
                          : true,
                ),
              ],
            ),
          ),
        ),
        Visibility(
          child: Positioned.fill(
//            top: expandedHeight / 2 - shrinkOffset,
            top: 50,
            child: Opacity(
              opacity: (1 - shrinkOffset / (expandedHeight)),
              child: Align(
                child: GestureDetector(
                  child: Center(
                    child: Container(
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return newsList._buildCategoryItem(index);
                        },
                        itemCount: newsList._isMyNews
                            ? newsList._myCategories.length
                            : newsList._categories.length,
                        scrollDirection: Axis.horizontal,
                      ),
//                  child: _buildCategoryItem(),
                      height: 35,
                    ),
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          visible: shrinkOffset < 20 ? true : false,
        ),
        Visibility(
          child: Positioned.fill(
//            top: expandedHeight / 2 - shrinkOffset,
            top: newsList._isMyNews && newsList._isNoInterest ? 115 : 155,
            child: Opacity(
              opacity: (1 - shrinkOffset / (expandedHeight)),
              child: Center(
                child: newsList._isMyNews && newsList._isNoInterest
                    ? Text(
                        'لم تحدد اخبارك المفضلة بعد ..!',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    :
                    // newsList._isMyNews
                    //         ? SizedBox()
                    //         :

                    newsList._buildSelectedSubCategory(),
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
