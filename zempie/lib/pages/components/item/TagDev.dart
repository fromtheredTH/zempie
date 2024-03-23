
import 'package:app/Constants/ColorConstants.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';

import '../../../Constants/Constants.dart';
import '../../../models/MatchEnumModel.dart';

class TagDevWidget extends StatelessWidget {
  TagDevWidget({super.key,required this.positionIndex});
  String positionIndex;

  @override
  Widget build(BuildContext context) {
    int index = -1;
    MatchEnumModel? model;
    try{
      index = int.parse(positionIndex);
      if(index < 5){
        model = Constants.jobPositions[index];
      }
    }catch (e) {
      index = -1;
    }
    // TODO: implement build
    return model != null ? Container(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: model.color
      ),
      child: AppText(
        text: model.enumValue,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w700,
        fontSize: 8,
      ),
    ) : Container();
  }
}