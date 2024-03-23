
import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/Constants/utils.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/Constants.dart';
import '../../global/DioClient.dart';
import '../screens/communityScreens/community_detal_screen.dart';

class CommunityWidget extends StatefulWidget {
  CommunityWidget({super.key, required this.community, required this.onSubscribe});
  CommunityModel community;
  Function(CommunityModel) onSubscribe;

  @override
  State<CommunityWidget> createState() {
    // TODO: implement createState
    return _CommunityWidget();
  }
}

class _CommunityWidget extends State<CommunityWidget> {

  late CommunityModel community;

  @override
  void initState() {
    community = widget.community;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        Get.to(CommunityDetailScreen(community: community, refreshCommunity: (community){
        setState(() {
          this.community = community;
          widget.onSubscribe(community);
        });
        },));
      },
      child: Container(
        margin: EdgeInsets.only(top: Get.height*0.025,right: Get.width*0.02,left: Get.width*0.02),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorConstants.gray3, width: 0.5)
        ),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
                padding: EdgeInsets.only(top: 1,left: 1,right: 1),
              height: Get.width*0.4*1.5/3*1.2,
              child: Stack(
                children: [
                  ImageUtils.setCommunityListNetworkImage(community.bannerImg, true),
                  Padding(
                    padding:  EdgeInsets.only(top: Get.width*0.4*1.5/3*1.2 - Get.width*0.4*1.5/4),
                    child: Center(child: ImageUtils.CommunityProfileImage( community.profileImg, Get.width*0.4*1.5/4, Get.width*0.4*1.5/4)),
                  ),
                ],
              ),
            ),
            SizedBox(height: Get.height*0.02,),
            AppText(
              text: community.name,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: Get.height*0.005,),
            SizedBox(
              width: Get.width*0.35,
              child: AppText(
                text: community.description,
                fontSize: 11,
                color: ColorConstants.white70Percent,
                maxLine: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                    child: Column(
                      children: [
                        AppText(
                          text: "${community.memberCnt}",
                          fontSize: 13,
                          color: ColorConstants.white,
                          fontWeight: FontWeight.w700,
                        ),
                        AppText(
                          text: 'member'.tr(),
                          fontSize: 10,
                          color: ColorConstants.white70Percent,
                        ),
                      ],
                    ),
                ),
                Expanded(
                  child: Column(
                  children: [
                    AppText(
                      text: "${community.postsCnt}",
                      fontSize: 13,
                      color: ColorConstants.white,
                      fontWeight: FontWeight.w700,
                    ),
                    AppText(
                      text: 'post'.tr(),
                      fontSize: 10,
                      color: ColorConstants.white70Percent,
                    ),
                  ],
                ),
                ),
                Expanded(
                  child: Column(
                  children: [
                    AppText(
                      text: "${community.visitCnt}",
                      fontSize: 13,
                      color: ColorConstants.white,
                      fontWeight: FontWeight.w700,
                    ),
                    AppText(
                      text: 'visit'.tr(),
                      fontSize: 10,
                      color: ColorConstants.white70Percent,
                    ),
                  ],
                ),
                )
              ],
            ),
            Spacer(),
            (community.isSubscribed==false)?
            GestureDetector(
              onTap: () async {
                await DioClient.getCommunitySubscribe(community.id);
                setState(() {
                  community.isSubscribed = true;
                });
                Utils.showToast("subscribe_complete".tr());
                widget.onSubscribe(community);
                Constants.addCommunityFollow(community);
              },
              child: Container(
                width: Get.width,
                height: Get.height*0.05,
                decoration: BoxDecoration(
                    color: ColorConstants.colorMain,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Center(
                  child: AppText(
                    text: 'subscribe'.tr(),
                    fontSize: 13,
                  ),
                ),
              ),
            ):
            Container(
              width: Get.width,
              height: Get.height*0.05,
              decoration: BoxDecoration(
                // color: ColorConstants.yellow,
                  border: Border.all(color: ColorConstants.colorMain,),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Center(
                child: AppText(
                  text: 'enterance'.tr(),
                  fontSize: 13,
                  color: ColorConstants.colorMain,
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}