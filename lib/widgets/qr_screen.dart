import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:barcode_widget/barcode_widget.dart';

class QRScreen extends StatefulWidget {

  QRScreen(
  );

  @override
  State<StatefulWidget> createState() {
    return QRScreenState();
  }
}

class QRScreenState extends State<QRScreen> {
  User user = User();

  @override
  void initState() {
    super.initState();
    this.user = LocalSettings.user ?? User(user_name: "ايمن " , id: 194545421248452);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              "المحتوى",
            ),
            leading: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          body: buildContent(context),
    ));
  }


  Widget buildContent(BuildContext context) {
    // String value ="رقم العضوية : ${user.id} \n الاسم ${user.user_name}";
    String value ="رقم العضوية : ${user.id}  ,  الاسم ${user.user_name}";
    print(value);

    return Center(
      child:
      Container(
        height: 200,
        child:
        BarcodeWidget(
          barcode: Barcode.qrCode(),
          data: value,
          errorBuilder: (context, error) => Center(child: Text(error)),
        )
        // SfBarcodeGenerator(
        //   value: value,
        //   symbology: QRCode( ),
        //   showValue: true,
        // ),

        // QrImage(
        //   data: value,
        //   version: QrVersions.auto,
        //   size: 200.0,
        // ),
      )
    );
  }

}
