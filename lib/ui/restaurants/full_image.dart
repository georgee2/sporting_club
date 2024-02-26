import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sporting_club/data/model/restaurant_image.dart';
import 'dart:ui' as ui;

class FullImage extends StatelessWidget {
  String _imageUrl = "";
  List<RestaurantImage> gallery;
  int index;

  FullImage(this._imageUrl, {this.index = 0, this.gallery = const []});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
          child: _imageUrl != ""
              ?
              // FadeInImage.assetNetwork(
              //         placeholder: 'assets/placeholder_2.png',
              //         image: _imageUrl,
              //         width: width - 50,
              //         fit: BoxFit.fitWidth,
              //       )
              FutureBuilder<ui.Image>(
                  future: _getImage(_imageUrl),
                  builder:
                      (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                    if (snapshot.hasData) {
                      return (gallery != null&&gallery.isNotEmpty)
                          ? CarouselSlider(
                              options: CarouselOptions(
                                viewportFraction: 1.0,
                                initialPage: index,
                                enableInfiniteScroll: false,
                                reverse: true,
                                height: snapshot.data?.height.toDouble(),
                              ),

//                                    aspectRatio: 1,
//                                     height: snapshot.data.height.toDouble(),
                              // autoPlay: false,
                              items: gallery.map((item) {
                                _getImage(item.large ?? "");
                                return Container(
                                  // width: width - 50,
                                  height: snapshot.data?.height.toDouble(),
                                  child: CachedNetworkImage(
                                    imageUrl: item.large ?? "",
                                    imageBuilder: (context, imageProvider) =>
                                        PhotoView(
                                      imageProvider: imageProvider,
                                      backgroundDecoration: BoxDecoration(
                                          color: Colors.transparent),
                                    ),
                                    placeholder: (context, url) =>
                                        Image.asset("assets/placeholder_2.png"),
                                  ),
                                );
                              }).toList(),
                            )
                          : Container(
                              // width: width - 50,
                              height: snapshot.data?.height.toDouble(),
                              child: CachedNetworkImage(
                                imageUrl: _imageUrl,
                                imageBuilder: (context, imageProvider) =>
                                    PhotoView(
                                  imageProvider: imageProvider,
                                  backgroundDecoration:
                                      BoxDecoration(color: Colors.transparent),
                                ),
                                // ScalableImage(
                                //     imageProvider: imageProvider,
                                //     dragSpeed: 4.0,
                                //     maxScale: 16.0),

                                placeholder: (context, url) =>
                                    Image.asset("assets/placeholder_2.png"),
                                // width: width - 50,
                                // fit: BoxFit.cover,
                              ),
                            );
                    }
                    return SizedBox();
                  })
              // buildGallery(menus, context)
              : Image.asset(
                  'assets/placeholder_2.png',
                  width: width - 50,
                  fit: BoxFit.fitWidth,
                ),
        ),
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
