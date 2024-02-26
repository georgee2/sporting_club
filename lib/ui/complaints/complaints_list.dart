import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/complaint.dart';
import 'package:sporting_club/data/model/complaints_data.dart';
import 'package:sporting_club/delegates/complaints_delegate.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/listeners/ComplaintsResponseListener.dart';
import 'package:sporting_club/network/repositories/complaints_netwrok.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_data.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'add_complaint.dart';
import 'complaint_details.dart';

class ComplaintsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ComplaintsListState();
  }
}

class ComplaintsListState extends State<ComplaintsList>
    implements
        ComplaintsResponseListener,
        NoNewrokDelagate,
        ComplaintsDelegate {
  bool _isloading = false;
  bool _isNoData = false;
  bool _isNoNetwork = false;
  bool _isNoMoreData = false;
  bool _isPerformingRequest = false;
  int _page = 1;

  List<Complaint> _complaints = [];
  ScrollController _scrollController = ScrollController();
  ComplaintsNetwork _complaintsNetwork = ComplaintsNetwork();

  @override
  void initState() {
    _complaintsNetwork.getComplaints(_page, true, this);
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('load more');
        _getMoreData();
      }
    });
    OneSignal.shared
        .setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent  notification) {
      print("setNotificationReceivedHandler in complain ${ notification.notification.additionalData}");
      Map<String, dynamic>? data = notification.notification.additionalData;


      if(data != null){
        if( data["type"].toString() == "complaint"){
          setState(() {
            _page = 1;
            _complaints.clear();
            _complaintsNetwork.getComplaints(_page, true, this);


          });
        }
      }


    });

  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: <Widget>[
            Container(
              color: Color(0xfff9f9f9),
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background_category.png"),
                  fit: BoxFit.fill,
                ),
              ),
              height: 210,
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                // <-- APPBAR WITH TRANSPARENT BG
                elevation: 0,
                leading: IconButton(
                  icon: new Image.asset('assets/back_white.png'),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                // <-- ELEVATION ZEROED
                automaticallyImplyLeading: true, // Used for removing back buttoon.
              ),
              body: SafeArea(
                child: _buildContent(),
              ),
            ),
            GestureDetector(
              child: Align(
                child: Padding(
                  padding: EdgeInsets.only(top: 140, left: 15),
                  child: Image.asset('assets/add_btn.png'),
                ),
                alignment: Alignment.topLeft,
              ),
              onTap: () => _addComplaint(),
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

  Widget _buildContent() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 60,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 20, top: 0, left: 10),
                      child: Align(
                        child: Text(
                          'الشكاوى والاراء',
                          style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 75,
              ),
              Flexible(
                child: _isNoNetwork || _isNoData
                    ? _isNoNetwork ? _buildImageNetworkError() : _buildNoData()
                    : ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          if (_isNoMoreData) {
                            return _buildComplaintsItem(index);
                          } else {
                            return index == _complaints.length
                                ? _buildProgressIndicator()
                                : _buildComplaintsItem(index);
                          }
                        },
                        itemCount: _isNoMoreData
                            ? _complaints.length
                            : _complaints.length + 1,
                        controller: _scrollController,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsItem(int index) {
    return Slidable(
      key:  UniqueKey(),
      // actionPane: SlidableDrawerActionPane(),
      // actionExtentRatio: 0.25,
// startActionPane: SlidableDrawerActionPane(),
      child: Container(
        color: Colors.white,
        child: GestureDetector(
            child: Center(
              child: Padding(
                padding:
                    EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 10),
                child: Container(
//            height: 110,
//          width: 300,
                  padding:
                      EdgeInsets.only(bottom: 10, right: 15, left: 15, top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.2),
                        blurRadius: 5.0,
                        // has the effect of softening the shadow
                        spreadRadius: 0.0,
                        // has the effect of extending the shadow
                        offset: Offset(
                          0.0, // horizontal, move right 10
                          0.0, // vertical, move down 10
                        ),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _complaints[index].id != null
                                ? "شكوى رقم  ${_complaints[index].id}"
                                : "",
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Color(0xff646464),
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        _complaints[index].content ?? "",
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Color(0xff646464),
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 10, left: 10),
                            height: 27,
                            child: Center(
                              child: Text(
                                _complaints[index].complaint_status != null
                                    ? getComplaintStatus(
                                        _complaints[index].complaint_status??"")
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color:
                                    _complaints[index].complaint_status != null
                                        ? getComplaintColor(
                                            _complaints[index].complaint_status??"")
                                        : Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              color: _complaints[index].complaint_status != null
                                  ? getComplaintColor(
                                      _complaints[index].complaint_status??"")
                                  : Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 0, left: 0, top: 0),
                            child: Text(
                              _complaints[index].date ??"",
                              style: TextStyle(
                                  color: Color(0xffb6b9c0), fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () async {
              var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ComplaintDetails(_complaints[index].id??0)));
              if (result != null) {
                _complaints.removeAt(index);
                hideLoading();
                // clearComplaints();
                // _complaintsNetwork.getComplaints(1, true, this);
              }
            }),
      ),
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {
          print("onDismissed");
        }),
        dragDismissible: false,
        // All actions are defined in the children parameter.
        children: _complaints[index].complaint_status == "done"
            ?
        [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (c){
              setState(() {
                showLoading();
                index_clicked = index;
                _complaintsNetwork.removeComplaintDetails(
                    _complaints[index].id??0, context, null, this);
              });
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            // label: 'done',
          ),

        ]:[],
      ),
      // actions: <Widget>[
      //   _complaints[index].complaint_status == "done"
      //       ?
      //   IconSlideAction(
      //       iconWidget: Image.asset('assets/notificcation_ic.png'),
      //       onTap: () {
      //         setState(() {
      //           showLoading();
      //          index_clicked = index;
      //           _complaintsNetwork.removeComplaintDetails(
      //               _complaints[index].id, context, null, this);
      //         });
      //       }):SizedBox(),
      // ],
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

  Widget _buildImageNetworkError() {
    return NoNetwork(this);
  }

  Widget _buildNoData() {
    return NoData('لم تقم بإرسال شكوى');
  }

  void _addComplaint() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AddComplaint(this)));
  }

  _getMoreData() async {
    if (!_isNoMoreData) {
      if (!_isPerformingRequest) {
        setState(() => _isPerformingRequest = true);
        _complaintsNetwork.getComplaints(_page, false, this);
      }
    }
  }

  String getComplaintStatus(String status) {
    if (status == "new") {
      return "جديدة";
    } else if (status == "in_progress") {
      return "قيد المراجعة";
    } else if (status == "done") {
      return "تم حلها";
    }
    return "";
  }

  Color getComplaintColor(String status) {
    if (status == "new") {
      return Color(0xffe21b1b);
    } else if (status == "in_progress") {
      return Color(0xffff5c46);
    } else if (status == "done") {
      return Color(0xff43a047);
    }
    return Color(0xff43a047);
  }
  int index_clicked = 0;

  void clearComplaints() {

    setState(() {
      _page = 1;
      _complaints.removeAt(index_clicked);
      hideLoading();
      // this._complaints.clear();
    });
  }

  @override
  void setComplaints(ComplaintsData? complaintsData) {
    if(_page==1){
      this._complaints.clear();
    }
    _page += 1;
    if (complaintsData?.complaints != null) {
      if (complaintsData?.complaints?.isEmpty??true) {
        setState(() {
          _isNoMoreData = true;
        });
      }
      setState(() {
        this._complaints.addAll(complaintsData?.complaints??[]);
        _isPerformingRequest = false;
        _isNoNetwork = false;
      });
    }
    if (this._complaints.isEmpty) {
      _isNoData = true;
    } else {
      _isNoData = false;
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
  void reloadAction() {
    _complaintsNetwork.getComplaints(_page, true, this);
  }

  @override
  void addComplaintSuccessfully() {
    setState(() {
      _complaints.clear();
      _page = 1;
      _isNoMoreData = false;
    });
    _complaintsNetwork.getComplaints(_page, true, this);
  }
}
