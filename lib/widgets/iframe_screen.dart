import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

class IframeScreen extends StatefulWidget {
  String content;

  IframeScreen(
    this.content,
  );

  @override
  State<StatefulWidget> createState() {
    return IframeScreenState();
  }
}

class IframeScreenState extends State<IframeScreen> {
  String _content = "";

  @override
  void initState() {
    super.initState();
    _content = widget.content;
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

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
          body: Platform.isAndroid ?buildContent(context):buildIosContent( context)),
    );
  }

  Widget buildContent(BuildContext context) {
    print("_content $_content");
    return Container(
      height: MediaQuery.of(context).size.height - 60,
      child: HtmlWidget(
        _content != null ? _content : "",
        webView: true,
        webViewJs: true,
        customWidgetBuilder: (dom) {
          if (dom.localName == "iframe") {
            print("attributes ${dom.attributes["src"]}");
            return WebView(
              initialUrl: dom.attributes["src"]??"",
              javascriptMode: JavascriptMode.unrestricted,
            )
            //   HtmlWidget(
            //   dom.outerHtml,
            //   webView: true,
            //   webViewJs: true,
            // )
            ;
          }
          return SizedBox();
        },
      ),
    );
  }
  Widget buildIosContent(BuildContext context) {
    print("_content $_content");
    return SingleChildScrollView(
      child: HtmlWidget(
        _content != null ? _content : "",
        webView: true,
        webViewJs: true,
        customWidgetBuilder: (dom) {
          if (dom.localName == "iframe") {
            return HtmlWidget(
              dom.outerHtml,
              webView: true,
              webViewJs: true,
            )
            ;
          }
          return SizedBox();
        },
      ),
    );
  }
}
