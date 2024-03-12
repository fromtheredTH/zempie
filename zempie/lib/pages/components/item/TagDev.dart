
import 'package:app/Constants/ColorConstants.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';

class TagDevWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorConstants.colorOption4
      ),
      child: AppText(
        text: "DEV",
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w700,
        fontSize: 8,
      ),
    );
  }
}