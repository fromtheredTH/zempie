
import 'package:app/Constants/ColorConstants.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';

class TagCreatorWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: ColorConstants.colorOption3
      ),
      child: AppText(
        text: "CREATOR",
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w700,
        fontSize: 8,
      ),
    );
  }
}