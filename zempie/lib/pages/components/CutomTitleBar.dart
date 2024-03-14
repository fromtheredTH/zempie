import 'package:app/Constants/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;

import '../../Constants/ImageConstants.dart';
import '../screens/chat.dart';
import 'app_text.dart';
import 'fucus_detector.dart';

class CustomTitleBar extends StatelessWidget {

  String? title;
  String? imageUrl;
  Color? color;
  double? padding;
  final VoidCallback? callBack;
  String? notShowBackIcon;
  Function() onTapLogo;
  RxInt unReadCount = Constants.user.meta.unreadNotiCount.obs;

  CustomTitleBar({Key? key, this.title,  this.imageUrl, this.color,this.padding,this.callBack,this.notShowBackIcon, required this.onTapLogo}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
        onFocusLost: () {

    },
    onFocusGained: () {
      unReadCount.value = Constants.user.meta.unreadNotiCount;

    },
    child: Column(
      children: [
        SizedBox(
          height: Get.height * 0.06,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: (){
                onTapLogo();
              },
              child: Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: SvgPicture.asset(ImageConstants.appLogo, height: 30,)),
            ),

            Row(

              children: [
                GestureDetector(
                    onTap: (){
                      Get.to(ChatPage());
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            top: 0,
                            child: Center(
                              child: Image.asset(ImageConstants.chatIcon, width: 35, height: 35,),
                            ),
                          ),

                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: unReadCount.value != 0 ? Colors.red : Colors.transparent,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Obx(() => AppText(text: unReadCount.value != 0 ? "${unReadCount.value}" : "",
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 0.01,),
                                )),
                              padding: EdgeInsets.all(Get.height*0.007),
                            ),
                          ),
                        ],
                      ),
                    )
                ),

                SizedBox(width: Get.width*0.02),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: GestureDetector(
                    onTap: callBack,
                    child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Image.asset(ImageConstants.profileIcon, width: 35, height: 35,)),
                  ),
                )
              ],
            ),



          ],
        ),
      ],
    )
    );
  }
}
