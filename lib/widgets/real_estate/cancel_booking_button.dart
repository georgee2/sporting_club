import 'package:flutter/material.dart';

class RealEstateCancelBookingButton extends StatelessWidget {

  final void Function() onTap;

  RealEstateCancelBookingButton({
  required  this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          width: double.infinity,
          height: 50,
          child: Center(
            child: Text(
              'الغاء الحجز',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
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
            color: Color(0xffff5c46),
          ),
        ),
        onTap: () => onTap()
    );
  }
}