import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sporting_club/base/common/widgets/app_text.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_member.dart';
import 'package:sporting_club/data/model/shuttle_bus/shuttle_package.dart';
import 'package:sporting_club/utilities/app_colors.dart';

class MemberRow extends StatelessWidget {
  final void Function(bool) onTapAction;
  ShuttleMember shuttleMember;
  bool isAvailableMember;
  Map<String, dynamic> selectedMemberMap = {};

  MemberRow({required this .shuttleMember, required this.onTapAction,
    this.isAvailableMember=false,
  required this.selectedMemberMap
  }) ;

  @override
  Widget build(BuildContext context) {
    Color memberNameColor;
    Color membershipColor;
    if( selectedMemberMap.containsKey(shuttleMember.memberId??"")){
      memberNameColor=AppColors.mediumGreen;
      membershipColor=AppColors.black;
      }else{
      memberNameColor=Color(0xffb2b2b2);
      membershipColor=Color(0xffb2b2b2);
    }
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: (   selectedMemberMap.containsKey(shuttleMember.memberId??""))||( !isAvailableMember),
                onChanged: (val) {
                onTapAction(val??false);
                },
                activeColor:   selectedMemberMap.containsKey(shuttleMember.memberId??"")
                    ? AppColors.green
                    : Color(0xffb2b2b2),
              ),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: CustomAppText(
                              text: shuttleMember.name??"",
                              textColor:true
                                  ? AppColors.green
                                  : Color(0xffb2b2b2),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selectedMemberMap.containsKey(shuttleMember.memberId??"")?   Container(
                            margin: EdgeInsets.only(top: 10),
                            child: CustomAppText(
                              text: "${selectedMemberMap[shuttleMember.memberId??""].toString()} جنيه ",
                              textColor:true
                                  ? AppColors.green
                                  : Color(0xffb2b2b2),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ):SizedBox(),
                        ],
                      ),
                      CustomAppText(
                        text: shuttleMember.memberId??"",
                        textColor: true
                            ? AppColors.black
                            : Color(0xffb2b2b2),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ]),
              ),
            ],
          ),
        ]));
  }
}
