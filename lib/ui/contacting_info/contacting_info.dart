import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sporting_club/data/model/contacting_info_data.dart';
import 'package:sporting_club/data/model/contacting_info.dart'
    as ContactingData;
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/listeners/ContactingInfoResponseListener.dart';
import 'package:sporting_club/network/repositories/info_network.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactingInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ContactingInfoState();
  }
}

class ContactingInfoState extends State<ContactingInfo>
    implements ContactingInfoResponseListener, NoNewrokDelagate {
  List<Marker> allMarkers = [];
  bool _isloading = false;
  bool _isNoNetwork = false;
  bool _isSuccess = false;
  ContactingData.ContactingInfo _contactingInfo =
      ContactingData.ContactingInfo();
  double latitude = 0.0;
  double longitude = 0.0;
  InfoNetwork _infoNetwork = InfoNetwork();
  GoogleMapController? _controller;

  @override
  void initState() {
    _infoNetwork.getContactingInfo(this);
    super.initState();
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
              'وسائل التواصل',
            ),
            leading: IconButton(
              icon: new Image.asset('assets/back_white.png'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ),
          backgroundColor: Color(0xfff9f9f9),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'All Copy Rights Reserved@SportingClub(2019-2020)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
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

  Widget _buildContent() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
        child: _isNoNetwork
            ? _buildImageNetworkError()
            : Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        height: height / 3,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                              target: LatLng(latitude, longitude), zoom: 15.0),
                          markers: Set.from(allMarkers),
                          onMapCreated: mapCreated,
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      Container(
                        color: Colors.white,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 20,
                                ),
                                Image.asset(
                                  'assets/telephone_ic.png',
                                  width: 18,
                                  fit: BoxFit.fitWidth,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  'تليفون النادي',
                                  style: TextStyle(
                                      color: Color(0xff43a047), fontSize: 18),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 5),
                              child: Align(
                                child: Text(
                                  _contactingInfo.phone ??"",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            height: 110,
                            width: width,
                            padding: EdgeInsets.only(top: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 190,
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Image.asset(
                                        'assets/email_ic.png',
                                        width: 18,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        'البريد الإلكتروني',
                                        style: TextStyle(
                                            color: Color(0xff43a047),
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: width - 190,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 5),
                                    child: Align(
                                      child: Text(
                                        _contactingInfo.email ??"",
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      alignment: Alignment.topLeft,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 110),
                            child: Divider(
                              height: 1,
                            ),
                          ),
                          _buildSocialLinks(),
                        ],
                      ),
                    ],
                  ),
                  _isSuccess
                      ? SizedBox()
                      : Container(
                          height: height,
                          width: width,
                          color: Color(0xfff9f9f9),
                        ),
                ],
              ));
  }

  Widget _buildSocialLinks() {
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 0, top: 90, bottom: 20),
      child: Center(
        child: Container(
          alignment: Alignment.center,
          height: 55,
          width: 280,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 0,
              ),
              GestureDetector(
                child: _buildSocialItem(
                  "assets/instagram_ic.png",
                  'Instagram',
                  Color(0xffe4405f),
                ),
                onTap: () => _launchURL(
                    _contactingInfo.instagram ??""),
              ),
              SizedBox(
                width: 20,
              ),

              GestureDetector(
                child: _buildSocialItem(
                  "assets/youtube.png",
                  'Youtube',
                  Color(0xfff12b10),
                ),
                onTap: () => _launchURL(_contactingInfo.youtube ??""),
              ),

              SizedBox(
                width: 20,
              ),
              GestureDetector(
                child: _buildSocialItem(
                  "assets/twitter_ic.png",
                  'Twitter',
                  Color(0xff55acee),
                ),
                onTap: () => _launchURL(_contactingInfo.twitter ??""),
              ),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                child: _buildSocialItem(
                  "assets/facebook_ic.png",
                  'Facebook',
                  Color(0xff3b5999),
                ),
                onTap: () => _launchURL(_contactingInfo.facebook ??""),
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 8.0, // has the effect of softening the shadow
                spreadRadius: 5.0, // has the effect of extending the shadow
                offset: Offset(
                  0.0, // horizontal, move right 10
                  0.0, // vertical, move down 10
                ),
              ),
            ],
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialItem(String imageName, String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        imageName.contains('youtube')
            ? Image.asset(
                imageName,
                width: 23,
                height: 17,
                fit: BoxFit.fill,
              )
            : Image.asset(
                imageName,
              ),
        SizedBox(
          height: imageName.contains('youtube') ? 6 : 0,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: color),
        )
      ],
    );
  }

  Widget _buildImageNetworkError() {
    double height = MediaQuery.of(context).size.height;
    double topPadding = (height - 250) / 2.6;
    if (topPadding < 0) {
      topPadding = 60;
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: NoNetwork(this),
    );
  }
  _launchURL(String value) async {
    String url = value;

    if (await canLaunch(url)){
      await launch(url);
    }
    else{
      throw "Could not launch $url";
    }
  }

  _twitterLaunchURL(String value) async {
    String url = "https://twitter.com/" + value;

    try {
      bool launched = await UrlLauncher.launch(url, forceSafariVC: false);
      if (!launched) {
        print('is not lanucehd');
        await UrlLauncher.launch(url, forceSafariVC: false);
      } else {
        print(' lanucehd');
      }
    } catch (e) {
      await UrlLauncher.launch(url, forceSafariVC: false);
    }
  }

  _fbLaunchURL(String url) async {
    String fbProtocolUrl = "fb://page/" + url;
    String fallbackUrl = "https://www.facebook.com/" + url;
    if(Platform.isIOS){
      try {
        bool launched =
        await UrlLauncher.launch(fallbackUrl, forceSafariVC: false);
        if (!launched) {
          await UrlLauncher.launch(fallbackUrl, forceSafariVC: false);
        }
      } catch (e) {
        await UrlLauncher.launch(fallbackUrl, forceSafariVC: false);
      }
    }else{
      try {
        bool launched =
        await UrlLauncher.launch(fbProtocolUrl, forceSafariVC: false);
        if (!launched) {
          await UrlLauncher.launch(fallbackUrl, forceSafariVC: false);
        }
      } catch (e) {
        await UrlLauncher.launch(fallbackUrl, forceSafariVC: false);
      }
    }
  }

  _instagramLaunchURL(String value) async {
    String url = "https://www.instagram.com/" + value;
    try {
      bool launched = await UrlLauncher.launch(url);
      if (!launched) {
        print('is not lanucehd');
        await UrlLauncher.launch(url);
      } else {
        print(' lanucehd');
      }
    } catch (e) {
      await UrlLauncher.launch(url);
    }
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  _youtubeLaunchURL(String value) async {
    if (Platform.isIOS) {
      if (await UrlLauncher.canLaunch(
          'youtube://www.youtube.com/channel/' + value)) {
        await UrlLauncher.launch('youtube://www.youtube.com/channel/' + value,
            forceSafariVC: false);
      } else {
        if (await UrlLauncher.canLaunch(
            'https://www.youtube.com/channel/' + value)) {
          await UrlLauncher.launch('https://www.youtube.com/channel/' + value);
        } else {
          throw 'Could not launch https://www.youtube.com/channel/' + value;
        }
      }
    } else {
      String url = 'https://www.youtube.com/channel/' + value;
      if (await UrlLauncher.canLaunch(url)) {
        await UrlLauncher.launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void moveToLocation() {
    _controller?.moveCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(this.latitude, this.longitude), zoom: 15.0),
    ));
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(this.latitude, this.longitude)));
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
    Fluttertoast.showToast(msg:"حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(msg:
        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showServerError(String? msg) {
    Fluttertoast.showToast(msg:msg??"", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
  }

  @override
  void setData(ContactingInfoData? data) {
    if (data?.contact_us != null) {
      setState(() {
        this._contactingInfo = data?.contact_us??ContactingData.ContactingInfo();
        this.latitude = _contactingInfo.lat != null
            ? double.parse(_contactingInfo.lat??"0")
            : 0.0;
        this.longitude = _contactingInfo.lang != null
            ? double.parse(_contactingInfo.lang??"0")
            : 0.0;
        moveToLocation();
        _isSuccess = true;
        _isNoNetwork = false;
      });
    }
  }

  @override
  void reloadAction() {
    _infoNetwork.getContactingInfo(this);
  }
}
