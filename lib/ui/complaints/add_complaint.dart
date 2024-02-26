import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sporting_club/data/model/administratives_data.dart';
import 'package:sporting_club/data/model/category.dart';
import 'package:sporting_club/delegates/complaints_delegate.dart';
import 'package:sporting_club/network/listeners/AddComplaintResponseListener.dart';
import 'package:sporting_club/network/repositories/complaints_netwrok.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/utilities/validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddComplaint extends StatefulWidget {
  ComplaintsDelegate _complaintsDelegate;

  AddComplaint(this._complaintsDelegate);

  @override
  State<StatefulWidget> createState() {
    return AddComplaintState(this._complaintsDelegate);
  }
}

class AddComplaintState extends State<AddComplaint>
    implements AddComplaintResponseListener {
  ComplaintsDelegate _complaintsDelegate;
  bool _isloading = false;
  final _contentController = TextEditingController();
  File? _image;
  String? _imageName;
  String _imageurl = "";

  Validation _validation = Validation();
  ComplaintsNetwork _complaintsNetwork = ComplaintsNetwork();

  List<Category> _administratives = [];
  List<PopupMenuItem<Category>> _dropdownMenuItems = [];
  Category? _selectedAdministrative;

  bool isValidAdministrative = true;
  bool isValidContent = true;

  AddComplaintState(this._complaintsDelegate);

  @override
  void initState() {
    _complaintsNetwork.getAdministrativesList(this);
    super.initState();
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
                  image: AssetImage("assets/complaint_background.png"),
                  fit: BoxFit.fill,
                ),
              ),
              height: 200,
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
                  padding: EdgeInsets.only(top: 135, left: 15),
                  child: Image.asset('assets/submit_review.png'),
                ),
                alignment: Alignment.topLeft,
              ),
              onTap: () => _submitComplaint(),
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
                'شكوى جديدة',
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
              alignment: Alignment.centerRight,
            ),
          ),
          SizedBox(
            height: 75,
          ),
          _buildComplaintContent(),
        ],
      ),
    );
  }

  Widget _buildComplaintContent() {
    double width = MediaQuery.of(context).size.width;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20, top: 5, left: 10),
              child: Align(
                child: Text(
                  'الجهة المختصة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff646464),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                alignment: Alignment.centerRight,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _buildDropDown(),
            _buildErrorText(
                "برجاء إدخال إسم الجهة المختصة", isValidAdministrative),
            Padding(
              padding: EdgeInsets.only(right: 20, top: 30, left: 10),
              child: Align(
                child: Text(
                  'الشكوى',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff646464),
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
              height: 120,
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
                controller: _contentController,
                style: TextStyle(fontSize: 15, color: Colors.black),
                maxLines: 5,
                // textInputAction: TextInputAction.newline,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
//                contentPadding:
//                EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 8),
                  hintText: 'قم بكتابة الشكوى هنا',
                ),
                // keyboardType: TextInputType.text,
                keyboardType: TextInputType.multiline,
                // maxLines: null,
                keyboardAppearance: Brightness.light,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(255),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            _buildErrorText("برجاء إدخال نص الرسالة", isValidContent),
            SizedBox(
              height: 20,
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
                            child: (_image != null &&
                                    (_image?.path.isNotEmpty ?? false))
                                ? Image.file(
                                    _image ?? File(""),
                                    fit: BoxFit.cover,
                                  )
                                : FadeInImage.assetNetwork(
                                    placeholder: 'assets/placeholder_2.png',
                                    image: _imageurl,
                                    imageErrorBuilder: (c, t, o) {
                                      return Image.asset(
                                          'assets/placeholder_2.png');
                                    },
                                    fit: BoxFit.cover,
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
                          _imageName ?? "",
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

  Widget myPopMenu() {
    return PopupMenuButton(
        onSelected: (value) {},
        itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("a"),
              ),
            ]);
  }

  Widget _buildDropDown() {
    double width = MediaQuery.of(context).size.width;
    double viewWidth = _administratives.length > 0 ? width - 120 : width - 120;
    return Container(
      child: Container(
        child: PopupMenuButton(
          offset: Offset(
            -viewWidth, // horizontal, move right 10
            35.0, // vertical, move down 10
          ),
          // icon: Image.asset('assets/dropdown_ic.png'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(_selectedAdministrative == null
                  ? "الجهة المختصة"
                  : _selectedAdministrative?.name ?? ""),
              Image.asset('assets/dropdown_ic.png'),
            ],
          ),
          padding: EdgeInsets.only(right: 50),
          onSelected: onChangeDropdownItem,
          itemBuilder: (context) => _dropdownMenuItems,
        ),
        // width: viewWidth,
      ),
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
      height: 50,
      padding: EdgeInsets.only(left: 15, bottom: 0, right: 15, top: 0),
      margin: EdgeInsets.only(left: 15, bottom: 5, right: 15, top: 5),
    );
  }

  Widget _buildErrorText(String error, bool isValid) {
    return Align(
      child: Visibility(
        child: Container(
          child: Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
          margin: EdgeInsets.only(right: 25),
        ),
        visible: !isValid,
      ),
      alignment: Alignment.centerRight,
    );
  }

  List<PopupMenuItem<Category>> buildDropdownMenuItems(List administratives) {
    List<PopupMenuItem<Category>> items = [];
    double width = MediaQuery.of(context).size.width;
    double viewWidth = width - 90;
    for (Category administrative in administratives) {
      items.add(
        PopupMenuItem(
          value: administrative,
          child: Align(
            child: Text(
              administrative.name ?? "",
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: _selectedAdministrative == administrative
                      ? Color(0xff43a047)
                      : null),
            ),
            alignment: Alignment.centerRight,
          ),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItem(Category selectedAdministrative) {
    setState(() {
      _selectedAdministrative = selectedAdministrative;
      _dropdownMenuItems = buildDropdownMenuItems(_administratives);
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

  Future<void> getImage(ImageSource source) async {
    XFile? xImageFile;
    if (Platform.isAndroid) {
//      imageFile = await ImagePicker.pickImage(
//          source: source, maxWidth: 600, maxHeight: 600);
      xImageFile = await ImagePicker().pickImage(
        source: source,
      );
    } else {
      xImageFile = await ImagePicker().pickImage(
        source: source,
      );
    }
    final File imageFile = File(xImageFile?.path ?? "");

    if (_validation.isValidImage(context, imageFile)) {
      setState(() {
        _image = imageFile;
        _imageName = path.basename(imageFile.path);
        print("name: $_imageName");
      });
    }
  }

  void checkCameraPermission() async {
    if (Platform.isIOS) {
      print('add image click');
      PermissionStatus status = await Permission.camera.status;
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

  void _submitComplaint() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (validateFields()) {
      if (_image != null && (_image?.path.isNotEmpty ?? false)) {
        ImageProperties properties =
            await FlutterNativeImage.getImageProperties(_image?.path ?? "");
        File compressedFile = await FlutterNativeImage.compressImage(
            _image?.path ?? "",
            quality: 80,
            targetWidth: ((properties.width ?? 0) * (2 / 3)).round(),
            targetHeight: ((properties.height ?? 0) * (2 / 3)).round());
        _complaintsNetwork.addComplaint(_contentController.text, compressedFile,
            _selectedAdministrative?.id ?? "", this);
      } else {
        _complaintsNetwork.addComplaint(_contentController.text,
            _image ?? File(""), _selectedAdministrative?.id ?? "", this);
      }
    }
  }

  bool validateFields() {
    bool isValid = true;
    if (_contentController.text.isEmpty) {
      setState(() {
        isValidContent = false;
      });
      isValid = false;
    } else {
      setState(() {
        isValidContent = true;
      });
    }

    if (_selectedAdministrative == null) {
      setState(() {
        isValidAdministrative = false;
      });
      isValid = false;
    } else {
      setState(() {
        isValidAdministrative = true;
      });
    }
    return isValid;
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
    Fluttertoast.showToast(
        msg: "حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(
        msg: "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showServerError(String? msg) {
    Fluttertoast.showToast(msg: msg ?? "", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showAuthError() {
    TokenUtilities tokenUtilities = TokenUtilities();
    tokenUtilities.refreshToken(context);
  }

  @override
  void setAdministratives(AdministrativesData? administrativesData) {
    if (administrativesData?.administratives != null) {
      _administratives = administrativesData?.administratives ?? [];
    }
    _dropdownMenuItems = buildDropdownMenuItems(_administratives);
  }

  @override
  void showSuccess() {
    if (_complaintsDelegate != null) {
      _complaintsDelegate.addComplaintSuccessfully();
    }
    Navigator.pop(context);
  }
}
