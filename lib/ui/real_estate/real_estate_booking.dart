import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sporting_club/data/model/real_estate/contract_category.dart';
import 'package:sporting_club/data/model/real_estate/contract_sub_category.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_available_dates.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_available_times_data.dart';
import 'package:sporting_club/data/model/real_estate/real_estate_contracts_data.dart';
import 'package:sporting_club/data/model/real_estate/time_slot.dart';
import 'package:sporting_club/data/model/real_estate/upcomming_booking.dart';
import 'package:sporting_club/data/model/real_estate/upcomming_booking_data.dart';
import 'package:sporting_club/data/model/real_estate/working_date.dart';
import 'package:sporting_club/data/model/user.dart';
import 'package:sporting_club/delegates/no_network_delegate.dart';
import 'package:sporting_club/network/listeners/RealEstateContractsResponseListener.dart';
import 'package:sporting_club/network/repositories/real_estate_network.dart';
import 'package:sporting_club/ui/real_estate/real_estate_reservations.dart';
import 'package:sporting_club/utilities/local_settings.dart';
import 'package:sporting_club/utilities/token_utilities.dart';
import 'package:sporting_club/widgets/no_network.dart';
import 'package:sporting_club/widgets/real_estate/upcomming_booking_view.dart';
import 'package:sporting_club/widgets/success_message_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RealEstateBookingScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return RealEstateBookingScreenState();
  }
}

class RealEstateBookingScreenState extends State<RealEstateBookingScreen> implements NoNewrokDelagate,RealEstateContractsResponseListener{

  bool _isLoading = false;
  bool _loadingWithBackground = true;
  bool _isNoNetwork = false;
  bool _showWebView = false;
  bool _showSuccessMessage = false;
  bool _lastSentRequestIsTheBookingRequest = false;
  String _upcommingBookingTitle = "";
  UpcommingBooking _upcommingBooking=UpcommingBooking();
  var _selectedDateController = TextEditingController();
  RealEstateNetwork _realEstateNetwork = RealEstateNetwork();

  ContractCategory? _selectedContractCategory;
  int? _selectedContractSubCategoryId;
  int? _selectedTimeIndex;
  User user = new User();

  RealEstateContractsData _contractsData = RealEstateContractsData();
  RealEstateAvailableTimesData _availableTimesData = RealEstateAvailableTimesData();

  List<WorkingDate> _availableDates = [];
  List<DropdownMenuItem<int>> _contractSubCategoriesDropdownItems = [];

  @override
  void initState() {
    super.initState();
    setUserData();
    _realEstateNetwork.checkUpcommingBooking(this);
  }
  void setUserData() {
    if (LocalSettings.user != null) {
      setState(() {
        this.user = LocalSettings.user??User();
      });
    } else {}
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text('حجز الشهر العقاري'),
            ),
            body: _isNoNetwork ? _buildImageNetworkError() : (_showSuccessMessage ?
            SuccessMessageView(message: "تم الحجز بنجاح") : ModalProgressHUD(
              child: (_upcommingBooking != null && _upcommingBooking.id != null) ?
              (_showWebView ?
              buildPaymentWebView(): RealEstateUpcommingBookingView(onCancelBooking: cancelBookingButtonAction,upcommingBooking: _upcommingBooking,upcommingBookingTitle: _upcommingBookingTitle,user: user))
                  : _buildNewBookingPageContent(),
              inAsyncCall: _isLoading,
              color: _loadingWithBackground ? Colors.white : Colors.transparent,
              opacity: 1,
              progressIndicator: CircularProgressIndicator(
                backgroundColor: Color.fromRGBO(0, 112, 26, 1),
                valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(118, 210, 117, 1)),
              ),
            ))
        )
    );
  }

  buildPaymentWebView(){
    return
      // WebviewScaffold(
      //   url: _upcommingBooking.link??"",
      //   initialChild: Container(
      //     color: Colors.white,
      //     child: const Center(
      //       child: Text('يرجى الانتظار ....'),
      //     ),
      //   ),
      // )
    WebView(
        initialUrl: _upcommingBooking.link??"",
        userAgent: 'random',
        javascriptMode: JavascriptMode.unrestricted,
        zoomEnabled: true,
        allowsInlineMediaPlayback: true,
        gestureNavigationEnabled: true,

    )
      ;
  }

  void cancelBookingButtonAction(){
    setState(() {
      _showWebView = true;
    });
  }

  void _onContractCategorySelection(ContractCategory? category) {
    setState(() {
      _selectedContractCategory = category;

      _refreshSubCategories();
      if (_lastConfirmedPickedDateIndex != null) {
        _getAvailableTimes();
      }
    });
  }

  @override
  void reloadAction() {
    setState(() {
      _isNoNetwork = false;

      if(_lastSentRequestIsTheBookingRequest){
        _sendBookingRequest();
      }else {
        _realEstateNetwork.checkUpcommingBooking(this);
      }
    });
  }

  _buildNewBookingPageContent(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(
            padding: EdgeInsets.only(top: 20,right: 15,left: 15),
            child: Text(
              "نوع العقد",
              style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
            ),
          ),

          (  _contractsData.categories!=null&&(_contractsData.categories?.length??0)==2)?
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 45,
                      child: Radio<ContractCategory>(
                        value:  _contractsData.categories?[0]??ContractCategory(),
                        activeColor: Color(0xffFF5C46),
                        groupValue: _selectedContractCategory,
                        onChanged: _onContractCategorySelection,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Image.asset("assets/contract_ic.png"),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top:10, right: 5),
                        child: Text(
                          // "عقود تمليك او ايجار تكست كبير جد ينزل على كذا سطر",
                          _contractsData.categories?[0].name??"",
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Color(0xff3A543F),fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 45,
                      child: Radio<ContractCategory?>(
                        value:  _contractsData.categories?[1],
                        activeColor: Color(0xffFF5C46),
                        groupValue: _selectedContractCategory,
                        onChanged: _onContractCategorySelection,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:10),
                      child: Image.asset("assets/contract_ic.png"),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top:10, right: 5),
                        child: Text(
                          // "عقود تمليك ",
                          _contractsData.categories?[1].name??"",
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Color(0xff3A543F),fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ):SizedBox(),
          // GridView.builder(
          //   shrinkWrap: true,
          //   physics: BouncingScrollPhysics(),
          //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //       crossAxisCount: 2,
          //       childAspectRatio: (MediaQuery.of(context).size.width - 30)/180 //ratio between width and height
          //   ),
          //   padding: EdgeInsetsDirectional.only(end: 20),
          //   itemCount: _contractsData.categories?.length ?? 0,
          //   itemBuilder: (_, index) {
          //     ContractCategory category = _contractsData.categories[index];
          //
          //     return Row(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: <Widget>[
          //         Container(
          //           height: 45,
          //           child: Radio<ContractCategory>(
          //             value: category,
          //             activeColor: Color(0xffFF5C46),
          //             groupValue: _selectedContractCategory,
          //             onChanged: _onContractCategorySelection,
          //           ),
          //         ),
          //         Padding(
          //           padding: EdgeInsets.only(top:10),
          //           child: Image.asset("assets/contract_ic.png"),
          //         ),
          //         Expanded(
          //           child: Padding(
          //             padding: EdgeInsets.only(top:10, right: 5),
          //             child: Text(
          //               "عقود تمليك ",
          //               // category.name,
          //               maxLines: 4,
          //               overflow: TextOverflow.ellipsis,
          //               style: TextStyle(color: Color(0xff3A543F),fontWeight: FontWeight.bold,),
          //             ),
          //           ),
          //         ),
          //       ],
          //     );
          //   },
          // ),
          Padding(
            padding: EdgeInsets.only(top: 10,right: 15,left: 15, bottom: 10),
            child: Text(
              "التصنيف",
              style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsetsDirectional.only(end: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton(
                    items: _contractSubCategoriesDropdownItems,
                    value: _selectedContractSubCategoryId,
                    disabledHint: Text(
                      "--إختار التصنيف--",
                      style: TextStyle(color: Color(0xffC6C6C6),fontSize: 14,),
                    ),
                    onChanged: (int? id) {
                      setState(() {
                        if(_selectedContractSubCategoryId != id){
                          _selectedContractSubCategoryId = id;
                        }
                      });
                    },
                    icon: Image.asset('assets/dropdown_ic.png'),
                  ),
                ),
              )
          ),
          Padding(
            padding: EdgeInsets.only(top: 25,right: 15,left: 15),
            child: Text(
              "تاريخ المقابلة",
              style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: (){
              _showDatePickerDialog(context);
            },
            child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 15,right: 15,bottom: 10,top: 5),
                padding: EdgeInsetsDirectional.only(start: 15,end: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Expanded(
                        child: TextField(
                          enabled: false,
                          controller: _selectedDateController,
                          style: TextStyle(color: Color(0xff314D38),fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "--اختيار الموعد--",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Color(0xffC6C6C6),fontSize: 14),
                          ),
                        ),
                      ),
                      Image.asset('assets/calender_ic.png'),
                    ])
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 15),
          //   child: Text("* مواعيد العمل ( الأحد-الثلاثا،-الخميس ) من ٩ص الي ٢م",
          //     style: TextStyle(color: Color(0xff707070), fontWeight: FontWeight.bold ,fontSize: 12),
          //   ),
          // ),
          _selectedDateController.text.isNotEmpty ? _buildTimeSelectionView() : SizedBox()
        ]);
  }

  Widget _buildTimeSelectionView(){
    return Expanded(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 25,right: 15,left: 15),
              child: Text(
                "وقت المقابلة",
                style: TextStyle(color: Color(0xff707070),fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: EdgeInsets.only(left: 15,right: 15,top: 15),
                  child: _buildAvailableTimesView(),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 15),
              width: double.infinity,
              child: RaisedButton(
                onPressed: (){
                  _sendBookingRequest();
                },
                child: Text("تأكيد الحجز",style: TextStyle(color: Colors.white),),
                color: Color(0xff7FF5C46),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            )
          ]),
    );
  }
  final _scrollController = ScrollController();

  Widget _buildAvailableTimesView() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scrollbar(
        controller: _scrollController,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.only(left: 1, right: 12 ),
            child: Tags(
              alignment: WrapAlignment.end,
              itemCount: _availableTimesData.slots?.length ?? 0,
              runSpacing: 5,
              spacing: 5,
              itemBuilder: (int index) {
                final item = _availableTimesData.slots?[index];
                _availableTimesData.slots?[index].id = index.toString();
                bool timeCanBeSelected = (!(item?.disabled??false)) && ((item?.count??0) < (_availableTimesData.capacity??0));

                return InkWell(
                  onTap: (){
                    if(timeCanBeSelected) {
                      _setTimeSelected(item);
                    }else{
                      Fluttertoast.showToast(msg:
                          "هذا الموعد محجوز",
                         toastLength: Toast.LENGTH_LONG);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "${_availableTimesData.slots?[index].start} - ${_availableTimesData.slots?[index].end}",
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                          color: !timeCanBeSelected ? Color(0xffC1C1C1) : ((item?.selected??false) ? Colors.white : Colors.grey)
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: !timeCanBeSelected ? Color(0xffEEEEEE) : ((item?.selected??false) ? Color(0xff76d275) : Colors.white),
                      border: Border.all(
                          color: !timeCanBeSelected ? Color(0xffEEEEEE) : ((item?.selected??false) ? Color(0xff76d275) : Colors.grey)
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _setTimeSelected(TimeSlot? item) {
    for (var index = 0; index < (_availableTimesData.slots?.length??0); index++) {
      if (item?.id == _availableTimesData.slots?[index].id) {
        if (_availableTimesData.slots?[index].selected??false) {
          setState(() {
            _availableTimesData.slots?[index].selected = false;
            _selectedTimeIndex = null;
          });
        } else {
          setState(() {
            if(_selectedTimeIndex != null) _availableTimesData.slots?[_selectedTimeIndex??0].selected = false;
            _availableTimesData.slots?[index].selected = true;
            _selectedTimeIndex = index;
          });
        }
        return;
      }
    }
  }

  int? _lastConfirmedPickedDateIndex;
  int _lastPickedDateIndex = 0;

  Future<void> _showDatePickerDialog(BuildContext context) async {
    if(_availableDates.isEmpty){
      Fluttertoast.showToast(msg:
          "لا يوجد أوقات متاحة للحجز في الوقت الحالي",
          toastLength: Toast.LENGTH_LONG);

      return;
    }else if(_selectedContractCategory == null){
      Fluttertoast.showToast(msg:
          "يجب اختيار نوع العقد اولا",
          toastLength: Toast.LENGTH_LONG);

      return;
    }
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.4,
          padding: EdgeInsets.only(top: 20),
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Expanded(
                  child: Center(
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      scrollController: FixedExtentScrollController(initialItem: _lastConfirmedPickedDateIndex ?? 0),
                      onSelectedItemChanged: (index) {
                        _lastPickedDateIndex = index;
                      },
                      itemExtent: 40,
                      children: _availableDates.map((date) {
                        return  Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            date.name??"",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: Theme.of(context).textTheme.bodyText1?.fontFamily,
                            ),
                          ),
                        );
                      } ).toList(),
                    ),
                  )
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: RaisedButton(
                  onPressed: () {
                    _confirmPickedDate();
                  },
                  child: Text(
                    "اختيار",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Color(0xff76D275),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _getAvailableTimes(){
    String bookingDate = _availableDates[_lastConfirmedPickedDateIndex??0].value??"";
    _realEstateNetwork.getRealEstateAvailableHours(this,_selectedContractCategory?.id??"",bookingDate);
  }

  _sendBookingRequest(){
    if(_selectedTimeIndex != null) {
      _lastSentRequestIsTheBookingRequest = true;

      String bookingDate = _availableDates[_lastConfirmedPickedDateIndex??0].value??"";
      String selectedTime = _availableTimesData.slots?[_selectedTimeIndex??0].total??"";
      _realEstateNetwork.requestRealEstateBooking(
          this, _selectedContractCategory?.id??"", bookingDate, _selectedContractSubCategoryId.toString(),selectedTime);
    }else{
      Fluttertoast.showToast(msg:
          "يجب اختيار الوقت المحدد",

          toastLength: Toast.LENGTH_LONG);
    }
  }

  _confirmPickedDate(){
    _lastConfirmedPickedDateIndex = _lastPickedDateIndex;
    _selectedDateController.text = _availableDates[_lastConfirmedPickedDateIndex??0].name??"";
    Navigator.pop(context);
    _getAvailableTimes();
  }

  @override
  void setRealEstateContracts(RealEstateContractsData? contractsData) {
    _realEstateNetwork.getRealEstateAvailableDates(this);
    _contractsData = contractsData?? RealEstateContractsData();

    if(_contractsData.categories != null && (_contractsData.categories?.isNotEmpty??false))_onContractCategorySelection(_contractsData.categories?[0]);
  }

  _refreshSubCategories(){
    if(_contractsData.categories != null && (_contractsData.categories?.isNotEmpty??false)) {
      List<ContractSubCategory> subCategories = _selectedContractCategory?.subCategories??[];

      _contractSubCategoriesDropdownItems.clear();
      _contractSubCategoriesDropdownItems.add(_getSubCategoryHintItem());
      _selectedContractSubCategoryId = 0;

      for (int index = 0; index < subCategories.length ; index++) {
        _contractSubCategoriesDropdownItems.add(
          DropdownMenuItem(
              value: int.parse(subCategories[index].id??"0"),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: MediaQuery.of(context).size.width-80,
                  child: Text(
                    subCategories[index].name??"",
                    maxLines: 2,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xff707070),
                        fontWeight: FontWeight.normal,
                        fontSize: 14
                    ),
                  ),
                ),
              )
          ),
        );
      }
    }
  }

  @override
  void setRealEstateAvailableHours(RealEstateAvailableTimesData? timesData) {
    setState(() {
      _availableTimesData = timesData??RealEstateAvailableTimesData();
      _selectedTimeIndex = null;
    });
  }

  @override
  void setRealEstateAvailableDates(RealEstateAvailableDatesData? datesData) {
    _availableDates = datesData?.dates??[];
  }

  @override
  void showNetworkError() {
    Fluttertoast.showToast(msg:
        "خطأ فى الإتصال, برجاء التأكد من اللإتصال بالشبكة وإعادة المحاولة",
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showImageNetworkError() {
    setState(() {
      _isNoNetwork = true;
    });
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
  void showGeneralError() {
    Fluttertoast.showToast(msg:"حدث خطأ ما برجاء اعادة المحاولة", toastLength: Toast.LENGTH_LONG);
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void realEstateBookedSuccessfully(){
    setState(() {
      _showSuccessMessage = true;
    });
  }

  @override
  void setRealEstateUpcommingBooking(RealEstateUpcommingBookingData? bookingData,String? message) {
    _loadingWithBackground = false;
    if(bookingData?.booking?.id == null){
      _realEstateNetwork.getRealEstateContracts(this);
    }else{
      setState(() {
        _upcommingBookingTitle = message??"";
        _isLoading = false;
        _upcommingBooking = bookingData?.booking??UpcommingBooking();
      });
    }
  }

  Widget _buildImageNetworkError() {
    return NoNetwork(this);
  }

  _getSubCategoryHintItem(){
    return DropdownMenuItem(
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          child: Text(
            "--إختار التصنيف--",
            textAlign: TextAlign.right,
            style: TextStyle(color: Color(0xffC6C6C6),fontSize: 14,),
          ),
        ),
      ),
      value: 0,
    );
  }

}