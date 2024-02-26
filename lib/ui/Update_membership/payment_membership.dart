import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/Badge.dart';
import 'package:sporting_club/data/model/Box.dart';
import 'package:sporting_club/data/model/Payment.dart';
import 'package:sporting_club/data/model/data_payment.dart';
import 'package:sporting_club/data/model/online_membership_payment.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/delegates/success_payment_delegate.dart';
import 'package:sporting_club/network/listeners/PaymentMembershipResponseListener.dart';
import 'package:sporting_club/network/listeners/PaymentResponseListener.dart';
import 'package:sporting_club/network/listeners/RegisterMembershipListener.dart';
import 'package:sporting_club/network/repositories/payment_network.dart';
import 'package:sporting_club/network/repositories/user_network.dart';
import 'package:sporting_club/utilities/local_settings.dart';

import '../../data/model/trips/Locker.dart';
import 'online_web_membership_payment.dart';

class PaymentMembership extends StatefulWidget {
  // BookingRequest _bookingRequest = BookingRequest();
  double screenWidth = 0;

  //ReloadTripsDelagate _reloadTripsDelagate;
  // bool _isFromPushNotification = false;
  PaymentData _paymentData;
  String? _serverMessage;
  List<Badge> badges = [];
  String _code;

  PaymentMembership(this._paymentData, this._serverMessage, this._code);

  @override
  State<StatefulWidget> createState() {
    return PaymentMembershipState(this._paymentData, this._code);
  }
}

class PaymentMembershipState extends State<PaymentMembership>
    implements
        RegisterMembershipListener,
        PaymentMembershipResponseListener,
        SuccessPaymentDelegate,
        PaymentResponseListener {
  bool _isloading = false;

  UserNetwork userNetwork = UserNetwork();
  PaymentNetwork paymentNetwork = PaymentNetwork();

  PaymentData _paymentData;
  User user = User();
  bool _hasPaidBadge = false;
  double total = 0.00;
  double total_fees = 0.00;
  double totalBoxesLockers = 0.00;
  bool show_items = true;
  bool from_badge = false;
  int index = 0;
  int index_serv = 0;

  String serv_count = "true";
  String _code;

  PaymentMembershipState(this._paymentData, this._code);

  //Timer timer;

  @override
  void initState() {
    super.initState();
    if (LocalSettings.user != null) {
      this.user = LocalSettings.user ?? User();
    }
    print("showitems${show_items}");

    if (_paymentData.dataOPayment != null) {
      if (_paymentData.dataOPayment?.items == null) {
        show_items = false;
        serv_count = "false";
      }
      if (_paymentData.dataOPayment?.annual_subscription != null &&
          show_items) {
        total = double.parse(
            _paymentData.dataOPayment?.annual_subscription.toString() ?? "0.0");
        total_fees = _paymentData.dataOPayment?.total_after_fees;
        totalBoxesLockers = _paymentData.member?.totalBoxesLockers ?? 0;
      } else {
        total = 0.00;
        total_fees = 0.00;
        totalBoxesLockers = 0.00;
      }
    }
//    if (_paymentData.case_member != null) {
//      print("hrtrt");
//      if(_paymentData.case_member == "case_processing"){
//        print("hrtrt");
//
//        timer = Timer.periodic(Duration(seconds: 60), (Timer t) => checkForNewStaus());
//      }else{
//     if(timer != null){
//        timer.cancel();
//
//       }
//
//      }
//      //
//    }else{
//      if(timer != null){
//        timer.cancel();
//
//      }
    //  }

    // print("here"+_paymentData.dataOPayment.unpaidCars.length.toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "تجديد الاشتراك السنوي",
            ),
            leading: IconButton(
                icon: new Image.asset('assets/back_white.png'),
                onPressed: () {
//                if(timer != null){
//                  timer.cancel();
//                }
                  Navigator.of(context).pop(null);
                }),
          ),
          bottomNavigationBar:
              _paymentData.dataOPayment == null || total == 0.00
                  ? SizedBox()
                  : _buildFooter(),
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

  bool showDetails = false;
  bool showBoxDetails = false;
  bool showLockerDetails = false;

  Widget _buildContent() {
    String name = "";
    String id = "";
    if (_paymentData.member != null) {
      name = _paymentData.member?.name ?? "";
      id = _paymentData.member?.member_id ?? "";
    }
//    if (user.last_name != null) {
//      name = name + user.last_name;
//    }
//    if (user.user_name != null) {
//      name = user.user_name;
//    }
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      child: ListView(
        children: <Widget>[
          _buildHeader(),
          Container(
            color: Color(0xffeeeeee),
            height: 1,
          ),
          Container(
            padding: EdgeInsets.only(right: 30, top: 15, left: 30, bottom: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Align(
                    child: Text(
                      'اسم العضو',
                      style: TextStyle(
                          color: Color(0xff00701a),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                    alignment: Alignment.centerRight),
                Expanded(
                    child: Align(
                        child: Text(
                          name,
                          style: TextStyle(
                              color: Color(0xff646464),
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                        alignment: Alignment.centerLeft)),
              ],
            ),
          ),
          Container(
            color: Color(0xffeeeeee),
            height: 1,
          ),
          Container(
            padding: EdgeInsets.only(right: 30, top: 15, left: 30, bottom: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Align(
                    child: Text(
                      'رقم العضوية',
                      style: TextStyle(
                          color: Color(0xff00701a),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                    alignment: Alignment.centerRight),
                Expanded(
                    child: Align(
                        child: Text(
                          id,
                          style: TextStyle(
                              color: Color(0xff646464),
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        ),
                        alignment: Alignment.centerLeft)),
              ],
            ),
          ),
          Container(
            color: Color(0xffeeeeee),
            height: 1,
          ),
          _paymentData.case_member == "case_processing"
              ? _buildProcessingPaymentDue()
              : _paymentData.case_member == "case_problem"
                  ? _buildIssuePaymentDue()
                  : _paymentData.case_member == "case_no_amount"
                      ? _buildNoPaymentDue()
                      : _buildPaymentInfo(),
        ],
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    double fees = 0.000;
    fees = total_fees - total;
    double annualSubscription =
        (_paymentData.dataOPayment?.annual_subscription ?? 0) -
            totalBoxesLockers;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
            child: Align(
                child: Text(
                  'دفع مستحقات التجديد',
                  style: TextStyle(
                      color: Color(0xff43a047),
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
                alignment: Alignment.center),
          ),
          Container(
            margin: EdgeInsets.only(right: 10, top: 5, left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    show_items
                        ? Container(
                            padding: EdgeInsets.only(
                                right: 10, top: 15, left: 10, bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Align(
                                        child: Text(
                                          'الاشتراك السنوي',
                                          style: TextStyle(
                                              color: Color(0xff43a047),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        alignment: Alignment.centerRight),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Align(
                                        child: Text(
                                          " L.E ",
                                          style: TextStyle(
                                              color: Color(0xff43a047),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900),
                                        ),
                                        alignment: Alignment.centerRight),
                                    Align(
                                        child: Text(
                                          "${annualSubscription.toStringAsFixed(2)}",
                                          style: TextStyle(
                                              color: Color(0xff43a047),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900),
                                        ),
                                        alignment: Alignment.centerRight),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      showDetails = !showDetails;
                                    });
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Align(
                                          child: Text(
                                            'عرض التفاصيل',
                                            style: TextStyle(
                                                color: showDetails
                                                    ? Color(0xffb2b2b2)
                                                    : Color(0xff00701a),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          alignment: Alignment.centerLeft),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      showDetails
                                          ? Image.asset(
                                              'assets/minus.png',
                                              width: 15,
                                              height: 15,
                                              fit: BoxFit.fitHeight,
                                            )
                                          : Image.asset(
                                              'assets/plus.png',
                                              width: 15,
                                              height: 15,
                                              fit: BoxFit.fitHeight,
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    showDetails &&
                            widget._paymentData.dataOPayment?.items != null
                        ? _buildDetailsWidget(
                            widget._paymentData.dataOPayment?.items ?? [])
                        : SizedBox(),
                    SizedBox(
                      height: widget._paymentData.dataOPayment?.items != null
                          ? 10
                          : 0,
                    ),
                    Container(
                      color: Color(0xffd4d4d4),
                      height: widget._paymentData.dataOPayment?.items != null
                          ? 1
                          : 0,
                    ),
                    _buildBoxWidget(),
                    _buildLockerWidget(),
                    (widget._paymentData.dataOPayment?.unpaidCars != null &&
                            (widget._paymentData.dataOPayment?.unpaidCars
                                    ?.isNotEmpty ??
                                false))
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10, top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  child: (selectAllBadgeCars)
                                      ? Icon(
                                          Icons.check_box,
                                          color: Color(0xffff5c46),
                                        )
                                      : Icon(
                                          Icons.check_box_outline_blank,
                                          color: Color(0xffbfbfbf),
                                        ),
                                  onTap: () {
                                    selectBadgeCarItem();
                                  },
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'بادجات العربيات',
                                  style: TextStyle(
                                    color: Color(0xff43a047),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    widget._paymentData.dataOPayment?.unpaidCars != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                _paymentData.dataOPayment?.unpaidCars?.length ??
                                    0,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildBadgeCarItem(
                                  _paymentData
                                          .dataOPayment?.unpaidCars?[index] ??
                                      Badge(),
                                  index);
                            })
                        : SizedBox(),
                    widget._paymentData.dataOPayment?.unpaidCars != null
                        ? Container(
                            color: Color(0xffd4d4d4),
                            height: 1,
                          )
                        : SizedBox(),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Align(
                              child: Text(
                                'الاجمالي',
                                style: TextStyle(
                                    color: Color(0xff00701a),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              alignment: Alignment.centerLeft),
                          SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    child: Align(
                                        child: Text(
                                          'L.E ',
                                          style: TextStyle(
                                              color: Color(0xff000000),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        alignment: Alignment.centerLeft),
                                  ),
                                  Align(
                                      child: Text(
                                        total.toString(),
                                        style: TextStyle(
                                            color: Color(0xff000000),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      alignment: Alignment.centerLeft),
                                ]),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(right: 10, top: 15, left: 10),
                    ),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Align(
                              child: Text(
                                'رسوم إدارية',
                                style: TextStyle(
                                    color: Color(0xff00701a),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              alignment: Alignment.centerLeft),
                          SizedBox(
                            width: 3,
                          ),
                          Expanded(
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                Container(
                                  child: Align(
                                      child: Text(
                                        'L.E ',
                                        style: TextStyle(
                                            color: Color(0xff000000),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      alignment: Alignment.centerLeft),
                                ),
                                Align(
                                    child: Text(
                                      fees.toStringAsFixed(3),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    alignment: Alignment.centerLeft)
                              ])),
                        ],
                      ),
                      padding: EdgeInsets.only(right: 10, top: 2, left: 10),
                    ),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Align(
                              child: Text(
                                ' الاجمالي شامل رسوم الدفع',
                                style: TextStyle(
                                    color: Color(0xff00701a),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              alignment: Alignment.centerLeft),
                          SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    child: Align(
                                        child: Text(
                                          'L.E ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        alignment: Alignment.centerLeft),
                                  ),
                                  Align(
                                      child: Text(
                                        total_fees.toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      alignment: Alignment.centerLeft)
                                ]),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(
                          right: 10, top: 2, left: 10, bottom: 15),
                    ),
                  ]),
            ),
          ),
        ]);
  }

  Widget _buildNoPaymentDue() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 140),
          Image.asset(
            'assets/check.png',
//          width: viewWidth,
            fit: BoxFit.fitHeight,
          ),
          SizedBox(
            height: 10,
          ),
          Align(
              child: Text(
                'لا يوجد مستحقات في الفترة الحالية',
                style: TextStyle(
                    color: Color(0xff03240a),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              alignment: Alignment.center),
        ]);
  }

  Widget _buildProcessingPaymentDue() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 120),

          //  CircularProgressIndicator(),
          Image.asset(
            'assets/check.png',
//          width: viewWidth,
            fit: BoxFit.fitHeight,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(right: 50, left: 50, top: 20),
            child: Align(
                child: Text(
                  'جاري تنفيذ عملية الدفع، برجاء الانتظار',
                  style: TextStyle(
                      color: Color(0xff727272),
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                alignment: Alignment.center),
          ),
        ]);
  }

  Widget _buildIssuePaymentDue() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 120),
          Image.asset(
            'assets/exclamation_mark.png',
//          width: viewWidth,
            fit: BoxFit.fitHeight,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(right: 50, left: 50, top: 20),
            child: Align(
                child: Text(
                  widget._serverMessage ??
                      'برجاء التواصل مع إدارة النادي لوجود مشكلة في تجديد اشتراك العضوية',
                  style: TextStyle(
                      color: Color(0xff03240a),
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                alignment: Alignment.center),
          ),
          // Container(
          //   padding: EdgeInsets.only(right: 50, left: 50, top: 10),
          //   child: Align(
          //       child: Text(
          //         'It@alexsportingclub.com',
          //         style: TextStyle(
          //             color: Color(0xff03240a),
          //             fontSize: 15,
          //             fontWeight: FontWeight.w500),
          //         textAlign: TextAlign.center,
          //       ),
          //       alignment: Alignment.center),
          // )
        ]);
  }

  Widget _buildDetailsWidget(List<Payment> paymentItems) {
    return Column(
      children: <Widget>[
        Container(
          color: Color(0xffeeeeee),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "البيان",
                    style: TextStyle(
                      color: Color(0xff646464),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.center,
                child: Text(
                  "القيمه",
                  style: TextStyle(
                    color: Color(0xff646464),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              )),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text(
                      "العدد",
                      style: TextStyle(
                        color: Color(0xff646464),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "الاجمالي",
                    style: TextStyle(
                      color: Color(0xff646464),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _paymentData.dataOPayment?.items?.length ?? 0,
            itemBuilder: (BuildContext ctxt, int index) {
              return _buildDetailsRowWidget(
                  _paymentData.dataOPayment?.items?[index] ?? Payment(), index);
            }),
      ],
    );
  }

  Widget _buildDetailsRowWidget(Payment paymentItems, int index_ser) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          paymentItems.serv_Count != null
              ? GestureDetector(
                  child: (paymentItems.serv_Count ?? false)
                      ? Icon(
                          Icons.check_box,
                          color: Color(0xffff5c46),
                          size: 20,
                        )
                      : Icon(
                          Icons.check_box_outline_blank,
                          color: Color(0xffbfbfbf),
                          size: 20,
                        ),
                  onTap: () {
                    setState(() {
                      from_badge = false;
                      this.index_serv = index_ser;
                      //badge.selected = !badge.selected;
                      double value_total = 0.00;
                      if (!(paymentItems.serv_Count ?? false)) {
                        value_total =
                            total + double.parse(paymentItems.total ?? "0.0");
                        //  total_fees = total_fees + double.parse( badge.value);
                      } else {
                        value_total =
                            total - double.parse(paymentItems.total ?? "0.0");
                        // total_fees = total_fees - double.parse( badge.value);

                      }
                      if (value_total == 0.00) {
                        total = 0.00;
                        total_fees = 0.00;
                        paymentItems.serv_Count =
                            !(paymentItems.serv_Count ?? false);
                      } else {
                        paymentNetwork.calculateFees(
                            value_total.toString(), this);
                      }
                    });
                  },
                )
              : SizedBox(
                  width: 20,
                ),
          Expanded(
            child: Container(
              child: Text(
                paymentItems.label ?? "",
                style: TextStyle(
                  color: Color(0xff43a047),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "L.E ",
                          style: TextStyle(
                            color: Color(0xff646464),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          paymentItems.price_once ?? "0",
                          style: TextStyle(
                            color: Color(0xff646464),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ]))),
          Expanded(
              child: Container(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                paymentItems.count ?? "",
                style: TextStyle(
                  color: Color(0xff646464),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
//              padding: paymentItems.serv_Count != null
//                  ? EdgeInsets.only(left: 10)
//                  : EdgeInsets.only(right: 15), //
          )),
          Expanded(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                Text(
                  "L.E ",
                  style: TextStyle(
                    color: Color(0xff646464),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    paymentItems.total ?? "0",
                    style: TextStyle(
                      color: Color(0xff646464),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ]))
        ],
      ),
    );
  }

  Widget _buildFieldTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 15, top: 20, bottom: 5),
      child: Align(
        child: Text(
          title,
          style: TextStyle(
            color: Color(0xff646464),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _buildSubTitle(String title, double right_align, double top_align) {
    return Padding(
      padding: EdgeInsets.only(right: right_align, top: top_align, bottom: 5),
      child: Align(
        child: Text(
          title,
          style: TextStyle(
            color: Color(0xff646464),
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _buildFieldError(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 20, top: 5, bottom: 5),
      child: Align(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: Colors.red,
          ),
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _buildInputField(
      String title, TextEditingController controller, TextInputType type) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 15, top: 5, left: 15),
      child: Container(
        child: TextField(
          controller: controller,
          style: TextStyle(fontSize: 16, color: Colors.black),
          maxLines: 1,
          // textInputAction: TextInputAction.newline,
          decoration: new InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 12, bottom: 10, top: 15, right: 12),
            hintText: title,
          ),
          keyboardType: type,
          keyboardAppearance: Brightness.light,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(32),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
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
          color: Colors.white,
        ),
//        width: width - 30,
        height: 60,
      ),
    );
  }

  Widget _buildErrorPhoneContent(String error) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            error,
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 13,
            ),
          ),
          GestureDetector(
            onTap: () {
//              Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (BuildContext context) =>
//                          UpdateInfoFirstStep(_controller.text)));
            },
            child: Text(
              'من هنا',
              style: TextStyle(
                  color: Color(0xfff12b10),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  decorationThickness: 2,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 20, right: 15, left: 15),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  Widget _buildErrorIDContent() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            'رقم عضوية غير صحيح',
            style: TextStyle(
              color: Color(0xfff12b10),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              'الرجاء معاودة المحاولة في وقت لاحق',
              style: TextStyle(
                color: Color(0xfff12b10),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 15, top: 15, right: 10, left: 10),
      margin: EdgeInsets.only(bottom: 20, right: 15, left: 15),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
          color: Color(0xffffeae3),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
    );
  }

  Widget _buildHeader() {
    double width = MediaQuery.of(context).size.width;
    double viewWidth = width - 150;

    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        child: Image.asset(
          'assets/step03.png',
//          width: viewWidth,
          height: 70,
          fit: BoxFit.fitHeight,
        ),
      ),
      color: Colors.white,
//      height: 120,
    );
  }

  Widget _buildFooter() {
    return GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
          child: Container(
            width: 88,
            height: 60,
            child: Center(
              child: Text(
                'الدفع الان',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
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
          ),
        ),
        onTap: () {
          _navigateToNextAction();
        });
  }

  Widget _buildNextStep(String number, String title) {
    return Column(
      children: <Widget>[
        Container(
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                  color: Color(0xffd4d4d4),
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Color(0xffd4d4d4)),
            color: Color(0xfff9f9f9),
          ),
          height: 50,
          width: 50,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          title,
          style: TextStyle(
              color: Color(0xffd4d4d4),
              fontSize: 12,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  void _navigateToNextAction() {
    String cars = "", remain = "false";
    if (_paymentData.dataOPayment?.unpaidCars != null) {
      for (Badge item in _paymentData.dataOPayment?.unpaidCars ?? []) {
        if ((item.selected ?? false)) {
          if (cars == "") {
            cars = item.carnumber ?? "";
          } else {
            cars = cars + "," + (item.carnumber ?? "");
          }
        }
      }
    }
    if (_paymentData.dataOPayment?.remaining != null) {
      if (_paymentData.dataOPayment?.remaining ?? false) {
        remain = "true";
      } else {
        remain = "false";
      }
    }
    paymentNetwork.requestPayment(total.toString(), remain, cars, serv_count,
        _paymentData.member?.member_id ?? "", this);
  }

  Widget _buildBoxWidget() {
    return (widget._paymentData.member?.boxes != null &&
            (widget._paymentData.member?.boxes?.isNotEmpty ?? false))
        ? Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      showBoxDetails = !showBoxDetails;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Align(
                          child: Text(
                            ' عرض تفاصيل البوكسات',
                            style: TextStyle(
                                color: showBoxDetails
                                    ? Color(0xffb2b2b2)
                                    : Color(0xff00701a),
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          alignment: Alignment.centerLeft),
                      SizedBox(
                        width: 3,
                      ),
                      showBoxDetails
                          ? Image.asset(
                              'assets/minus.png',
                              width: 15,
                              height: 15,
                              fit: BoxFit.fitHeight,
                            )
                          : Image.asset(
                              'assets/plus.png',
                              width: 15,
                              height: 15,
                              fit: BoxFit.fitHeight,
                            ),
                    ],
                  ),
                ),
                if (showBoxDetails)
                  Container(
                    color: Color(0xffeeeeee),
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "رقم البوكس",
                              style: TextStyle(
                                color: Color(0xff646464),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Text(
                                "القيمة",
                                style: TextStyle(
                                  color: Color(0xff646464),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (showBoxDetails)
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _paymentData.member?.boxes?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildBoxRowWidget(
                          _paymentData.member?.boxes?[index] ?? Box(),
                        );
                      }),
                Container(
                  color: Color(0xffd4d4d4),
                  height: 1,
                )
              ],
            ),
          )
        : SizedBox();
  }

  Widget _buildBoxRowWidget(Box box) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                box.boxNum ?? "",
                style: TextStyle(
                  color: Color(0xff43a047),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "L.E ",
                          style: TextStyle(
                            color: Color(0xff646464),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          box.boxPrice ?? "0",
                          style: TextStyle(
                            color: Color(0xff646464),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ]))),
        ],
      ),
    );
  }

  Widget _buildLockerWidget() {
    return (widget._paymentData.member?.lockers != null &&
            (widget._paymentData.member?.lockers?.isNotEmpty ?? false))
        ? Padding(
            padding: const EdgeInsets.only(
              right: 10,
              top: 10,
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      showLockerDetails = !showLockerDetails;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Align(
                          child: Text(
                            ' عرض تفاصيل الدواليب',
                            style: TextStyle(
                                color: showLockerDetails
                                    ? Color(0xffb2b2b2)
                                    : Color(0xff00701a),
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          alignment: Alignment.centerLeft),
                      SizedBox(
                        width: 3,
                      ),
                      showLockerDetails
                          ? Image.asset(
                              'assets/minus.png',
                              width: 15,
                              height: 15,
                              fit: BoxFit.fitHeight,
                            )
                          : Image.asset(
                              'assets/plus.png',
                              width: 15,
                              height: 15,
                              fit: BoxFit.fitHeight,
                            ),
                    ],
                  ),
                ),
                if (showLockerDetails)
                  Container(
                    color: Color(0xffeeeeee),
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "رقم الدولاب",
                              style: TextStyle(
                                color: Color(0xff646464),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Text(
                                "القيمه",
                                style: TextStyle(
                                  color: Color(0xff646464),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Text(
                                "المكان",
                                style: TextStyle(
                                  color: Color(0xff646464),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (showLockerDetails)
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _paymentData.member?.lockers?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildLockerRowWidget(
                          _paymentData.member?.lockers?[index] ?? Locker(),
                        );
                      }),
                Container(
                  color: Color(0xffd4d4d4),
                  height: 1,
                )
              ],
            ),
          )
        : SizedBox();
  }

  Widget _buildLockerRowWidget(Locker locker) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                locker.lockerNum ?? "",
                style: TextStyle(
                  color: Color(0xff43a047),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "L.E ",
                          style: TextStyle(
                            color: Color(0xff646464),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          locker.lockerPrice ?? "0",
                          style: TextStyle(
                            color: Color(0xff646464),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ]))),
          Expanded(
              child: Container(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                locker.lockerLocation ?? "",
                style: TextStyle(
                  color: Color(0xff646464),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  @override
  void extendTime(String time) {
    // TODO: implement extendTime
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
  void showAuthError() {}

  @override
  void showSuccessID(String? msg) {
    setState(() {
      total_fees = double.parse(msg ?? "0.0");
      if (from_badge) {
        from_badge = false;
        _paymentData.dataOPayment?.unpaidCars?.forEach((badge) {
          badge.selected = !(badge.selected ?? false);
          if (badge.selected ?? false) {
            total = total + double.parse(badge.value ?? "0.0");
            //  total_fees = total_fees + double.parse( badge.value);
          } else {
            total = total - double.parse(badge.value ?? "0.0");
            // total_fees = total_fees - double.parse( badge.value);
          }
        });
      } else {
        print("here");
        Payment payment =
            _paymentData.dataOPayment?.items?[index_serv] ?? Payment();
        payment.serv_Count = !(payment.serv_Count ?? false);
        if (payment.serv_Count ?? false) {
          total = total + double.parse(payment.total ?? "0.0");
          serv_count = "true";
        } else {
          total = total - double.parse(payment.total ?? "0.0");
          serv_count = "false";
        }
      }
    });
  }

  bool isLoginError = false;

  @override
  void showLoginError(String error) {
    setState(() {
      isLoginError = true;
    });
  }

  @override
  void showEmailError({String? errorMsg}) {}

  @override
  void showMemberShipIDError() {
    // TODO: implement showMemberShipIDError
  }

  @override
  void showPhoneError(String? error) {}

  Widget _buildBadgeCarItem(Badge badge, index) {
    return Padding(
      padding: EdgeInsets.only(
        top: 5,
        left: 10,
        right: 15,
      ),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            (badge.selected ?? false)
                ? Icon(
                    Icons.check_circle,
                    color: Color(0xffff5c46),
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    color: Color(0xffbfbfbf),
                  ),
            SizedBox(
              width: 10,
            ),
            Text(
              'بدج',
              style: TextStyle(
                color: Color(0xff43a047),
                fontSize: 16,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              badge.carnumber ?? "",
              style: TextStyle(
                color: Color(0xff43a047),
                fontSize: 16,
              ),
            ),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                  Container(
                    child: Align(
                        child: Text(
                          'L.E ',
                          style: TextStyle(
                              color: Color(0xff43a047),
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ),
                        alignment: Alignment.centerLeft),
                  ),
                  Container(
                    child: Align(
                        child: Text(
                          '${badge.value}',
                          style: TextStyle(
                              color: Color(0xff43a047),
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ),
                        alignment: Alignment.centerLeft),
                  ),
                ])),
          ],
        ),
        padding: EdgeInsets.only(top: 10, bottom: 10),
        // height: 50,
        //  color: Color(0xffeeeeee),
      ),
    );
  }

  bool selectAllBadgeCars = false;
  selectBadgeCarItem() {
    setState(() {
      selectAllBadgeCars = !selectAllBadgeCars;
      double value_total = 0.00;
      _paymentData.dataOPayment?.unpaidCars?.forEach((badge) {
        from_badge = true;
        // this.index = index;
        value_total = 0.00;
        if (!(badge.selected ?? false)) {
          value_total = total + double.parse(badge.value ?? "0.0");
          //  total_fees = total_fees + double.parse( badge.value);
        } else {
          value_total = total - double.parse(badge.value ?? "0.0");
          // total_fees = total_fees - double.parse( badge.value);

        }
        if (value_total == 0.00) {
          total = 0.00;
          total_fees = 0.00;
          badge.selected = !(badge.selected ?? false);
        }
      });
      if (value_total != 0.00) {
        paymentNetwork.calculateFees(value_total.toString(), this);
      }
    });
  }

  @override
  void showSuccessOnline(OnlineMembershipPayment? data) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                OnlineWebMembershipPayment(data?.iframe_url ?? "", this)));
  }

  @override
  void showSuccessOnlinePayment(String url) {
    print("url" + url);
    userNetwork.verifyLoginPayment(
        _code, _paymentData.member?.member_id ?? "", true, this);
    // TODO: implement showSuccessOnlinePayment
  }

  @override
  void showInvalidCode(String? data) {
    // TODO: implement showInvalidCode
  }

  @override
  void showSuccess(PaymentData? data, {String? serverMessage}) {
    setState(() {
      if (_paymentData.dataOPayment != null) {
        if (_paymentData.dataOPayment?.annual_subscription != null &&
            show_items) {
          total = double.parse(
              _paymentData.dataOPayment?.annual_subscription.toString() ??
                  "0.0");
          total_fees = _paymentData.dataOPayment?.total_after_fees;
          totalBoxesLockers = _paymentData.member?.totalBoxesLockers ?? 0;
        } else {
          total = 0.00;
          total_fees = 0.00;
          totalBoxesLockers = 0.00;
        }
      }
      if (_paymentData.case_member != null) {
        if (_paymentData.case_member == "case_processing") {}
      }
      _paymentData = data ?? PaymentData();
      _paymentData.case_member = data?.case_member;
    });
    // TODO: implement showSuccess
  }

  @override
  void showSuccessMsgCode(String? msg) {}

  @override
  void showErrorMsg(String? error) {}
//  void checkForNewStaus(){
//    if (_paymentData.case_member != null) {
//      print("tttttt"+_paymentData.case_member );
//      if (_paymentData.case_member == "case_processing") {
//        print("222222222222");
//
//        userNetwork.verifyLoginPayment(
//            _code, _paymentData.member.member_id, false, this);
//      }else if (_paymentData.case_member == "case_no_amount"){
//        print("3333333333");
//
////        timer.cancel();
////        setState(() {
////
////        });
//      }
//    }else{
//      print("checkForNewStauscancel");
//
////      if(timer != null){
////        timer.cancel();
////      }
//    }
//
//  }
}
