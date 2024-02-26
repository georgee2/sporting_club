import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/traffic_line_screen.dart';
import 'package:sporting_club/ui/swvl/screens/swvl_line_screen.dart';
import 'package:sporting_club/utilities/app_colors.dart';

import 'full_traffic_image.dart';
import 'no_shuttle_dialog.dart';

class ShuttleNoData extends StatelessWidget {
  final String message;
  final void Function() onTapNoData;
  final bool showBusLine;

  const ShuttleNoData(
      {Key? key,
      required this.onTapNoData,
      this.message = "",
      this.showBusLine = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/bus.png"),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "ليس لديك حجوزات شاتل باص",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButton(
              context: context,
              title: 'حجز شاتل باص',
              icon: Icon(Icons.add, color: Colors.white),
              backgroundColor: Color(0xffff5c46),
              onTap: () async {
                onTapNoData();
              }),
          showBusLine
              ? _buildButton(
                  context: context,
                  title: "خطوط السير والمواعيد",
                  icon: Image.asset("assets/shuttle_ic.png"),
                  backgroundColor: Color(0xff29902d),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                TrafficLineListScreen()));
                  })
              : SizedBox(),
          showBusLine
              ? _buildButton(
                  context: context,
                  title: "قائمة الأسعار",
                  icon: Icon(
                    Icons.article_outlined,
                    color: Colors.white,
                  ),
                  backgroundColor: AppColors.lightGreen,
                  onTap: () async {
                    Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) =>
                            FullTrafficImage(
                              imageUrl: "assets/shuttle_bus_prices.png",
                            )));
                  })
              : SizedBox(),
          showBusLine
              ? _buildButton(
                  context: context,
                  title: ' تتبع رحلتك',
                  icon: Image.asset(
                    "assets/route_ic.png",
                  ),
                  backgroundColor: Color(0xfff5143b),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                SwvlLineListScreen()));
                  })
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildButton({title, backgroundColor, icon, onTap, context}) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 0,
                    ),
                    icon,
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: backgroundColor,
              ),
            ),
          ),
          onTap: () {
            onTap();
          }),
    );
  }
}
