import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sporting_club/data/model/restaurant_image.dart';
import 'dart:ui' as ui;

class FullTrafficImage extends StatelessWidget {
  final String imageUrl;

  FullTrafficImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var isNetwork = false;
    if (imageUrl.startsWith('http')) {
      isNetwork = true;
    }
    return Scaffold(
      backgroundColor: Color(0xff081909).withOpacity(0.75),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // <-- APPBAR WITH TRANSPARENT BG
        elevation: 0,
        leading: IconButton(
          icon: new Image.asset('assets/close_green_ic.png'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        automaticallyImplyLeading: true, // Used for removing back buttoon.
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: PhotoView(
            customSize: imageUrl.isEmpty ? Size(50, 50) : null,
            imageProvider: imageUrl.isNotEmpty
                ? (isNetwork
                    ? Image.network(
                        imageUrl,
                        errorBuilder: (c, t, o) {
                          return Image.asset(
                            'assets/placeholder_2.png',
                          );
                        },
                      ).image
                    : Image.asset(imageUrl).image)
                : Image.asset(
                    'assets/placeholder_2.png',
                  ).image,
            loadingBuilder: (cx, chunck) {
              return Center(
                child: CircularProgressIndicator(
                    value: (chunck != null) && chunck.expectedTotalBytes != null
                        ? (chunck.cumulativeBytesLoaded /
                            (chunck.expectedTotalBytes ?? 1))
                        : null),
              );
            },
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
          ),
          // FutureBuilder<ui.Image>(
          //     future: _getImage(imageUrl),
          //     builder:
          //         (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
          //       if (snapshot.hasData) {
          //         return Container(
          //           // width: width - 50,
          //           height: snapshot.data?.height.toDouble(),
          //           child:
          //           PhotoView(
          //             imageProvider: Image.asset(imageUrl).image,
          //             backgroundDecoration:
          //             BoxDecoration(color: Colors.transparent),
          //           ),

          //         );
          //       }
          //       return SizedBox();
          //     })
        ),
      ),
    );
  }

  Future<ui.Image> _getImage(String index) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    final String url = index;
    Image image = Image.asset(url);

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
