import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/base/common/widgets/app_text.dart';
import 'package:sporting_club/base/screen_handler.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_fees.dart';
import 'package:sporting_club/network/repositories/booking_network.dart';
import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:sporting_club/ui/book_shuttle_bus/view_model/shuttle_viewmodel.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/shuttle_no_data.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/shuttle_no_network.dart';
import 'package:sporting_club/utilities/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/ui/book_shuttle_bus/view_model/shuttle_booking_viewmodel.dart';
import 'package:sporting_club/main.dart';

class ShuttleSelectionSummaryScreen extends StatefulWidget {
  ShuttleFees? totalAmoutFees;
  ShuttleBookingData? shuttleBookingData;
  String? favouriteLines;
  String? comment;
  List<String>? selectedMembersList = [];
  String? subscription;

  ShuttleSelectionSummaryScreen(
      {this.selectedMembersList,
      this.totalAmoutFees,
      this.subscription,
      this.shuttleBookingData,
        this.favouriteLines,
        this.comment,


      });

  @override
  State<StatefulWidget> createState() {
    return SelectShuttleBusPackageScreenState();
  }
}

class SelectShuttleBusPackageScreenState
    extends State<ShuttleSelectionSummaryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  BuildContext? mProviderContext = global.navigatorKey.currentContext;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShuttleBookingViewModel>(
        create: (context) =>
            ShuttleBookingViewModel(ShuttleBusNetwork(), context),
        child: Selector<ShuttleBookingViewModel, ShuttleData>(
            selector: (_, viewModel) => viewModel.shuttleData,
            builder: (providerContext, viewModelShuttleData, child) {
              mProviderContext = providerContext;
              return new Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    title: Text(
                      "شاتل باص",
                    ),
                    leading: IconButton(
                      icon: new Image.asset('assets/back_white.png'),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ),
                  backgroundColor: Color(0xfff9f9f9),
                  body: ScreenHandler<ShuttleBookingViewModel>(
                    networkWidget: ShuttleNoNetwork(
                      onTapNoNetwork: () {
                        _navigateToNextAction();
                      },
                    ),
                    child: Stack(
                      children: <Widget>[
                        _buildContent(),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: _buildFooter(),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  Widget _buildContent() {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 20, top: 20, bottom: 10),
          child: Align(
              child: Text(
                "الإجمالي",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight),
        ),
        _buildBookingData(),

        SizedBox(
          height: 120,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Container(
              height: 60,
              child: Center(
                child: Text(
                  'الدفع',
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
          onTap: () => _navigateToNextAction()),
    );
  }

  Widget _buildBookingData() {
    return Container(
      margin: EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
      padding: EdgeInsets.only(top: 5, bottom: 5),

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
        color: Colors.white,
      ),
      // height: 50,
      child: Container(
          // color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildCostRow(
                    title: "إجمالي عدد الأفراد",
                    value: "${widget.selectedMembersList?.length ?? 0}",
                  ),
                  Divider(),
                  buildCostRow(
                    title: "إجمالي التكلفة",
                    value:
                        "${widget.totalAmoutFees?.totalAfterDiscount ?? 0} جنيه ",
                  ),
                ]),
          ])),
    );
  }

  buildCostRow({title, value}) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xff43a047),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ]);
  }

  void _navigateToNextAction() {
    Provider.of<ShuttleBookingViewModel>(mProviderContext!, listen: false)
        .createPendingBooking(
      subType: widget.subscription ?? "",
      memberIds: widget.selectedMembersList?.join(",") ?? "",
      startDate: widget.shuttleBookingData?.startDate ?? "",
      endDate: widget.shuttleBookingData?.endDate ?? "",
      totalPrice: widget.totalAmoutFees?.totalAfterDiscount ?? 0,
      totalDiscount: widget.totalAmoutFees?.amountDiscount?.toString() ??"0",
      totalBeforeFees: widget.totalAmoutFees?.totalBeforeDiscount?.toString() ??"0",
      favouriteLines: widget.favouriteLines ?? "",
      comment: widget.comment ?? "",
    );
  }
}
