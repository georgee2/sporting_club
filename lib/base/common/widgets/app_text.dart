import 'package:flutter/material.dart';
import 'package:sporting_club/utilities/app_colors.dart';
class CustomAppText extends StatelessWidget {

  final double fontSize;
  final String text;
  final Color textColor;
  final bool underline;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final String? fontFamily;
  final double? lineSpace;
  final double? width;
  final int? maxLines;

  CustomAppText({
    this.textColor=AppColors.black,
     required this.text,
    this.fontSize = 18,
    this.underline = false,
    this.padding = const EdgeInsets.all(0),
    this.textAlign = TextAlign.start,
    this.fontWeight = FontWeight.normal,
    this.lineSpace,
    this.width,
    this.fontFamily,
    this.maxLines=10
  });

  @override
  Widget build(BuildContext context) {
   var textScale= MediaQuery.of(context).textScaleFactor;
   var devicePixelRatio= MediaQuery.of(context).devicePixelRatio;
    return Container(
      width: width,
      padding: padding,
      child: Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize*1,//*textScale
            fontWeight: fontWeight,
            color: textColor ,
            decoration: underline ? TextDecoration.underline : TextDecoration.none,
            height: lineSpace,
          )
              .apply(
              fontSizeDelta:  -2.0,
              fontSizeFactor: 1, )
      ),
    );
  }
}