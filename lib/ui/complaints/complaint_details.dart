import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/data/model/complaint.dart';
import 'package:sporting_club/data/model/complaints_data.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/listeners/ComplaintDetailsResponseListener.dart';
import 'package:sporting_club/network/listeners/ComplaintsResponseListener.dart';
import 'package:sporting_club/network/listeners/NewsDetailsResponseListener.dart';
import 'package:sporting_club/network/repositories/complaints_netwrok.dart';
import 'package:sporting_club/network/repositories/news_network.dart';
import 'package:sporting_club/ui/restaurants/full_image.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ComplaintDetails extends StatefulWidget {
  int _complaintID = 0;

  ComplaintDetails(this._complaintID);

  @override
  State<StatefulWidget> createState() {
    return ComplaintDetailsState(this._complaintID);
  }
}

class ComplaintDetailsState extends State<ComplaintDetails>
    implements NoNewrokDelagate, ComplaintDetailsResponseListener {
  int _complaintID = 0;

  bool _isloading = false;
  bool _isNoNetwork = false;
  bool _isSuccess = false;

  Complaint _complaint = Complaint();
  ComplaintsNetwork _complaintsNetwork = ComplaintsNetwork();

  ComplaintDetailsState(this._complaintID);

  @override
  void initState() {
    print(_complaintID);
    _complaintsNetwork.getComplaintDetails(_complaintID, this);
    super.initState();

    OneSignal.shared
        .setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent  notification) {
      print("setNotificationReceivedHandler in complain details${ notification.notification.additionalData}");
      Map<String, dynamic>? data = notification.notification.additionalData;


      if(data != null){
        if( data["type"].toString() == "complaint") {
          if (data["post_id"] != null) {
            if (data["post_id"] == _complaintID) {
              setState(() {
                _complaint = Complaint(); //(
                this._complaintID = _complaintID;
                _isloading = true;
// )
                // showLoading();
                _complaintsNetwork.getComplaintDetails(_complaintID, this);
              });
            }
          }
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
          children: [
            Container(
              color: Color(0xfff5f5f5),
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/complaint_background.png"),
                  fit: BoxFit.fill,
                ),
              ),
              height: 200,
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                // <-- APPBAR WITH TRANSPARENT BG
                elevation: 0,
                actions: <Widget>[
                  _complaint.complaint_status == "done"
                      ? Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: InkWell(
                            onTap: () {
                              _complaintsNetwork.removeComplaintDetails(
                                  widget._complaintID, context, this, null);
                            },
                            child: Row(
                              children: <Widget>[
                                new Image.asset('assets/close_ic1.png'),
                               SizedBox(width: 8,),
                                Text(
                                  "مسح",
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            )),
                      )
                      : SizedBox(),
                ],
                leading: IconButton(
                  icon: new Image.asset('assets/back_white.png'),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                // <-- ELEVATION ZEROED
                automaticallyImplyLeading:
                    true, // Used for removing back buttoon.
              ),
              body: _isNoNetwork
                  ? _buildImageNetworkError()
                  : SafeArea(
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

  Widget _buildContent() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: _isSuccess
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: 0, top: 0, left: 0),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Align(
                          child: Text(
                            widget._complaintID != null
                                ? "شكوى رقم  ${widget._complaintID}"
                                : "",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                  ),
                ), Container(
                  child: Padding(
                    padding: EdgeInsets.only(right: 0, top: 0, left: 0),
                    child: Align(
                      child: Text(
                        _complaint.date ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.normal),
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 0, top: 15, left: 0),
                  child: _complaint.complaint_status != null
                      ? Center(
                          child: Container(
                          padding: EdgeInsets.only(right: 15, left: 15, top: 2),
                          height: 27,
                          child: Text(
                            _complaint.complaint_status != null
                                ? getComplaintStatus(
                                    _complaint.complaint_status??"")
                                : "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: _complaint.complaint_status != null
                                  ? getComplaintColor(
                                      _complaint.complaint_status??"")
                                  : Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            color: _complaint.complaint_status != null
                                ? getComplaintColor(_complaint.complaint_status??"")
                                : Colors.white,
                          ),
                        ))
                      : SizedBox(
                          height: 27,
                        ),
                ),
                SizedBox(
                  height: 55,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Card(
                          elevation:3,
                    shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: EdgeInsets.only(right: 10,  left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: EdgeInsets.only(
                                    right: 20, top: 15, left: 10),
                                child: Align(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'الجهة المختصة',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff03240a),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: 5, top: 0, left: 10),
                                        child: Align(
                                          child: Text(
                                            _complaint.administrative_name ?? "",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xff00701a),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          alignment: Alignment.centerRight,
                                        ),
                                      ),

                                    ],
                                  ),
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: 20, top: 15, left: 10),
                                child: Align(
                                  child: Text(
                                    _complaint.content ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff03240a),
                                      fontWeight: FontWeight.normal,

                                    ),
                                  ),
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              _complaint.image_url != null
                                  ? _complaint.image_url != ""
                                      ? _buildUploadedImage()
                                      : SizedBox()
                                  : SizedBox(),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(right: 20, top: 30, left: 10),
                          child: Align(
                            child: Text(
                              ( _complaint.complaint_comment != null&&  (_complaint.complaint_comment?.isNotEmpty??false)&&_complaint.complaint_status=="done")
                                  ?  'إجابة الجهة المختصة'
                                  : "",

                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff03240a),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20, top: 5, left: 10),
                          child: Align(
                            child: Text(
                              (_complaint.complaint_comment !=null&&
                              (_complaint.complaint_comment?.isNotEmpty??false))
                                  ? _complaint.complaint_comment??""
                                  : "",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff00701a),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget _buildUploadedImage() {
    return Stack(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(right: 15, top: 5),
            child: Align(
              child: GestureDetector(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: _complaint.image_url != null
                      ? FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder_2.png',
                          image: _complaint.image_url??"",
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        )
                      : Image.asset(
                          'assets/placeholder_2.png',
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        ),
                ),
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) =>
                        FullImage(_complaint.image_url??""),
                  ));
                },
              ),
              alignment: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
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

  Widget _buildImageNetworkError() {
    return NoNetwork(this);
  }

  @override
  void reloadAction() {
    _complaintsNetwork.getComplaintDetails(_complaintID, this);
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
  void setComplaint(Complaint? complaint) {
    setState(() {
      _complaint = complaint??Complaint();
      _isSuccess = true;
      _isNoNetwork = false;
    });
  }
}
