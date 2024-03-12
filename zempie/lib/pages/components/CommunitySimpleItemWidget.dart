

import 'package:app/models/CommunityModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../base/base_state.dart';
import '../screens/communityScreens/community_detal_screen.dart';
import 'item/TagCreator.dart';
import 'item/TagDev.dart';

class CommunitySimpleItemWidget extends StatefulWidget {
  CommunitySimpleItemWidget({Key? key, required this.community}) : super(key: key);
  CommunityModel community;

  @override
  State<CommunitySimpleItemWidget> createState() => _CommunitySimpleItemWidget();
}

class _CommunitySimpleItemWidget extends BaseState<CommunitySimpleItemWidget> {
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
          });
        },));
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                    shape: BoxShape.circle
                ),
                child: ImageUtils.setRectNetworkImage(
                    community.profileImg,
                    45,
                    45
                ),
              ),
              SizedBox(width: 10),

              Flexible(
                  child:AppText(text: community.name,
                    fontSize: 13,
                    color: ColorConstants.white,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: FontConstants.AppFont,
                    fontWeight: FontWeight.w400,
                    maxLine: 2,
                  )
              ),

              SizedBox(width: 15,)
            ],
          ),

          SizedBox(height: 25,)
        ],
      ),
    );
  }
}
