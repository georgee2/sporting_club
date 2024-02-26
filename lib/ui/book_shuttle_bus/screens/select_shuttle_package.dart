import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/base/common/widgets/app_text.dart';
import 'package:sporting_club/base/screen_handler.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_booking_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_data.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';
import 'package:sporting_club/data/model/shuttle_bus/traffic_line.dart';
import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:sporting_club/ui/book_shuttle_bus/view_model/shuttle_viewmodel.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/footer.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/member_row.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/package_row.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/shuttle_no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sporting_club/utilities/app_colors.dart';

import 'my_shuttle_bookings.dart';

class SelectShuttleBusPackageScreen extends StatefulWidget {
  SelectShuttleBusPackageScreen();

  @override
  State<StatefulWidget> createState() {
    return SelectShuttleBusPackageScreenState();
  }
}

class SelectShuttleBusPackageScreenState
    extends State<SelectShuttleBusPackageScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      try {
        Provider.of<ShuttleViewModel>(mProviderContext!, listen: false)
            .getTrafficLineList();
        Provider.of<ShuttleViewModel>(mProviderContext!, listen: false)
            .getShuttlePackages();
      } catch (e) {
        print(e.toString());
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  BuildContext? mProviderContext = global.navigatorKey.currentContext;
  ShuttleData? shuttleData;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShuttleViewModel>(
        create: (context) => ShuttleViewModel(ShuttleBusNetwork(), context),
        child: Selector<ShuttleViewModel, ShuttleData>(
            selector: (_, viewModel) => viewModel.shuttleData,
            builder: (providerContext, viewModelShuttleData, child) {
              mProviderContext = providerContext;
              shuttleData = viewModelShuttleData;
              return new Directionality(
                textDirection: TextDirection.rtl,
                child: WillPopScope(
                  onWillPop: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                MyShuttleBookingsScreen()));
                    return true;
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      title: Text(
                        "شاتل باص",
                      ),
                      leading: IconButton(
                          icon: new Image.asset('assets/back_white.png'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        MyShuttleBookingsScreen()));
                          }),
                    ),
                    backgroundColor: Color(0xfff9f9f9),
                    body: ScreenHandler<ShuttleViewModel>(
                      networkWidget: ShuttleNoNetwork(
                        onTapNoNetwork: () {
                          Provider.of<ShuttleViewModel>(mProviderContext!,
                                  listen: false)
                              .getShuttlePackages();
                        },
                      ),
                      child: shuttleData == null ? SizedBox() : _buildContent(),
                    ),
                  ),
                ),
              );
            }));
  }

  Widget _buildContent() {
    return Stack(
      children: <Widget>[
        ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 20, top: 20, bottom: 0),
              child: Align(
                  child: CustomAppText(
                    text: "اختار نوع الاشتراك",
                    textColor: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  alignment: Alignment.centerRight),
            ),
            _buildPackageList(),
            Container(
              padding: EdgeInsets.only(right: 20, top: 20, bottom: 0),
              child: Align(
                  child: CustomAppText(
                    text: "اختيار عدد الأفراد",
                    textColor: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  alignment: Alignment.centerRight),
            ),
            _buildMembersList(),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 20, right: 20),
              child: Text(
                "يرجى إختيار الخط المفضل مع العلم الإشتراك يشمل كافة الخطوط",
                style: TextStyle(
                    color: Color(0xff03240a).withOpacity(.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            _buildFavouriteLinesField(),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 20, right: 20),
              child: Text(
                "المحطات الإضافية المقترحة",
                style: TextStyle(
                    color: Color(0xff03240a).withOpacity(.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            _buildCommentField(),
            SizedBox(
              height: 100,
            ),
          ],
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Selector<ShuttleViewModel, ShuttleBookingData>(
                selector: (_, viewModel) => viewModel.shuttleBookingData,
                builder: (_, _shuttleBookingData, child) {
                  return ShuttleSelectFooter(
                    shuttleBookingData: _shuttleBookingData,
                    navigateToNextAction: _navigateToNextAction,
                  );
                })),
      ],
    );
  }

  var _commentController = TextEditingController();
  List<TrafficLine> trafficLineList = [];

  Widget _buildFavouriteLinesField() {
    return Selector<ShuttleViewModel, List<TrafficLine>>(
        selector: (_, viewModel) => viewModel.trafficLineList,
        builder: (providerContext, viewModelTrafficLine, child) {
          trafficLineList = viewModelTrafficLine;
          return Container(
            margin: EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trafficLineList.length,
              itemBuilder: (context, i) {
                return _buildtrafficLineRow(trafficLineList[i]);
              },
            ),
          );
        });
  }

  List<String> selectedtrafficLineList = [];

  Widget _buildtrafficLineRow(TrafficLine trafficLine) {
    return Selector<ShuttleViewModel, List<String>>(
        selector: (_, viewModel) => viewModel.selectedtrafficLineList,
        builder: (providerContext, viewModelTrafficLine, child) {
          selectedtrafficLineList = viewModelTrafficLine;
          return InkWell(
            onTap: () async {},
            child: new Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      value: selectedtrafficLineList
                          .contains(trafficLine.id?.toString()),
                      onChanged: (val) {
                        Provider.of<ShuttleViewModel>(mProviderContext!,
                                listen: false)
                            .selectTrafficLineList(trafficLine, val ?? false);
                      },
                      activeColor: AppColors.green,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        trafficLine.name ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff43a047),
                        ),
                      ),
                    ),
                  ]),
            ),
          );
        });
  }

  Widget _buildCommentField() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Container(
          child: TextField(
            maxLines: null,
            controller: _commentController,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: "إضافة محطة مقترحة",
            ),
            keyboardType: TextInputType.multiline,
            keyboardAppearance: Brightness.light,
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
            color: Colors.white,
          ),
          height: 120,
          margin: EdgeInsets.only(bottom: 5, top: 10),
          padding: EdgeInsets.all(1),
        ),
      ),
    );
  }

  ShuttleBookingData? shuttleBookingData;

  // List<String> _selectedMembersList = [];
  Map<String, dynamic> _selectedMembersList = {};

  List<String> _availableMembersList = [];
  List<ShuttleMember> memberList = [];

  Widget _buildMembersList() {
    memberList = shuttleData?.memberList ?? [];
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
      child: Consumer<ShuttleViewModel>(builder: (context, viewModel, child) {
        _availableMembersList.clear();
        _availableMembersList.addAll(viewModel.availableMembersList);
        _selectedMembersList = viewModel.selectedMembersList;
        return ListView.builder(
          shrinkWrap: true, // use it
          physics: const NeverScrollableScrollPhysics(),
          itemCount: memberList.length,
          itemBuilder: (context, i) {
            return MemberRow(
              selectedMemberMap: _selectedMembersList,
              isAvailableMember:
                  _availableMembersList.contains(memberList[i].memberId),
              shuttleMember: memberList[i],
              onTapAction: (bool val) {
                if (selectPackage != null) {
                  if (_availableMembersList.contains(memberList[i].memberId)) {
                    if (val) {
                      _selectedMembersList[memberList[i].memberId ?? ""] = 0;
                    } else {
                      _selectedMembersList.remove(memberList[i].memberId);
                    }
                    Provider.of<ShuttleViewModel>(mProviderContext!,
                            listen: false)
                        .selectMembersList(
                      selectedMember: _selectedMembersList,
                    );
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "اختر نوع الاشتراك اولا",
                      toastLength: Toast.LENGTH_LONG);
                }
              },
            );
          },
        );
      }),
    );
  }

  String? selectPackage;
  ShuttlePackage? selectShuttlePackage;

  Widget _buildPackageList() {
    Map<String, ShuttlePackage> shuttlePackageMap =
        shuttleData?.packageMap ?? {};
    List<ShuttlePackage> shuttlePackageList =
        shuttleData?.packageMap?.values.toList() ?? [];
    return Container(
      margin: EdgeInsets.only(bottom: 5, top: 0, left: 10, right: 10),
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: ListView.builder(
        shrinkWrap: true, // use it
        physics: const NeverScrollableScrollPhysics(),
        itemCount: shuttlePackageMap.length,
        itemBuilder: (context, i) {
          return Selector<ShuttleViewModel, MapEntry<String, ShuttlePackage>?>(
              selector: (_, viewModel) => viewModel.selectedShuttlePackageMap,
              builder: (_, _selectedShuttlePackageMap, child) {
                if (_selectedShuttlePackageMap != null) {
                  selectPackage = _selectedShuttlePackageMap.key;
                  selectShuttlePackage = _selectedShuttlePackageMap.value;
                }
                return ShuttlePackageRow(
                  shuttlePackage: shuttlePackageList[i],
                  onTapAction: () {
                    Provider.of<ShuttleViewModel>(mProviderContext!,
                            listen: false)
                        .selectShuttlePackages(
                            shuttlePackageMap:
                                shuttlePackageMap.entries.toList()[i]);
                  },
                  isSelectedPackage:
                      shuttlePackageMap.keys.toList()[i] == selectPackage,
                );
              });
        },
      ),
    );
  }

  void _navigateToNextAction() {
    if (_validateIDs()) {
      print("valid ids");
      FocusScope.of(context).requestFocus(FocusNode());

      Provider.of<ShuttleViewModel>(mProviderContext!, listen: false)
          .calculatePrice(
              subscription: selectPackage ?? "",
              totalMembers: _selectedMembersList.length.toString(),
              comment: _commentController.text,
              favouriteLines: selectedtrafficLineList.join(","));
    }
  }

  bool _validateIDs() {
    if (_availableMembersList.isEmpty) {
      print("empty id");
      Fluttertoast.showToast(
          msg: 'جميع الأعضاء مشتركين الان', toastLength: Toast.LENGTH_LONG);
      return false;
    } else if (_selectedMembersList.isEmpty) {
      Fluttertoast.showToast(
          msg: 'من فضلك اختار الأعضاء', toastLength: Toast.LENGTH_LONG);
      return false;
    } else if (selectedtrafficLineList.isEmpty) {
      Fluttertoast.showToast(
          msg: 'من فضلك اختر خط واحد على الأقل',
          toastLength: Toast.LENGTH_LONG);
      return false;
    }
    return true;
  }
}
