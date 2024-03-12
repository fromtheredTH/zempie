import 'package:app/pages/components/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class CustomAppBar extends StatelessWidget {

  String? title;
  String? imageUrl;
  Color? color;
  double? padding;
  final VoidCallback? callBack;
  String? notShowBackIcon;


  CustomAppBar({Key? key, this.title,  this.imageUrl, this.color,this.padding,this.callBack,this.notShowBackIcon}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: Get.height * 0.05,
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            (notShowBackIcon==null)?
            GestureDetector(
                onTap: (){
                  Get.back();
                },
                child: Icon(Icons.arrow_back_ios, color: color!,)):
            SizedBox(width: Get.width*0.08,),
            Align(
              alignment: AlignmentDirectional.center,
              child: AppText(
                textAlign: TextAlign.center,
                text: title!,
                fontSize: 0.022,
                color: color!,
                fontWeight: FontWeight.w700,
              ),
            ),
            (imageUrl !=null)? GestureDetector(
              onTap: callBack,
              child: Container(
                alignment: Alignment.bottomRight,
                child: AppText(text: title!,
                    fontSize: Get.height*0.08)
              ),
            ):SizedBox(width: Get.width*0.07,),
          ],
        ),
      ],
    );
  }
}
