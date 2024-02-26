import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/interest.dart';
import 'package:sporting_club/data/model/interests_data.dart';
import 'package:sporting_club/data/model/trips/trips_interests.dart';
import 'package:sporting_club/delegates/interest_delegate.dart';
import 'package:sporting_club/delegates/interests_delegate.dart';
import 'package:sporting_club/delegates/news_delegate.dart';
import 'package:sporting_club/network/listeners/InterestsResponseListener.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/ui/home/home.dart';
import 'package:sporting_club/ui/news/news_sub_categories.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'news_interest_categories.dart';

class Interests extends StatefulWidget {
  bool isEdit = false;
  InterestsDeleagte? _interestsDeleagte;
  int _initialPage = 0;
  bool updateInterestsNow = false;

  Interests(this.isEdit, this._interestsDeleagte, this._initialPage,
      {this.updateInterestsNow = false});

  @override
  State<StatefulWidget> createState() {
    return InterestsState(
        this.isEdit, this._interestsDeleagte, this._initialPage);
  }
}

class InterestsState extends State<Interests>
    implements InterestsResponseListener, InterestDeleagte {
  ValueNotifier<int> _valueNotifier = ValueNotifier(0);
  bool _isloading = false;
  PageController? _controller;
  UserNetwork userNetwork = UserNetwork();
  InterestsDeleagte? _interestsDeleagte;

  int _initialPage = 0;

//  List<Interest> _values = [];
  List<Interest> _events = [];
  List<Interest> _teams = [];
  List<Interest> _news = [];
  List<String> _subNews = [];
  List<String> _subNewsSelected = [];

  bool _isOuterTrips = false;
  bool _isInnerTrips = false;
  String nextButtonImg = "assets/next_ic.png";
  bool isEdit = false;
  Map<String, dynamic>? _tags;
  bool _isSelectNews = false;
  ScrollController? _scrollController2;
  bool test = false;
  int index = 0;

  InterestsState(this.isEdit, this._interestsDeleagte, this._initialPage);

  @override
  void initState() {
    _controller =
        PageController(initialPage: this._initialPage, keepPage: false);
    _scrollController2 = new ScrollController(
      initialScrollOffset: 0.0,
      //keepScrollOffset: true,
    );

    super.initState();
    _valueNotifier = ValueNotifier(_initialPage);
    userNetwork.getInterests(this);
    _updateValueNotifier(_initialPage);
//    _getSavedTags();
  }

  void _getSavedTags() async {
    _tags = await OneSignal.shared.getTags();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Container(
              color: Color(0xfff5f5f5),
            ),
            Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/intersection_4.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                height: 270),
            isEdit
                ? _buildEditContent()
                : Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SafeArea(
                      child: _buildContent(),
                    ),
                  ),
          ],
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

  Widget _buildEditContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // <-- APPBAR WITH TRANSPARENT BG
        elevation: 0,

        leading: IconButton(
          icon: new Image.asset('assets/back_grey.png'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        // <-- ELEVATION ZEROED
        automaticallyImplyLeading: true, // Used for removing back buttoon.
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return new Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: <Widget>[
          Container(
            margin: new EdgeInsets.only(top: 20.0),
            child: Padding(
              child: widget.updateInterestsNow
                  ? getPageToUpdate(widget._initialPage)
                  : PageView.builder(
                      controller: _controller,
                      itemCount: 4,
                      //physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return NotificationListener(
                              onNotification: (t) {
                                if (t is ScrollEndNotification) {
                                  if (_scrollController2?.hasClients ?? false) {
                                    print(_scrollController2?.position.pixels);
                                    double height =
                                        MediaQuery.of(context).size.height;
                                    double? scrollOffset =
                                        _scrollController2?.offset;

                                    print("mmm${height}");
                                    print("ccccccccccccccc${scrollOffset}");

//                             if(_scrollController2?.position.pixels == 0 ||
//                                 _scrollController2?.position.pixels >=height/2-80 ) {
                                    this.index = 0;
                                    if (_scrollController2?.position.atEdge ??
                                        false) {
                                      setState(() {});
                                      print(
                                          "rrrrrrrrrrrrrr${_scrollController2?.position.pixels}");
                                    }

                                    print(
                                        "fff${_scrollController2?.position.pixels}");

                                    // }
                                    // if(_scrollController2?.position.pixels == 0)
                                  }
                                }
                                return true;
                              },
                              child: SingleChildScrollView(
                                  controller: _scrollController2,
                                  child: _buildPageItem(
                                      _news,
                                      'assets/news_intersets.png',
                                      'بتفضل إيه اكتر..',
                                      'اختر اخبارك المفضلة من خلال دوائر الاهتمامات الموجودة بالاسفل')));
                        } else if (index == 1) {
                          // if(_scrollController2?.hasClients??false)
                          //  _scrollController2?.animateTo(0.0, duration: null, curve: null);
                          return NotificationListener(
                              onNotification: (t) {
                                if (t is ScrollEndNotification) {
                                  if (_scrollController2?.hasClients ?? false) {
                                    print(_scrollController2?.position.pixels);
                                    double height =
                                        MediaQuery.of(context).size.height;
                                    print("mmm${height}");

                                    // if(_scrollController2?.position.pixels == 0 ||
                                    // _scrollController2?.position.pixels >=height/2-80 ) {
                                    print(
                                        "fff${_scrollController2?.position.pixels}");
                                    this.index = 0;

                                    if (_scrollController2?.position.atEdge ??
                                        false) {
                                      setState(() {});
                                    }
                                    //  }
                                    // if(_scrollController2?.position.pixels == 0)
                                  }
                                }
                                return true;
                              },
                              child: SingleChildScrollView(
                                  controller: _scrollController2,
                                  child: _buildPageItem(
                                      _teams,
                                      'assets/results_ic.png',
                                      'تابع نتائج الفرق',
                                      'اختر الفرق التي تريد متابعتها من خلال دوائر الاهتمامات الموجودة بالاسفل')));
                        } else if (index == 2) {
                          return SingleChildScrollView(
                              controller: _scrollController2,
                              child: _buildTripsPage(
                                  'assets/trip_ic.png',
                                  'متفوتش الرحلات',
                                  'اطلع معانا رحلات نادي سبورتنج من خلال دوائر الاهتمامات الموجودة بالاسفل'));
                        } else if (index == 3) {
                          return NotificationListener(
                              onNotification: (t) {
                                if (t is ScrollEndNotification) {
                                  if (_scrollController2?.hasClients ?? false) {
                                    print(_scrollController2?.position.pixels);
                                    double height =
                                        MediaQuery.of(context).size.height;
                                    print("mmm${height}");

                                    //   if(_scrollController2?.position.pixels == 0 ||
                                    //      _scrollController2?.position.pixels >=height/2-80 ) {
                                    print(
                                        "fff${_scrollController2?.position.pixels}");
                                    this.index = 0;

                                    if (_scrollController2?.position.atEdge ??
                                        false) {
                                      setState(() {});
                                    }
                                    //   }
                                    // if(_scrollController2?.position.pixels == 0)
                                  }
                                }
                                return true;
                              },
                              child: SingleChildScrollView(
                                  controller: _scrollController2,
                                  child: _buildPageItem(
                                      _events,
                                      'assets/events_ic.png',
                                      'فعاليات تهمك!',
                                      'تابع فعاليات نادي سبورتنج من خلال دوائر الاهتمامات الموجودة بالاسفل')));
                        }
                        return SizedBox();
                      },
                      onPageChanged: (value) {
                        if (!widget.updateInterestsNow) {
                          test = true;
                          _scrollController2 = new ScrollController(
                            initialScrollOffset: 0.0,
                            // keepScrollOffset: true,
                          );
                          // this.index = 10;
                          //  _scrollController2?.offset = 0;

                          //  _nextPageAction();
                          _updateValueNotifier(value);
                          this.index = 0;
                          setState(() {
                            if (_scrollController2?.hasClients ?? false)
                              _scrollController2?.animateTo(0.0,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease);
                          });
                        }
                      }),

              padding: index == 0
                  ? !(_scrollController2?.hasClients ?? false)
                      ? EdgeInsets.only(bottom: 0)
                      : (_scrollController2?.positions.length == 1 &&
                              _scrollController2?.position.pixels == 0)
                          ? EdgeInsets.only(bottom: 0)
                          : EdgeInsets.only(bottom: 70)
                  : EdgeInsets.only(bottom: 70), //////////
            ),
          ),
//          SizedBox(height:20),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white70,
              height: 70,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(bottom: 30, right: 20),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CirclePageIndicator(
                        dotSpacing: 10,
                        size: 15,
                        selectedSize: 15,
                        itemCount: 4,
                        dotColor: Color(0xffb6b9c0),
                        selectedDotColor: Color(0xffff5c46),
                        currentPageNotifier: _valueNotifier,
                      ),
                    ),
                  )),
                  Expanded(
                      child: GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 5, left: 20),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Image.asset(nextButtonImg),
                      ),
                    ),
                    onTap: _nextPageAction,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPageToUpdate(int pageIndex) {
    if (pageIndex == 0) {
      return NotificationListener(
          onNotification: (t) {
            if (t is ScrollEndNotification) {
              if (_scrollController2?.hasClients ?? false) {
                print(_scrollController2?.position.pixels);
                double height = MediaQuery.of(context).size.height;
                double? scrollOffset = _scrollController2?.offset;

                print("mmm${height}");
                print("ccccccccccccccc${scrollOffset}");

//                             if(_scrollController2?.position.pixels == 0 ||
//                                 _scrollController2?.position.pixels >=height/2-80 ) {
                this.index = 0;
                if (_scrollController2?.position.atEdge ?? false) {
                  setState(() {});
                  print("rrrrrrrrrrrrrr${_scrollController2?.position.pixels}");
                }

                print("fff${_scrollController2?.position.pixels}");

                // }
                // if(_scrollController2?.position.pixels == 0)
              }
            }
            return true;
          },
          child: SingleChildScrollView(
              controller: _scrollController2,
              child: _buildPageItem(
                  _news,
                  'assets/news_intersets.png',
                  'بتفضل إيه اكتر..',
                  'اختر اخبارك المفضلة من خلال دوائر الاهتمامات الموجودة بالاسفل')));
    } else if (pageIndex == 1) {
      // if(_scrollController2?.hasClients??false)
      //  _scrollController2?.animateTo(0.0, duration: null, curve: null);
      return NotificationListener(
          onNotification: (t) {
            if (t is ScrollEndNotification) {
              if (_scrollController2?.hasClients ?? false) {
                print(_scrollController2?.position.pixels);
                double height = MediaQuery.of(context).size.height;
                print("mmm${height}");

                // if(_scrollController2?.position.pixels == 0 ||
                // _scrollController2?.position.pixels >=height/2-80 ) {
                print("fff${_scrollController2?.position.pixels}");
                this.index = 0;

                if (_scrollController2?.position.atEdge ?? false) {
                  setState(() {});
                }
                //  }
                // if(_scrollController2?.position.pixels == 0)
              }
            }
            return true;
          },
          child: SingleChildScrollView(
              controller: _scrollController2,
              child: _buildPageItem(
                  _teams,
                  'assets/results_ic.png',
                  'تابع نتائج الفرق',
                  'اختر الفرق التي تريد متابعتها من خلال دوائر الاهتمامات الموجودة بالاسفل')));
    } else if (pageIndex == 2) {
      return SingleChildScrollView(
          controller: _scrollController2,
          child: _buildTripsPage('assets/trip_ic.png', 'متفوتش الرحلات',
              'اطلع معانا رحلات نادي سبورتنج من خلال دوائر الاهتمامات الموجودة بالاسفل'));
    } else if (pageIndex == 3) {
      return NotificationListener(
          onNotification: (t) {
            if (t is ScrollEndNotification) {
              if (_scrollController2?.hasClients ?? false) {
                print(_scrollController2?.position.pixels);
                double height = MediaQuery.of(context).size.height;
                print("mmm${height}");

                //   if(_scrollController2?.position.pixels == 0 ||
                //      _scrollController2?.position.pixels >=height/2-80 ) {
                print("fff${_scrollController2?.position.pixels}");
                this.index = 0;

                if (_scrollController2?.position.atEdge ?? false) {
                  setState(() {});
                }
                //   }
                // if(_scrollController2?.position.pixels == 0)
              }
            }
            return true;
          },
          child: SingleChildScrollView(
              controller: _scrollController2,
              child: _buildPageItem(
                  _events,
                  'assets/events_ic.png',
                  'فعاليات تهمك!',
                  'تابع فعاليات نادي سبورتنج من خلال دوائر الاهتمامات الموجودة بالاسفل')));
    }
    return SizedBox();
  }

  Widget _buildPageItem(
      List<Interest> values, String imageStr, String title, String desc) {
    // _scrollController2?.hasClients??false? _scrollController2?.animateTo(0.0, duration: null, curve: null):null;
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: isEdit ? 0 : 50,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(right: 20, top: 20, left: 10),
                    child: Column(
                      children: <Widget>[
                        Align(
                          child: Text(
                            title,
                            style: TextStyle(
                                fontSize: 30,
                                color: Color(0xff43a047),
                                fontWeight: FontWeight.w700),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text(
                            desc,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    )),
                flex: 2,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 50, left: 20),
                  child: Image.asset(
                    imageStr,
                    width: 90,
                    height: 90,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                flex: 1,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 50, bottom: 40, left: 10, right: 10),
            child: values.isEmpty ? SizedBox() : _buildTags(values),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsPage(String imageStr, String title, String desc) {
    double width = MediaQuery.of(context).size.width - 80;
    double height = MediaQuery.of(context).size.height;

    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: isEdit ? 0 : 50,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(right: 20, top: 20, left: 10),
                    child: Column(
                      children: <Widget>[
                        Align(
                          child: Text(
                            title,
                            style: TextStyle(
                                fontSize: 30,
                                color: Color(0xff43a047),
                                fontWeight: FontWeight.w700),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text(
                            desc,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    )),
                flex: 2,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 50, left: 20),
                  child: Image.asset(
                    imageStr,
                    width: 90,
                    height: 90,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                flex: 1,
              ),
            ],
          ),
          Container(
            height: height - 305,
            child: Padding(
              padding: EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Image.asset(
                      _isInnerTrips
                          ? "assets/inner_ac.png"
                          : "assets/inner_nr.png",
                      width: _isInnerTrips ? width / 2 + 8 : width / 2,
                      fit: BoxFit.fitWidth,
                    ),
                    onTap: () {
                      setState(() {
                        _isInnerTrips = !_isInnerTrips;
                      });
                    },
                  ),
                  GestureDetector(
                    child: Image.asset(
                      _isOuterTrips
                          ? "assets/outer_ac.png"
                          : "assets/outer_nr.png",
                      width: _isOuterTrips ? width / 2 + 10 : width / 2,
                      fit: BoxFit.fitWidth,
                    ),
                    onTap: () {
                      setState(() {
                        _isOuterTrips = !_isOuterTrips;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(List<Interest> values) {
    double height = MediaQuery.of(context).size.height;
    if (_valueNotifier.value == 0) {
      return Tags(
        alignment: WrapAlignment.end,
        itemCount: values.length,
        heightHorizontalScroll: height, // required
        itemBuilder: (int index) {
          final item = values[index];

          return GestureDetector(
              onTap: () {
                setState(() {
//              _viewSubCategories = true;
                  Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) =>
                        NewsSubCategories([], null, ""),
                  ));
                });
              },
              child:
                  // buildTags(item)
                  ActionChip(
                      elevation: 5,

                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title ?? "",
                            style: TextStyle(
                              color: Color(0xffb6b9c0),
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xffb6b9c0),
                          )
                        ],
                      ),
                      backgroundColor: Color(0xffeeeeee),
                      onPressed: () {
                        setState(() {
//              _viewSubCategories = true;
                          List<Interest> _subCategories = [];
                          //  for (Interest item in values[index]) {
                          for (Interest subcat in item.subCategories ?? []) {
                            _subCategories.add(Interest(
                              title: subcat.title,
                              id: subcat.id,
                              selected: subcat.selected,
                            ));
                            //   }
                          }

                          Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                NewsInterestCategories(
                                    _subCategories, this, _subNewsSelected),
                          ));
                        });
                        if (_valueNotifier.value == 0) {
//                  for (Interest sub in item.subCategories) {
//                    if (sub.selected) {
//                      _subNewsSelected.add(sub.id);
//                      _news[index].selected = true;
//                    }
//
//                  }

                          // _setNewsSelected(item);
                        } else if (_valueNotifier.value == 1) {
                          _setTeamsSelected(item);
                        } else if (_valueNotifier.value == 3) {
                          _setEventsSelected(item);
                        }
                      }));
        },
      );
    } else {
      return Tags(
        alignment: WrapAlignment.end,
        itemCount: values.length,
        heightHorizontalScroll: height, // required
        itemBuilder: (int index) {
          final item = values[index];
          return ActionChip(
            elevation: 3,
            label: Text(
              item.title ?? "",
              style: TextStyle(
                color:
                    (item.selected ?? false) ? Colors.white : Color(0xffb6b9c0),
                fontSize: 14,
              ),
            ),
            backgroundColor: (item.selected ?? false)
                ? Color(0xff76d275)
                : Color(0xffeeeeee),
            padding: EdgeInsets.all(5),
            onPressed: () {
              if (_valueNotifier.value == 0) {
                _setNewsSelected(item);
              } else if (_valueNotifier.value == 1) {
                _setTeamsSelected(item);
              } else if (_valueNotifier.value == 3) {
                _setEventsSelected(item);
              }
            },
          );
        },
      );
    }
  }

  buildTags(item) {
    if (_valueNotifier.value == 0) {
      return ItemTags(
        key: Key(index.toString()),
        index: index,
        activeColor:
            (item.selected ?? false) ? Color(0xffeeeeee) : Color(0xffeeeeee),
        color: Color(0xffeeeeee),
        textActiveColor:
            (item.selected ?? false) ? Color(0xffb6b9c0) : Color(0xffb6b9c0),
        textColor: Color(0xffb6b9c0),
        border: Border.all(color: Colors.transparent),
        // required
        title: item.title ?? "",
        icon: ItemTagsIcon(
          icon: Icons.arrow_drop_down,
        ),
        active: (item.selected ?? false),
        textStyle: TextStyle(
          fontSize: 14,
        ),

        combine: ItemTagsCombine.withTextBefore,
        onPressed: (value) {
          setState(() {
//              _viewSubCategories = true;
            List<Interest> _subCategories = [];
            //  for (Interest item in values[index]) {
            for (Interest subcat in item.subCategories ?? []) {
              _subCategories.add(Interest(
                title: subcat.title,
                id: subcat.id,
                selected: subcat.selected,
              ));
              //   }
            }

            Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) =>
                  NewsInterestCategories(
                      _subCategories, this, _subNewsSelected),
            ));
          });
          if (_valueNotifier.value == 0) {
//                  for (Interest sub in item.subCategories) {
//                    if (sub.selected) {
//                      _subNewsSelected.add(sub.id);
//                      _news[index].selected = true;
//                    }
//
//                  }

            // _setNewsSelected(item);
          } else if (_valueNotifier.value == 1) {
            _setTeamsSelected(item);
          } else if (_valueNotifier.value == 3) {
            _setEventsSelected(item);
          }
        },
        onLongPressed: (item) => print(item),
      );
    }

    return ItemTags(
      key: Key(index.toString()),
      index: index,
      activeColor: Color(0xff76d275),
      color: Color(0xffeeeeee),
      textActiveColor: Colors.white,
      textColor: Color(0xffb6b9c0),
      border: Border.all(color: Colors.transparent),
      // required
      title: item.title ?? "",
      active: item.selected ?? false,
      textStyle: TextStyle(
        fontSize: 14,
      ),
      padding: EdgeInsets.all(5),
      combine: ItemTagsCombine.withTextBefore,
      onPressed: (value) {
        if (_valueNotifier.value == 0) {
          _setNewsSelected(item);
        } else if (_valueNotifier.value == 1) {
          _setTeamsSelected(item);
        } else if (_valueNotifier.value == 3) {
          _setEventsSelected(item);
        }
      },
      onLongPressed: (item) => print(item),
    );
  }

  void _setNewsSelected(Interest item) {
    for (var i = 0; i < _news.length; i++) {
      if (item.id == _news[i].id) {
        if (_news[i].selected ?? false) {
          setState(() {
            _news[i].selected = false;
          });
        } else {
          setState(() {
            _news[i].selected = true;
          });
        }
        return;
      }
    }
  }

  void _setTeamsSelected(Interest item) {
    for (var i = 0; i < _teams.length; i++) {
      if (item.id == _teams[i].id) {
        if (_teams[i].selected ?? false) {
          setState(() {
            _teams[i].selected = false;
          });
        } else {
          setState(() {
            _teams[i].selected = true;
          });
        }
        return;
      }
    }
  }

  void _setEventsSelected(Interest item) {
    for (var i = 0; i < _events.length; i++) {
      if (item.id == _events[i].id) {
        if (_events[i].selected ?? false) {
          setState(() {
            _events[i].selected = false;
          });
        } else {
          setState(() {
            _events[i].selected = true;
          });
        }
        return;
      }
    }
  }

  void _updateValueNotifier(int i) {
    setState(() {
      if (!widget.updateInterestsNow) {
        _valueNotifier.value = i;
      }
      if (i == 3 || widget.updateInterestsNow) {
        nextButtonImg = 'assets/done.png';
      } else {
        nextButtonImg = 'assets/next_ic.png';
      }
      index == 0;
//      if(i == 0){
//        _values.addAll(_news);
//      }else if(i == 1) {
//        _values.addAll(_teams);
//      }else if(i == 2) {
//        _values.addAll(_events);
//      }
    });
  }

  void _nextPageAction() {
    if (!widget.updateInterestsNow) {
      setState(() {
        _controller?.animateToPage(_valueNotifier.value + 1,
            duration: Duration(milliseconds: 300), curve: Curves.linear);
      });
    }
    if (_valueNotifier.value == 3 || widget.updateInterestsNow) {
      userNetwork.updateInterests(
          _getSelectedIds(_teams),
          _getSelectedIds(_events),
          // _getSelectedNewsIds(_subNews),
          _getSelectedNewsIds(_subNewsSelected),
          _getSelectedTrips(),
          this);
    }
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

  String _getSelectedNewsIds(List<String> values) {
    String ids = "";
    for (String value in values) {
      ids += value + ",";
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
    return trips;
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
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(
        msg: "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
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
  void setInterests(InterestsData? data) {
    setState(() {
      if (data?.events != null) {
        _events.addAll(data?.events ?? []);
      }
      print(_events.length);
      if (data?.news != null) {
        _news.addAll(data?.news ?? []);

        for (Interest item in data?.news ?? []) {
          for (Interest sub in item.subCategories ?? []) {
            if (sub.selected ?? false) {
              _subNewsSelected.add(sub.id ?? "");
              _subNews.add(sub.id ?? "");
              item.selected = true;
            }
          }
        }
      }
      print("hhh" + _news.length.toString());

      if (data?.teams != null) {
        _teams.addAll(data?.teams ?? []);
      }
      print(_teams.length);
      if (data?.trips != null) {
        for (TripsInterest trip in data?.trips ?? []) {
          if (trip.value != null) {
            if (trip.value == "inner" && trip.selected != null) {
              _isInnerTrips = trip.selected ?? false;
            } else if (trip.value == "outer" && trip.selected != null) {
              _isOuterTrips = trip.selected ?? false;
            }
          }
        }
      }
    });
  }

  @override
  void showUpdateSuccess() {
    print('success update');
//    _saveTagsInOneSignal();

    _saveNewInterests();
    if (isEdit) {
      if (_interestsDeleagte != null) {
        _interestsDeleagte?.addInterests();
      }
      Navigator.of(context).pop(null);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => Home()),
          (Route<dynamic> route) => false);
    }
  }

  void _saveNewInterests() {
    List<String> interests = [];
    if (_getSelectedIds(_news).isNotEmpty) {
      interests.add('news');
    }
    if (_getSelectedIds(_teams).isNotEmpty) {
      interests.add('teams');
    }
    if (_getSelectedIds(_events).isNotEmpty) {
      interests.add('events');
    }
    if (_getSelectedTrips().isNotEmpty) {
      interests.add('trips');
    }
    print(interests.toString());
    LocalSettings _localSettings = LocalSettings();
    _localSettings.setInterests(interests);
    LocalSettings.interests = interests;
  }

  void _saveTagsInOneSignal() async {
    Map<String, dynamic> _newTags = Map<String, dynamic>();

    for (Interest value in _events) {
      if (value.selected ?? false) {
        _newTags["event_${value.id}"] = value.id;
      }
    }

    for (Interest value in _teams) {
      if (value.selected ?? false) {
        _newTags["team_${value.id}"] = value.id;
      }
    }

    for (Interest value in _news) {
      if (value.selected ?? false) {
        _newTags["new_${value.id}"] = value.id;
      }
    }

    LocalSettings.newTags = _newTags;
    if (LocalSettings.savedTags != null) {
      //delete all keys
      Map values = await OneSignal.shared
          .deleteTags(LocalSettings.savedTags?.keys.toList() ?? []);
      print(values);
      Map newValues =
          await OneSignal.shared.sendTags(LocalSettings.newTags ?? {});
      print(newValues);
    }
  }

  @override
  void selectedNewsInterests(
      List<Interest> interests, List<String> _selectedSubcategoryId) {
    //_subNews.clear();

    _subNews = _selectedSubcategoryId;
    _subNewsSelected = _selectedSubcategoryId;
    print("interest" + interests.length.toString());

//  if (_news != null) {
//    print("interest"+"here");
//
//    for (Interest item in _news) {
//      for (String sub in _selectedSubcategoryId) {
//        print("interest"+sub);
//        print("interest"+item.id);
//        for (Interest subInterest in item.subCategories) {
//          if (sub == subInterest.id) {
//            item.selected = true;
//            print("interest" + "here");
//          }
//        }
//      }
//    }
//  }

//      for (Interest sub in _news) {
//    for (Interest item in interests) {
//      print("1");
//      if (sub.subCategories.contains(item)) {
//        print("1"+item.title);
//
//        item.selected = true;
//        sub.subCategories.remove(item);
//        sub.subCategories.add(item);
//        print("1"+_news[0].subCategories[0].title);
//
//      }
//    }
//  }
//    _subNewsSelected.addAll(_selectedSubcategoryId);

//    for(Interest item in _subNews ){
//      print(item.title + "------");
//    }
  }

  @override
  void dispose() {
    _scrollController2?.dispose();
    super.dispose();
  }
}
