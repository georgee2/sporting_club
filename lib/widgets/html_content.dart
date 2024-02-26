import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:sporting_club/utilities/app_colors.dart';

import 'iframe_screen.dart';

class HtmlContent extends StatelessWidget {
  String _content;

  HtmlContent(this._content);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print("_content $_content");
    if (_content != null) {
      if (_content.contains('<table')) {
        if (_content.contains('<thead')) {
          String headTag = _content.substring(
              _content.indexOf('<thead'), _content.indexOf('</thead>'));
          if (headTag.contains('<tr')) {
            String trTag = headTag.substring(
                headTag.indexOf('<tr'), headTag.indexOf('</tr>'));
            if (trTag.contains('<th')) {
              if ('<th'.allMatches(trTag).length > 2) {
                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: ('<th'.allMatches(trTag).length) *
                          (MediaQuery.of(context).size.width * 0.4),
                      child: HtmlWidget(
                        _content,
                        customStylesBuilder: (element) {
                          return {'text-align': 'center'};
                        },
                        webView: true,
                        webViewJs: true,
                      ),
                    ));
              }
            } else if (trTag.contains('<td')) {
              if ('<td'.allMatches(trTag).length > 2) {
                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: ('<td'.allMatches(trTag).length) *
                          (MediaQuery.of(context).size.width * 0.4),
                      child: HtmlWidget(
                        _content,
                        customStylesBuilder: (element) {
                          return {'text-align': 'center'};
                        },
                        webView: true,
                        webViewJs: true,
                      ),
                    ));
              }
            }
          }
        } else if (_content.contains('<tbody')) {
          String bodyTag = _content.substring(
              _content.indexOf('<tbody'), _content.indexOf('</tbody>'));
          if (bodyTag.contains('<tr')) {
            String trTag = bodyTag.substring(
                bodyTag.indexOf('<tr'), bodyTag.indexOf('</tr>'));
            if (trTag.contains('<th')) {
              if ('<th'.allMatches(trTag).length > 2) {
                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: ('<th'.allMatches(trTag).length) *
                          (MediaQuery.of(context).size.width * 0.4),
                      child: HtmlWidget(
                        _content,
                        customStylesBuilder: (element) {
                          return {'text-align': 'center'};
                        },
                        webView: true,
                        webViewJs: true,
                      ),
                    ));
              }
            } else if (trTag.contains('<td')) {
              if ('<td'.allMatches(trTag).length > 2) {
                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: ('<td'.allMatches(trTag).length) *
                          (MediaQuery.of(context).size.width * 0.4),
                      child: HtmlWidget(
                        _content,
                        customStylesBuilder: (element) {
                          return {'text-align': 'center'};
                        },
                        webView: true,
                        webViewJs: true,
                      ),
                    ));
              }
            }
          }
        }
      }
      return HtmlWidget(
        _content != null ? _content : "",
        webView: true,
        webViewJs: true,
        customWidgetBuilder: (dom) {
          if (dom.localName == "iframe") {
            String butonName=dom.attributes["title"]?? 'عرض المحتوى';
            Color butonColor=HexColor.fromHex(dom.attributes["color"]??"#ffff5c46") ;// Color(0xffff5c46)
            Color textColor=HexColor.fromHex(dom.attributes["textcolor"]??"#FFFFFFFF") ;// Color(0xffff5c46)
            double buttonRaduis=double.tryParse(dom.attributes["buttonraduis"]??"10")??10;
            return GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(left: 0, right: 10),
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        butonName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color:  textColor),
                        maxLines: 1,
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(buttonRaduis),
                      color: butonColor,
                    ),
                  ),
                ),
                onTap: () => _navigateToNextAction(context, dom));
          }
          return null;
        },
      );
    } else {
      return Container();
    }
  }

  _navigateToNextAction(context , iframeContent) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => IframeScreen(
                  this._content,
                )));
  }
}
