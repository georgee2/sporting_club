import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sporting_club/data/model/restaurant_image.dart';
import 'dart:ui' as ui;

class FullAdsView extends StatelessWidget {
  String _imageUrl = "";
  Function _adsAction;
  Function closeDialog;

  FullAdsView(this._imageUrl, this._adsAction, this.closeDialog);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xff081909).withOpacity(0.75),
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   // <-- APPBAR WITH TRANSPARENT BG
      //   elevation: 0,
      //   leading: ,
      //   automaticallyImplyLeading: true, // Used for removing back buttoon.
      // ),
      body: Stack(
        children: <Widget>[
          Container(
            height: kToolbarHeight,
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              icon: new Image.asset('assets/close_green_ic.png'),
              onPressed: () {
                closeDialog();
              },
            ),
            margin: EdgeInsets.only(top: 20),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: (_imageUrl != null && _imageUrl != "")
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: 15, right: 15, left: 15, bottom: 15),
                      child: GestureDetector(
                        onTap: () {
                          _adsAction();
                        },
                        child: Stack(
                          children: <Widget>[
                            Image.network(_imageUrl,fit: BoxFit.cover,
                              loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null)
                                  return child;
                                return  Container(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor:
                                      Color.fromRGBO(0, 112, 26, 1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color.fromRGBO(118, 210, 117, 1)),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // FutureBuilder<ui.Image>(
                            //     future: _getImage(_imageUrl),
                            //     builder: (BuildContext context,
                            //         AsyncSnapshot<ui.Image> snapshot) {
                            //       if (snapshot.hasData) {
                            //         return IconButton(
                            //           icon: new Image.asset(
                            //               'assets/close_green_ic.png'),
                            //           onPressed: () {
                            //             closeDialog();
                            //           },
                            //         );
                            //       }
                            //       return SizedBox();
                            //     }),
                          ],
                        ),
                      ),
                    )

                  // buildGallery(menus, context)
                  : Image.asset(
                      'assets/placeholder_2.png',
                      width: width - 50,
                      fit: BoxFit.fitWidth,
                    ),
            ),
          )
        ],
      ),
    );
  }

  Future<ui.Image> _getImage(String index) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    final String url = index;
    Image image = Image.network(url);

    image.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool isSync) {
      print(info.image.width);
      print(info.image.height);
      completer.complete(info.image);
    }));

    return completer.future;
  }
}
