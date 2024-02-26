import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/data/model/review_data.dart';
import 'package:sporting_club/delegates/add_review_delegate.dart';
import 'package:sporting_club/network/listeners/BasicResponseListener.dart';
import 'package:sporting_club/network/listeners/ReviewResponseListener.dart';
import 'package:sporting_club/network/repositories/review_network.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class AddReview extends StatefulWidget {
  String _postID = "";
  bool _hasReview = false;
  bool _validReview = true;

  bool _isEvent = false;
  String _reviewID;
  AddReviewDelegate _addReviewDelegate;

  AddReview(this._postID, this._hasReview, this._reviewID, this._isEvent,
      this._addReviewDelegate,this._validReview);

  @override
  State<StatefulWidget> createState() {
    return AddReviewState(this._postID, this._hasReview, this._reviewID,
        this._isEvent, this._addReviewDelegate,this._validReview);
  }
}

class AddReviewState extends State<AddReview>
    implements ReviewResponseListener {
  String _postID = "";
  bool _hasReview = false;
  bool _validReview = false;

  bool _isEvent = false;
  String _reviewID;
  AddReviewDelegate _addReviewDelegate;

  bool _isloading = false;
  final _reviewController = TextEditingController();
  File? _image=File("");
  String _imageName="";
  String _imageurl = "";

  Validation _validation = Validation();
  ReviewNetwork _reviewNetwork = ReviewNetwork();

  int _rating = 0;
  String _ratingStr = "";

  AddReviewState(this._postID, this._hasReview, this._reviewID, this._isEvent,
      this._addReviewDelegate,this._validReview);

  @override
  void initState() {
    super.initState();
    if (_hasReview) {
      print('get Review');
      _reviewNetwork.getReview(_postID, _reviewID, _isEvent, this);
    } else {
      print("doesn't have Review");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Container(
              color: Color(0xfff5f5f5),
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/intersection_3.png"),
                  fit: BoxFit.fill,
                ),
              ),
              height: 280,
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                // <-- APPBAR WITH TRANSPARENT BG
                elevation: 0,

                leading: IconButton(
                  icon: new Image.asset('assets/back_white.png'),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                // <-- ELEVATION ZEROED
                automaticallyImplyLeading:
                    true, // Used for removing back buttoon.
              ),
              body: SafeArea(
                child: _buildContent(),
              ),
            ),
            GestureDetector(
              child: Align(
                child: Padding(
                  padding: EdgeInsets.only(top: 180, left: 15),
                  child: Image.asset('assets/submit_review.png'),
                ),
                alignment: Alignment.topLeft,
              ),
              onTap: () => _submitReview(),
            ),
          ],
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
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20, top: 5, left: 10),
            child: Align(
              child: Text(
                'اضف رأي وتقييم',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20, top: 35, left: 10),
            child: Align(
              child: Text(
                'تقييم',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              alignment: Alignment.centerRight,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15, top: 10, left: 5),
            child: Align(
              child: _buildStarts(),
              alignment: Alignment.centerRight,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          _buildReviewContent(),
        ],
      ),
    );
  }

  Widget _buildStarts() {
    return Container(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new GestureDetector(
                child: new Icon(
                  Icons.star,
                  size: 40,
                  color: _rating >= 1 ? Color(0xfff0ee4f) : Color(0xff43a047),
                ),
                onTap: () => rate(1),
              ),
              new GestureDetector(
                child: new Icon(
                  Icons.star,
                  size: 40,
                  color: _rating >= 2 ? Color(0xfff0ee4f) : Color(0xff43a047),
                ),
                onTap: () => rate(2),
              ),
              new GestureDetector(
                child: new Icon(
                  Icons.star,
                  size: 40,
                  color: _rating >= 3 ? Color(0xfff0ee4f) : Color(0xff43a047),
                ),
                onTap: () => rate(3),
              ),
              new GestureDetector(
                child: new Icon(
                  Icons.star,
                  size: 40,
                  color: _rating >= 4 ? Color(0xfff0ee4f) : Color(0xff43a047),
                ),
                onTap: () => rate(4),
              ),
              new GestureDetector(
                child: new Icon(
                  Icons.star,
                  size: 40,
                  color: _rating >= 5 ? Color(0xfff0ee4f) : Color(0xff43a047),
                ),
                onTap: () => rate(5),
              )
            ],
          ),
          Center(
            child: Text(
              _ratingStr,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xfff0ee4f),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContent() {
    double width = MediaQuery.of(context).size.width;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20, top: 20, left: 10),
              child: Align(
                child: Text(
                  'إضافة رأي',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                alignment: Alignment.centerRight,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: width - 30,
              height: 100,
              padding: EdgeInsets.only(bottom: 5, right: 10, left: 10, top: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
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
                color: Colors.white,
              ),
              child: TextField(
                controller: _reviewController,
                style: TextStyle(fontSize: 15, color: Colors.black),
                maxLines: 5,
                // textInputAction: TextInputAction.newline,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
//                contentPadding:
//                EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 8),
                  hintText: 'اكتب رأيك هنا',
                ),
                keyboardType: TextInputType.multiline,
                keyboardAppearance: Brightness.light,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(255),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _buildAddImage(),
            _buildUploadedImage(),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImage() {
    return _image == null && _imageurl == ""
        ? Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Align(
                  child: GestureDetector(
                    child: Image.asset(
                      'assets/path_red.png',
                      height: 60,
                      width: 150,
                      fit: BoxFit.fill,
                    ),
                    onTap: _showImageDialog,
                  ),
                  alignment: Alignment.centerRight,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 25, top: 15),
                child: Align(
                  child: GestureDetector(
                    child: Image.asset(
                      'assets/page_title.png',
                      height: 22,
                      width: 25,
                      fit: BoxFit.fitHeight,
                    ),
                    onTap: _showImageDialog,
                  ),
                  alignment: Alignment.centerRight,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 52, top: 13),
                child: Align(
                  child: GestureDetector(
                    child: Text(
                      'إرفاق صورة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: _showImageDialog,
                  ),
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          )
        : Container();
  }

  Widget _buildUploadedImage() {
    double width = MediaQuery.of(context).size.width;
    return _image != null || _imageurl != ""
        ? Stack(
            children: <Widget>[
              Container(
//                width: 300,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 15, top: 5),
                      child: Align(
                        child: Container(
                          width: 90,
                          height: 90,
                          padding: EdgeInsets.only(
                              bottom: 0, right: 0, left: 0, top: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.2),
                                blurRadius:
                                    8.0, // has the effect of softening the shadow
                                spreadRadius:
                                    0.0, // has the effect of extending the shadow
                                offset: Offset(
                                  0.0, // horizontal, move right 10
                                  0.0, // vertical, move down 10
                                ),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: (_image != null&&(_image?.path.isNotEmpty??false))
                                ? Image.file(
                                    _image??File(""),
                                    fit: BoxFit.fill,
                                  )
                                : FadeInImage.assetNetwork(
                                    placeholder: 'assets/placeholder_2.png',
                                    imageErrorBuilder: (c, t, o){
                                      return Image.asset( 'assets/placeholder_2.png');
                                    },
                                    image: _imageurl,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      width: width - 150,
                      child: Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          _imageName,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(right: 82, top: 8),
                  child: Align(
                    child: Image.asset(
                      'assets/close_ic_1.png',
                      height: 20,
                      fit: BoxFit.fitHeight,
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _image = null;
                    _imageName = "";
                    _imageurl = "";
                  });
                },
              )
            ],
          )
        : SizedBox();
  }

  void rate(int rating) {
    //Other actions based on rating such as api calls.
    setState(() {
      _rating = rating;
      switch (rating) {
        case 1:
          _ratingStr = "سيء للغاية";
          break;
        case 2:
          _ratingStr = "سيء";
          break;
        case 3:
          _ratingStr = "جيد";
          break;
        case 4:
          _ratingStr = "جيد جداً";
          break;
        case 5:
          _ratingStr = "ممتاز";
          break;
        default:
          break;
      }
    });
  }

  void _showImageDialog() {
    print('add image click');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            content:
//          Align(
//            child:
                new Text(
              "اختر صورة",
              textAlign: TextAlign.right,
            ),
//            alignment: Alignment.centerRight,
//          ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: new Text(
                  "الصور",
                  style: TextStyle(color: Color(0xff43a047)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  getImage(ImageSource.gallery);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: new Text(
                  "كاميرا",
                  style: TextStyle(color: Color(0xff43a047)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  checkCameraPermission();
                },
              ),
            ],
          ),
          height: 50,
        );
      },
    );
  }

  void _submitReview() async {
    print('_submitReview');
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_rating != 0) {
      if (_isEvent && !_validReview) {
        Fluttertoast.showToast(msg:'! التقييم غير متاح بعد', toastLength: Toast.LENGTH_LONG);
      }else{
        bool update_image = false;
        if (_image != null&&(_image?.path.isNotEmpty??false)) {
          //the is an image so it's updated
          update_image = true;
        } else if (_imageurl == "") {
          //the is no image and no url so it's updated that image deleted
          update_image = true;
        }
        if (_image != null&&(_image?.path.isNotEmpty??false)) {
          ImageProperties properties =
          await FlutterNativeImage.getImageProperties(_image?.path??"");
          File compressedFile = await FlutterNativeImage.compressImage(
              _image?.path??"",
              quality: 80,
              targetWidth: ((properties.width ??0)* (2 / 3)).round(),
              targetHeight: ((properties.height??0) * (2 / 3)).round());
          _reviewNetwork.setReview(
              _postID,
              _rating,
              _reviewController.text,
              compressedFile,
              _hasReview,
              _reviewID,
              update_image,
              _isEvent,
              this);
        } else {
          _reviewNetwork.setReview(
              _postID,
              _rating,
              _reviewController.text,
              _image??File(""),
              _hasReview,
              _reviewID,
              update_image,
              _isEvent,
              this);
        }
      }
      } else {
        Fluttertoast.showToast(msg:'من فضلك اضف التقييم', toastLength: Toast.LENGTH_LONG);
      }

  }

  void checkCameraPermission() async {
    if (Platform.isIOS) {
      print('add image click');
      PermissionStatus status = await Permission.camera.status
      ;
      if (status == PermissionStatus.denied) {
        print("PermissionStatus.denied");
        _showPermissionDialog();
      } else {
        getImage(ImageSource.camera);
      }
    } else {
      getImage(ImageSource.camera);
    }
  }

  void _showPermissionDialog() {
    print('add image click');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            content:
//          Align(
//            child:
                new Text(
              "برجاء السماح لنا باستخدام الكاميرا",
              textAlign: TextAlign.right,
            ),
//            alignment: Alignment.centerRight,
//          ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: new Text(
                  "الإعدادات",
                  style: TextStyle(color: Color(0xff43a047)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                 openAppSettings();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: new Text(
                  "إلغاء",
                  style: TextStyle(color: Color(0xff43a047)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          height: 50,
        );
      },
    );
  }

  Future<void> getImage(ImageSource source) async {
    XFile? xImageFile;
    if (Platform.isAndroid) {
      xImageFile = await ImagePicker().pickImage(
          source: source, maxWidth: 600, maxHeight: 600);
    } else {
      xImageFile = await ImagePicker().pickImage(
        source: source,
      );
    }
    final File imageFile = File(xImageFile?.path??"");
    if (_validation.isValidImage(context, imageFile)) {
      setState(() {
        _image = imageFile;
        _imageName = path.basename(imageFile.path);
        print("name: " + _imageName);
      });
    }
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
  void showSuccess(ReviewData? reviewData) {
    if (_addReviewDelegate != null && !_hasReview) {
      if (reviewData?.review?.comment != null) {
        _addReviewDelegate.addReviewSuccessfully(reviewData?.review?.comment??0);
      }
    }
    Navigator.pop(context);
  }

  @override
  void setReview(ReviewData? reviewData) {
    print("setReview");
    if (reviewData?.review != null) {
      setState(() {
        _reviewController.text = reviewData?.review?.comment_content??"";
        _rating = reviewData?.review?.rate != null
            ? int.parse(reviewData?.review?.rate??"0")
            : 0;
        rate(_rating);
        _imageurl =
            reviewData?.review?.image ?? "";

        _imageName = "";
      });
    }
  }
}
