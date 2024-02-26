import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sporting_club/base/screen_handler.dart';
import 'package:sporting_club/data/model/emergency/emergency_category.dart';
import 'package:sporting_club/network/repositories/emergency_network.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/ui/sos/view_model/emergency_categories_viewmodel.dart';
import 'package:sporting_club/ui/sos/widgets/category_row.dart';
import 'package:sporting_club/main.dart';
import '../../../utilities/location_manager.dart';
import '../../book_shuttle_bus/widgets/full_traffic_image.dart';
import '../widgets/emergency_no_data.dart';
import '../widgets/emergency_no_network.dart';

class EmergencyCategoriesScreen extends StatefulWidget {
  EmergencyCategoriesScreen();

  @override
  State<StatefulWidget> createState() {
    return EmergencyCategoriesScreenState();
  }
}

class EmergencyCategoriesScreenState extends State<EmergencyCategoriesScreen> {
  EmergencyCategoriesScreenState();

  BuildContext? mProviderContext = global.navigatorKey.currentContext;
  List<EmergencyCategory> sosCategoryList = [];

  @override
  void initState() {
    super.initState();
    getCategoryList();
    getCurrentLocation();
  }

  getCategoryList() async {
    try {
      Future.delayed(Duration.zero, () {
        try {
          Provider.of<EmergencyCategoriesViewModel>(
                  mProviderContext ?? global.navigatorKey.currentContext!,
                  listen: false)
              .getEmergencyCategoryList();
        } catch (e) {
          print(e.toString());
        }
      });
    } catch (error) {
      print("erroe getShuttleList");
      // _pagingController.error = error;
    }
  }

  getCurrentLocation() async {
    try {
      Future.delayed(Duration.zero, () {
        try {
          Provider.of<EmergencyCategoriesViewModel>(mProviderContext!,
                  listen: false)
              .getCurrentLocation();
        } catch (e) {
          print(e.toString());
        }
      });
    } catch (error) {
      print("erroe getShuttleList");
      // _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmergencyCategoriesViewModel>(
        create: (context) =>
            EmergencyCategoriesViewModel(EmergencyNetwork(), context),
        child: Scaffold(
          backgroundColor: Color(0xfff9f9f9),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          // floatingActionButton: _buildFloatingButton(),
          body: new Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        Selector<EmergencyCategoriesViewModel,
                                List<EmergencyCategory>>(
                            selector: (_, viewModel) =>
                                viewModel.sosCategoryList,
                            builder:
                                (providerContext, _sosCategoryList, child) {
                              mProviderContext = providerContext;
                              return _buildScreenContent();
                            }),
                      ],
                    ),
                  ),
                  // Selector<EmergencyCategoriesViewModel, bool>(
                  //     selector: (_, viewModel) => viewModel.isSOSSent,
                  //     builder: (providerContext, _isSOSSent, child) {
                  //       mProviderContext = providerContext;
                  //       bool isSOSSent = _isSOSSent;
                  //       return isSOSSent
                  //           ? Positioned(
                  //               bottom: 0,
                  //               left: 0,
                  //               right: 0,
                  //               child: Container(
                  //                 width: MediaQuery.of(context).size.width,
                  //                 color: Colors.white,
                  //                 padding: EdgeInsets.symmetric(vertical: 15),
                  //                 child: Center(
                  //                   child: Text(
                  //                     "تم إرسال الطلب",
                  //                     style: TextStyle(
                  //                         color: Color(0xff646464),
                  //                         fontWeight: FontWeight.bold,
                  //                         fontSize: 16),
                  //                   ),
                  //                 ),
                  //               ))
                  //           : SizedBox();
                  //     }),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 25),
        child: Container(
          child: Center(
            child: Text(
              "أماكن تواجد أجهزه الإنعاش القلبي",
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
            color: Color(0xffff5c46),
          ),
          height: 50,
        ),
      ),
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => FullTrafficImage(
              imageUrl: "assets/green_backgound.png",
            )));
        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return SafeArea(
        //           child: Material(
        //         color: Colors.transparent,
        //         child: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Row(
        //               crossAxisAlignment: CrossAxisAlignment.end,
        //               children: [
        //                 IconButton(
        //                     onPressed: () => Navigator.pop(context),
        //                     icon: Image.asset("assets/close_green_ic.png"))
        //               ],
        //             ),
        //             Expanded(
        //               child: Image.asset(
        //                 "assets/green_backgound.png",
        //                 fit: BoxFit.contain,
        //               ),
        //             )
        //           ],
        //         ),
        //       ));
        //     });
      },
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/complaint_background.png"),
              fit: BoxFit.fill,
            ),
          ),
          height: 190 + MediaQuery.of(context).padding.top,
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: new Image.asset('assets/back_white.png'),
                onPressed: () => Navigator.of(context).pop(null),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الطوارئ',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'أضغط في حالة الطوارئ',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      "assets/emrgancy_details_ic.png",
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreenContent() {
    return ScreenHandler<EmergencyCategoriesViewModel>(
      networkWidget: EmergencyNoNetwork(
        onTapNoNetwork: () {
          getCategoryList();
        },
      ),
      noDataWidget: EmergencyNoData(
        onTapNoData: () {
          getCategoryList();
        },
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Selector<EmergencyCategoriesViewModel, List<EmergencyCategory>>(
        selector: (_, viewModel) => viewModel.sosCategoryList,
        builder: (providerContext, _sosCategoryList, child) {
          sosCategoryList = _sosCategoryList;
          return sosCategoryList.isEmpty
              ? SizedBox()
              : _buildSosCategoryListList();
        });
  }

  Widget _buildSosCategoryListList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sosCategoryList.length,
      itemBuilder: (context, i) {
        return _buildCategoryRow(sosCategoryList[i]);
      },
      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: 2,
      //     crossAxisSpacing: 3.0,
      //     mainAxisSpacing: 1.0,
      //     childAspectRatio: .85),
    );
  }

  Widget _buildCategoryRow(EmergencyCategory emergencyCategory) {
    return Selector<EmergencyCategoriesViewModel, EmergencyCategory>(
        selector: (_, viewModel) => viewModel.selectedEmergencyCategory,
        builder: (providerContext, _selectedEmergencyCategory, child) {
          return EmergencyCategoryRow(
              emergencyCategory: emergencyCategory,
              isSelected: emergencyCategory.id == _selectedEmergencyCategory.id,
              onTapAction: () {
                Provider.of<EmergencyCategoriesViewModel>(mProviderContext!,
                        listen: false)
                    .selectEmergencyCategory(emergencyCategory);
                showSendSOSView(emergencyCategory);
              });
        });
  }

  void showSendSOSView(EmergencyCategory emergencyCategory) {
    print('add image click');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text("هل تريد الإرسال ؟",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black)),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 15, right: 15, bottom: 20, top: 20),
                          child: Container(
                            height: 55,
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            child: Center(
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff03240A)),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xffD4D4D4),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        }),
                    GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 15, right: 15, bottom: 20, top: 20),
                          child: Container(
                            height: 55,
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            child: Center(
                              child: Text(
                                'تأكيد',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xffff5c46),
                            ),
                          ),
                        ),
                        onTap: () async {
                          bool handlePermission =
                              await LocationManager.handlePermission();
                          if (!handlePermission) {
                            // Navigator.of(context).pop();
                          } else {
                            Provider.of<EmergencyCategoriesViewModel>(
                                    mProviderContext!,
                                    listen: false)
                                .sendSOS(emergencyCategory);
                            Navigator.of(context).pop();
                          }
                        }),
                  ],
                )
              ],
            ),
          ),
          height: 50,
        );
      },
    );
  }
}
