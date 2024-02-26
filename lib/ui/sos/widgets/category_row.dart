import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/model/emergency/emergency_category.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EmergencyCategoryRow extends StatelessWidget {
  final void Function() onTapAction;
  EmergencyCategory  emergencyCategory;
bool isSelected;
  EmergencyCategoryRow({required this .emergencyCategory, required this.onTapAction,required this.isSelected
  }) ;

  @override
  Widget build(BuildContext context) {

    return  InkWell(
      onTap: () async {
        onTapAction();
        // showCallkitIncoming(Uuid().v4() , "Handling a background message");
      },
      child: new Container(
        margin: EdgeInsets.only(bottom: 5, top: 10, left: 10, right: 10),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isSelected?0.5:0),
              blurRadius: 8.0,
              // has the effect of softening the shadow
              spreadRadius: 8.0,
              // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                3.0, // vertical, move down 10
              ),
            ),
          ],
          color: isSelected?Color(0xffE21B1B):Color(0xff03240A),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Image.asset(emergencyCategory.categoryIcon??""),
             SizedBox(height: 10,),
              CachedNetworkImage(
                imageUrl: emergencyCategory.categoryIcon??"",
                placeholder: (context, url) =>
                    Image.asset("assets/placeholder_2.png"),
                errorWidget:  (context, url, _) {
                  return Image.asset("assets/placeholder_2.png");
                },
                height: 80,
                width: 80,
                fit: BoxFit.contain,
              ),

              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: MediaQuery.of(context).size.width*.07),
                  child: Text(
                    emergencyCategory.name ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
