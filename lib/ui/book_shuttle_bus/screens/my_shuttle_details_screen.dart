import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sporting_club/base/screen_handler.dart';

import 'package:sporting_club/network/repositories/booking_shuttle_bus.dart';
import 'package:sporting_club/ui/book_shuttle_bus/screens/my_shuttle_bookings.dart';
import 'package:sporting_club/ui/book_shuttle_bus/view_model/shuttle_details_viewmodel.dart';
import 'package:sporting_club/ui/book_shuttle_bus/widgets/shuttle_no_network.dart';
import 'package:sporting_club/utilities/app_colors.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_details.dart';
import 'package:open_file/open_file.dart';
import 'package:sporting_club/main.dart';
import 'package:path_provider/path_provider.dart';

class ShuttleDetailsScreen extends StatefulWidget {
  String suttleId;

  ShuttleDetailsScreen({required this.suttleId});

  @override
  State<StatefulWidget> createState() {
    return SelectShuttleBusPackageScreenState();
  }
}

class SelectShuttleBusPackageScreenState extends State<ShuttleDetailsScreen> {
  SelectShuttleBusPackageScreenState();

  // final pdf = pw.Document();
  BuildContext? mProviderContext = global.navigatorKey.currentContext;
  ShuttleDetails? shuttleDetails;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      try {
        Provider.of<ShuttleDetailsViewModel>(mProviderContext!, listen: false)
            .getShuttleDetails(shuttleId: widget.suttleId);
      } catch (e) {
        print(e.toString());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShuttleDetailsViewModel>(
        create: (context) =>
            ShuttleDetailsViewModel(ShuttleBusNetwork(), context),
        child: Selector<ShuttleDetailsViewModel, ShuttleDetails>(
            selector: (_, viewModel) => viewModel.shuttleDetails,
            builder: (providerContext, viewModelShuttleData, child) {
              mProviderContext = providerContext;
              shuttleDetails = viewModelShuttleData;
              return new Directionality(
                textDirection: TextDirection.rtl,
                child: WillPopScope(
                  onWillPop: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                MyShuttleBookingsScreen()));
                    return true;
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      title: Text(
                        "تفاصيل حجز شاتل باص",
                      ),
                      leading: IconButton(
                          icon: new Image.asset('assets/back_white.png'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        MyShuttleBookingsScreen()));
                          }),
                    ),
                    backgroundColor: Color(0xfff9f9f9),
                    body: ScreenHandler<ShuttleDetailsViewModel>(
                      networkWidget: ShuttleNoNetwork(
                        onTapNoNetwork: () {
                          Provider.of<ShuttleDetailsViewModel>(
                                  mProviderContext!,
                                  listen: false)
                              .getShuttleDetails(shuttleId: widget.suttleId);
                        },
                      ),
                      child: shuttleDetails?.shuttleId == null
                          ? SizedBox()
                          : _buildContent(),
                    ),
                  ),
                ),
              );
            }));
  }

  Widget _buildContent() {
    return ListView(
      children: <Widget>[
        _buildDetailsCard(),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
          child: Align(
              child: TextButton.icon(
                onPressed: () {
                  generateInvoice();
                },
                icon: Image.asset(
                  "assets/print.png",
                ),
                // color: AppColors.mediumGreen,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    AppColors.mediumGreen,
                  ),
                ),
                label: Text(
                  "طباعه الايصال",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
              alignment: Alignment.centerLeft),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
      padding: EdgeInsets.only(top: 5, bottom: 5),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.2),
            blurRadius: 8.0,
            // has the effect of softening the shadow
            spreadRadius: 5.0,
            // has the effect of extending the shadow
            offset: Offset(
              0.0, // horizontal, move right 10
              0.0, // vertical, move down 10
            ),
          ),
        ],
        color: Colors.white,
      ),
      // height: 50,
      child: Container(
          // color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildDetailRow(
                  title: "رقم الحجز",
                  value: shuttleDetails?.shuttleId?.toString() ?? "",
                ),
                Divider(),
                buildDetailRow(
                  title: "عدد الافراد",
                  value: shuttleDetails?.bookingMembersCount?.toString() ?? "",
                ),
                ...buildMembersRow(),
                Divider(),
                buildDetailRow(
                  title: "نوع الاشتراك",
                  value: shuttleDetails?.date ?? "",
                ),
                Divider(),
                buildDetailRow(
                  title: "المبلغ الاجمالى",
                  value: "${shuttleDetails?.totalAmoutFees} جنيه ",
                )
              ])),
    );
  }

  List<Widget> buildMembersRow() {
    List<Widget> MemberWidgetlist = [];
    shuttleDetails?.members?.forEach((element) {
      MemberWidgetlist.add(buildDetailRow(
        title: element.name,
        value: element.memberId,
      ));
    });
    return MemberWidgetlist;
  }

  buildDetailRow({title, value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  pw.Font? ttf;
  pw.Document pdf = pw.Document();
  Uint8List? logobytes;
  PdfImage? _logoImage;

  Future<void> generateInvoice() async {
    final ByteData bytes = await rootBundle.load('fonts/Bahij-Plain.ttf');
    ttf = pw.Font.ttf(bytes);
    ByteData _bytes = await rootBundle.load('assets/sporting_logo.png');
    logobytes = _bytes.buffer.asUint8List();
    try {
      _logoImage = PdfImage.file(
        pdf.document,
        bytes: logobytes ?? Uint8List(0),
      );
    } catch (e) {
      print("catch--  $e");
      logobytes = null;
      _logoImage = PdfImage.file(
        pdf.document,
        bytes: logobytes ?? Uint8List(0),
      );
    }
    ;
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => _buildPdfDetailsCard(),
      ),
    );

    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    final file = File('${appDocDirectory.path}/${widget.suttleId}.pdf');
    await file.writeAsBytes(await pdf.save()).then((pdfFile) {
      print("pdfFile");
      OpenFile.open(pdfFile.path);
      print("opened");
    });
  }

  _buildPdfDetailsCard() {
    List<pw.Widget> widgets = [];
    widgets.add(pw.Container(
        margin: pw.EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
        padding: pw.EdgeInsets.only(top: 5, bottom: 5),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(10),
          boxShadow: [
            pw.BoxShadow(
              // color:PdfColors Colors.grey.withOpacity(.2),
              blurRadius: 8.0,
              // has the effect of softening the shadow
              spreadRadius: 5.0,
            ),
          ],
        ),
        child: pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Container(
              // color: Colors.white,
              margin: pw.EdgeInsets.symmetric(horizontal: 15),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text("Shuttle bus",
                        style: pw.TextStyle(
                          fontSize: 18,
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.right),
                    pw.Align(
                      child: pw.Image(
                        pw.MemoryImage(logobytes ?? Uint8List(0)),
                        fit: pw.BoxFit.fill,
                        height: 100,
                        width: 100,
                      ),
                      alignment: pw.Alignment.center,
                    ),
                    buildPdfDetailRow(
                      title: "رقم الحجز",
                      value: shuttleDetails?.shuttleId?.toString() ?? "",
                    ),
                    pw.Divider(),
                    buildPdfDetailRow(
                      title: "عدد الافراد",
                      value:
                          shuttleDetails?.bookingMembersCount?.toString() ?? "",
                    ),
                    ...buildPDfMembersRow(),
                    pw.Divider(),
                    buildPdfDetailRow(
                      title: "نوع الاشتراك",
                      value: shuttleDetails?.date ?? "",
                    ),
                    pw.Divider(),
                    buildPdfDetailRow(
                      title: "المبلغ الاجمالى",
                      value: (shuttleDetails?.price ?? "") + " جنيه",
                    )
                  ])),
        )));

    // widgets.add(pw.Container(
    //     margin: pw.EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
    //     padding: pw.EdgeInsets.only(top: 5, bottom: 5),
    //     decoration: pw.BoxDecoration(
    //       borderRadius: pw.BorderRadius.circular(10),
    //       boxShadow: [
    //         pw.BoxShadow(
    //           // color:PdfColors Colors.grey.withOpacity(.2),
    //           blurRadius: 8.0,
    //           // has the effect of softening the shadow
    //           spreadRadius: 5.0,
    //         ),
    //       ],
    //     ),
    //     child: pw.Directionality(
    //       textDirection: pw.TextDirection.rtl,
    //       child: pw.Container(
    //         // color: Colors.white,
    //           margin: pw.EdgeInsets.symmetric(horizontal: 15),
    //           child: pw.Column(
    //               crossAxisAlignment: pw.CrossAxisAlignment.center,
    //               mainAxisAlignment: pw.MainAxisAlignment.start,
    //               children: [
    //
    //                 buildPdfDetailRow(
    //                   title: "المبلغ الاجمالى",
    //                   value: (shuttleDetails?.price ?? "") + " جنيه",
    //                 )
    //               ])),
    //     )));
    return widgets;
  }

  List<pw.Widget> buildPDfMembersRow() {
    List<pw.Widget> MemberWidgetlist = [];
    shuttleDetails?.members?.forEach((element) {
      MemberWidgetlist.add(buildPdfDetailRow(
        title: element.name,
        value: element.memberId,
      ));
    });
    return MemberWidgetlist;
  }

  buildPdfDetailRow({
    title,
    value,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          margin: pw.EdgeInsets.only(top: 10),
          child: pw.Text(title,
              style: pw.TextStyle(
                fontSize: 12,
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xff43a047),
              ),
              textDirection: pw.TextDirection.rtl,
              textAlign: pw.TextAlign.right),
        ),
        pw.Container(
          margin: pw.EdgeInsets.only(top: 10),
          child: pw.Text(value,
              style: pw.TextStyle(
                fontSize: 14,
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              textDirection: pw.TextDirection.rtl,
              textAlign: pw.TextAlign.right),
        ),
      ],
    );
  }
}
