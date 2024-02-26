import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/event.dart';
import 'package:sporting_club/data/model/offer.dart';
import 'package:sporting_club/data/model/offers_data.dart';
import 'package:sporting_club/data/model/trips/trip.dart';
import 'package:sporting_club/data/model/trips/trips_data.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/delegates/reload_trips_delegate.dart';
import 'package:sporting_club/network/listeners/SearchResponseListener.dart';
import 'package:sporting_club/network/repositories/search_network.dart';
import 'package:sporting_club/ui/events/event_details.dart';
import 'package:sporting_club/ui/news/news_details.dart';
import 'package:sporting_club/ui/offers_services/offer_service_details.dart';
import 'package:sporting_club/ui/trips/trip_details.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl/intl.dart' as intl;

class Search extends StatefulWidget {
  String _type = "";
  ReloadTripsDelagate? _reloadTripsDelagate;
  String search_from = "";

  Search(
    this._type,
      this.search_from,
      this._reloadTripsDelagate,

  );

  @override
  State<StatefulWidget> createState() {
    return SearchState(
      this._type,
        this.search_from,
      this._reloadTripsDelagate


    );
  }
}

class SearchState extends State<Search>
    implements SearchResponseListener, NoNewrokDelagate {
  bool _isloading = false;
  ReloadTripsDelagate? _reloadTripsDelagate;
  String search_from = "";


  final _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  SearchNetwork _searchNetwork = SearchNetwork();

  List<Offer> _items = [];
  List<Event> _events = [];
  List<Trip> _trips = [];
  String _searchText = "";

  //'OFFERS'for offers search ... 'SERVICES' for services search .. 'EVENTS' for events search .. 'NEWS' for news search .. 'TRIPS' for trips search
  String _type = "";

  int _page = 1;

  bool _isNoMoreData = false;
  bool _isNoNetwork = false;
  bool _isNoData = false;
  bool _isPerformingRequest = false;

  SearchState(
    this._type,
    this.search_from, ReloadTripsDelagate? reloadTripsDelagate,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        _getMoreData();
      }
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: _buildSearchField(),
            actions: <Widget>[
              IconButton(
                icon: _searchText.isEmpty
                    ? Image.asset('assets/search_black.png')
                    : Image.asset('assets/close_black.png'),
                onPressed: () {
                  setState(() {
                    if (_searchText.isNotEmpty) {
                      _searchController.text = "";
                      _searchText = "";
                      _resetSearchData();
                    }
                  });
                },
              ),
            ],
            leading: IconButton(
              icon: new Image.asset('assets/back_black.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        width: width,
//        height: height,
        color: Color(0xfff9f9f9),
        child: _searchText.isEmpty ? _buildEmptySearch() : _checkView(),
      ),
    );
  }

  Widget _checkView() {
    if (_isNoNetwork) {
      return _buildImageNetworkError();
    } else if (_isNoData) {
      return _buildNoData();
    } else {
      return _buildSearchList();
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: TextStyle(fontSize: 17, color: Color(0xff43a047)),
      maxLines: 1,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: new InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
//                contentPadding:
//                EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 8),
        hintText: 'بحث',
      ),
      keyboardType: TextInputType.text,
      keyboardAppearance: Brightness.light,
      onChanged: (value) {
        setState(() {
          if (value == "") {
            _resetSearchData();
          }
          _searchText = value;
        });
      },
      onSubmitted: (value) => _searchAction(),
    );
  }

  Widget _buildEmptySearch() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfff9f9f9),
        image: DecorationImage(
            image: AssetImage("assets/search_backgound.png"),
            fit: BoxFit.cover),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/search-eye-line.png'),
            SizedBox(
              height: 15,
            ),
            Text(
              'قم بالبحث هنا',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchList() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        if (_isNoMoreData) {
          return _type == "EVENTS"
              ? _buildEventItem(index)
              : _type == "TRIPS"
                  ? _buildTripsItem(index)
                  : _buildSearchItem(index);
        } else {
          return _type == "EVENTS"
              ? index == _events.length
                  ? _buildProgressIndicator()
                  : _buildEventItem(index)
              : _type == "TRIPS"
                  ? index == _trips.length
                      ? _buildProgressIndicator()
                      : _buildTripsItem(index)
                  : index == _items.length
                      ? _buildProgressIndicator()
                      : _buildSearchItem(index);
        }
      },
      itemCount: _type == "EVENTS"
          ? _isNoMoreData ? _events.length : _events.length + 1
          : _type == "TRIPS"
              ? _isNoMoreData ? _trips.length : _trips.length + 1
              : _isNoMoreData ? _items.length : _items.length + 1,
      controller: _scrollController,
    );
  }

  Widget _buildSearchItem(int index) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              right: 10, left: 10, top: index == 0 ? 30 : 5, bottom: 10),
          child: Container(
            height: 110,
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
                  child: _items[index].image != null
                      ? _items[index].image != ""
                          ? FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder_2.png',
                              image: _items[index].image??"",
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10, left: 10, top: 12),
                        child: Align(
                          child: Text(
                            _items[index].title?? "",
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
                          padding: EdgeInsets.only(
                              right: 10, left: 10, top: 12, bottom: 5),
                          child: Text(
                            _items[index].date ?? "",
                            style: TextStyle(
                                color: Color(0xffb6b9c0), fontSize: 15),
                          ),
                        ),
                        alignment: Alignment.bottomRight,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onTap: () => _navigateToDetails(index),
    );
  }

  Widget _buildEventItem(int index) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              right: 10, left: 10, top: index == 0 ? 25 : 5, bottom: 10),
          child: Container(
            height: 100,
//          width: width - 20,
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
                SizedBox(
                  width: 15,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/calender.png',
                        ),
                        Text(
                          _events[index].date ?? "",
                          style: TextStyle(color: Colors.white, fontSize: 26),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Text(
                            _events[index].date_month ??"",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      _events[index].date_day ??"",
                      style: TextStyle(
                          color: Color(0xff43a047),
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  width: width - 100,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: Align(
                      child: Text(
                        _events[index].title ??"",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xff646464),
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      alignment: Alignment.topRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () => _navigateToDetails(index),
    );
  }

  Widget _buildTripsItem(int index) {
    double width = MediaQuery.of(context).size.width;

    String startDay = "";
    String startMonth = "";
    if (_trips[index].start_date != null) {
      intl.DateFormat dateFormat = intl.DateFormat("dd-MM-yyyy");
      DateTime dateTime = dateFormat.parse(_trips[index].start_date??"2000-01-01");
      startDay = intl.DateFormat.d('en_US').format(dateTime);
      print(startDay);
      startMonth = intl.DateFormat.MMMM('ar_EG').format(dateTime);
      print(startMonth);
    }

    return GestureDetector(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
              right: 10, left: 10, top: index == 0 ? 30 : 5, bottom: 10),
          child: Container(
            height: 120,
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
                Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      child: _trips[index].image != null
                          ? _trips[index].image?.medium != null
                              ? FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder_2.png',
                                  image: _trips[index].image?.medium??"",
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/placeholder_2.png',
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.fill,
                                )
                          : Image.asset(
                              'assets/placeholder_2.png',
                              height: 120,
                              width: 120,
                              fit: BoxFit.fill,
                            ),
                    ),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Image.asset(
                          'assets/calendar_label_2.png',
                          height: 50,
                          width: 50,
                          fit: BoxFit.fill,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            startMonth,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: Text(
                            startDay,
                            style: TextStyle(
                                color: Color(0xff43a047),
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: width - 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10, left: 10, top: 12),
                        child: Align(
                          child: Text(
                            _trips[index].name??"",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff43a047),
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Align(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 10, left: 10, top: 0, bottom: 5),
                                  child: Text(
                                    "اﻷماكن المتاحة",
                                    style: TextStyle(
                                        color: Color(0xff76d275),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                              ),
                              Align(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 10, left: 10, top: 0, bottom: 0),
                                  child: Text(
                                    _trips[index].available_seats != null
                                        ? _trips[index]
                                            .available_seats
                                            .toString()
                                        : "",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                              )
                            ],
                          ),
                          _trips[index].waiting_list_count != null
                              ? _trips[index].waiting_list_count != 0
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Align(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 10,
                                                left: 10,
                                                top: 0,
                                                bottom: 5),
                                            child: Text(
                                              "قائمة الانتظار",
                                              style: TextStyle(
                                                  color: Color(0xffff5c46),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          alignment: Alignment.centerRight,
                                        ),
                                        Align(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 10,
                                                left: 10,
                                                top: 0,
                                                bottom: 0),
                                            child: Text(
                                              _trips[index]
                                                  .waiting_list_count
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          alignment: Alignment.centerRight,
                                        )
                                      ],
                                    )
                                  : SizedBox()
                              : SizedBox(),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 10, left: 10, top: 0, bottom: 5),
                              child: Text(
                                "انتهاء الحجز",
                                style: TextStyle(
                                    color: Color(0xffb6b9c0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            alignment: Alignment.centerRight,
                          ),
                          Align(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: 10, left: 10, top: 0, bottom: 5),
                              child: Text(
                                _trips[index].booking_end_date?? "",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            ),
                            alignment: Alignment.centerRight,
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          settings: RouteSettings(name: 'TripDetails'),
          builder: (context) =>
              TripDetails(_trips[index].id??0, _reloadTripsDelagate, false))),
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
    String title = "";
    switch (_type) {
      case 'OFFERS':
        title = 'لا يوجد عروض';
        break;
      case 'SERVICES':
        title = 'لا توجد خدمات';
        break;
      case 'EVENTS':
        title = 'لا توجد فعاليات';
        break;
      case 'NEWS':
        title = 'لا توجد أخبار';
        break;
      case 'TRIPS':
        title = 'لا توجد رحلات';
        break;
    }
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfff9f9f9),
      ),
      child: NoData(title),
    );
  }

  Widget _buildImageNetworkError() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfff9f9f9),
      ),
      child: NoNetwork(this),
    );
  }

  _getMoreData() async {
    if (!_isNoMoreData) {
      if (!_isPerformingRequest && !_isloading) {
        setState(() => _isPerformingRequest = true);

        switch (_type) {
          case 'OFFERS':
            _searchNetwork.searchOffers(
                _searchController.text, _page, false, this);
            break;
          case 'SERVICES':
            _searchNetwork.searchServices(
                _searchController.text, _page, false, this);
            break;
          case 'EVENTS':
            _searchNetwork.searchEvents(
                _searchController.text, _page, false, this);
            break;
          case 'TRIPS':
            _searchNetwork.searchTrips(
                _searchController.text, _page, false, this);
            break;
          case 'NEWS':
            _searchNetwork.searchNews(
                _searchController.text, _page, search_from ,false, this);
            break;
        }
      }
    }
  }

  void _navigateToDetails(int index) {
    switch (_type) {
      case 'OFFERS':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    OfferServiceDetails(_items[index].id??0, true)));
        break;
      case 'SERVICES':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    OfferServiceDetails(_items[index].id??0, false)));
        break;
      case 'EVENTS':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    EventDetails(_events[index].id??"0")));
        break;
      case 'TRIPS':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => TripDetails(
                    _trips[index].id??0, _reloadTripsDelagate, false)));
        break;
      case 'NEWS':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    NewsDetails(_items[index].id??0,false)));
        break;
    }
  }

  void _resetSearchData() {
    print('resetSearchData');
    _page = 1;
    _items.clear();
    _events.clear();
    _trips.clear();
    setState(() {
      _isPerformingRequest = false;
      _isNoMoreData = false;
      _isNoData = false;
      _isNoNetwork = false;
    });
  }

  void _searchAction() {
    _resetSearchData();
    if (_searchController.text.isNotEmpty) {
      switch (_type) {
        case 'OFFERS':
          _searchNetwork.searchOffers(
              _searchController.text, _page, true, this);
          break;
        case 'SERVICES':
          _searchNetwork.searchServices(
              _searchController.text, _page, true, this);
          break;
        case 'EVENTS':
          print('search events');
          _searchNetwork.searchEvents(
              _searchController.text, _page, true, this);
          break;
        case 'TRIPS':
          print('search TRIPS');
          _searchNetwork.searchTrips(_searchController.text, _page, true, this);
          break;
        case 'NEWS':
          _searchNetwork.searchNews(_searchController.text, _page,search_from, true, this);
          break;
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
  void setData(List<Offer>? data) {
    _page += 1;
    if (data?.isEmpty??false) {
      setState(() {
        _isNoMoreData = true;
      });
    }
    setState(() {
      this._items.addAll(data??[]);

      _isPerformingRequest = false;
      _isNoNetwork = false;
    });

    if (this._items.isEmpty) {
      _isNoData = true;
    } else {
      _isNoData = false;
    }
  }

  @override
  void reloadAction() {
    switch (_type) {
      case 'OFFERS':
        _searchNetwork.searchOffers(_searchController.text, _page, true, this);
        break;
      case 'SERVICES':
        _searchNetwork.searchServices(
            _searchController.text, _page, true, this);
        break;
      case 'EVENTS':
        _searchNetwork.searchEvents(_searchController.text, _page, true, this);
        break;
      case 'TRIPS':
        _searchNetwork.searchTrips(_searchController.text, _page, true, this);
        break;
      case 'NEWS':
        _searchNetwork.searchNews(_searchController.text, _page, search_from,true, this);
        break;
    }
  }

  @override
  void setEvents(List<Event>? events) {
    _page += 1;
    if (events?.isEmpty??true) {
      setState(() {
        _isNoMoreData = true;
      });
    }
    setState(() {
      this._events.addAll(events??[]);

      _isPerformingRequest = false;
      _isNoNetwork = false;
    });

    if (this._events.isEmpty) {
      _isNoData = true;
    } else {
      _isNoData = false;
    }
  }

  @override
  void setTrips(TripsData? tripsData) {
    _page += 1;
    if (tripsData?.trips != null) {
      if (tripsData?.trips?.isEmpty??true) {
        setState(() {
          _isNoMoreData = true;
        });
      }
      setState(() {
        this._trips.addAll(tripsData?.trips??[]);

        _isPerformingRequest = false;
        _isNoNetwork = false;
      });

      if (this._trips.isEmpty) {
        _isNoData = true;
      } else {
        _isNoData = false;
      }
    }
  }
}
