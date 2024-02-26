import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:ui' as ui;

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<ui.Image>(
            future: _getImage(url),
            builder:
                (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              if (snapshot.hasData) {
                return Container(
                  height: snapshot.data?.height.toDouble(),
                  // width: snapshot.data.width.toDouble(),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    imageBuilder: (context, imageProvider) => PhotoView(
                      imageProvider: imageProvider,
                      backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),

                    )
                    // ScalableImage(
                    // imageProvider: imageProvider,
                    // dragSpeed: 4.0,
                    // maxScale: 16.0)
                    ,
                    placeholder: (context, url) =>
                        Image.asset("assets/placeholder.png"),
                    fit: BoxFit.contain,
                  ),
                );
              }
              return SizedBox();
            }),
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
      completer.complete(info.image);
    }));

    return completer.future;
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key? key, required this.url}) : super(key: key);

  @override
  State createState() => new FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key? key, required this.url});

  @override
  void initState() {
    super.initState();
    _getImage(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff081909).withOpacity(0.75),
      body: Container(
        color: Colors.transparent,
        child: Center(
          child: FutureBuilder<ui.Image>(
              future: _getImage(url),
              builder:
                  (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: snapshot.data?.height.toDouble(),
                    // width: snapshot.data.width.toDouble(),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      imageBuilder: (context, imageProvider) => PhotoView(
                        imageProvider: imageProvider,
                        backgroundDecoration:
                            BoxDecoration(color: Colors.transparent),
                      )
                      // ScalableImage(
                      // imageProvider: imageProvider,
                      // dragSpeed: 4.0,
                      // maxScale: 16.0)
                      ,
                      placeholder: (context, url) =>
                          Image.asset("assets/placeholder.png"),
                      fit: BoxFit.contain,
                    ),
                  );
                }
                return SizedBox();
              }),
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
      completer.complete(info.image);
    }));

    return completer.future;
  }
}
