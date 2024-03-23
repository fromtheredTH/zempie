

import 'package:app/Constants/Constants.dart';
import 'package:app/models/ChannelModel.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';

class BottomPostCommunityWidget extends StatefulWidget{
  BottomPostCommunityWidget({Key? key, required this.selectedChannels, required this.onSelectChannels}) : super(key: key);
  List<ChannelModel> selectedChannels;
  Function(List<ChannelModel>) onSelectChannels;

  @override
  State<BottomPostCommunityWidget> createState() {
    // TODO: implement createState
    return _BottomPostCommunityWidget();
  }
}

class _BottomPostCommunityWidget extends BaseState<BottomPostCommunityWidget> {

  List<String> selectedCommunityId = [];
  List<ChannelModel> selectedChannels = [];

  @override
  void initState() {
    selectedChannels = widget.selectedChannels;
    for(int i=0;i<selectedChannels.length;i++){
      if(!selectedChannels.map((e) => e.communityId).toList().contains(selectedCommunityId)){
        selectedCommunityId.add(selectedChannels[i].communityId);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: Get.width,
      constraints: BoxConstraints(
        minHeight: Get.height*0.2,
        maxHeight: Get.height*0.52
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
              topRight: Radius.circular(30))
      ),
      child: Column(

        children: [
          SizedBox(height: 15,),
          Container(
            height: Get.height*0.01,
            width: Get.width*0.18,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ColorConstants.white
            ),
          ),
          SizedBox(height: Get.height*0.02,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                text: "${Constants.followCommunities.length}",
                fontSize: 14,
                color: ColorConstants.colorMain,
                fontWeight: FontWeight.w700,
              ),
              AppText(
                text: "bottom_post_community_widget_guide".tr(),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),

          SizedBox(height: Get.height*0.01,),
          AppText(
            text: "bottom_post_community_select".tr(),
            fontSize: 12,
            color: ColorConstants.halfWhite,
          ),
          SizedBox(height: Get.height*0.018,),
          Container(
            height: Get.height*0.3,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Constants.followCommunities.length,
              itemBuilder: (context, index) {
                return buildCommunityCheckBoxItem(selectedCommunityId.contains(Constants.followCommunities[index].id), Constants.followCommunities[index]);
              },
            ),
          ),
          SizedBox(height: Get.height*0.01,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 15,),
              Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Get.back();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: ColorConstants.gray3,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Center(
                        child: AppText(
                          text: "cancel".tr(),
                          fontSize: 0.016,
                          color: ColorConstants.white,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
              ),
              SizedBox(width: 15,),
              Expanded(
                  child: GestureDetector(
                    onTap: (){
                      widget.onSelectChannels(selectedChannels);
                      Get.back();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: ColorConstants.colorMain,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Center(
                        child: AppText(
                          text: "confirm".tr(),
                          fontSize: 0.016,
                          color: ColorConstants.white,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
              ),
              SizedBox(width: 15,),
            ],
          ),

          SizedBox(height: 15,)

        ],
      ),
    );
  }

  Widget buildCommunityCheckBoxItem(bool isChecked, CommunityModel community) {
    return Padding(
      padding: EdgeInsets.only(
        left: Get.width * 0.04,
        bottom: Get.height * 0.01,
        top:  Get.height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if(isChecked){
                      selectedCommunityId.remove(community.id);
                    }else{
                      selectedCommunityId.add(community.id);
                    }
                  });
                },
                child: SvgPicture.asset(
                  isChecked ? ImageConstants.orangeTick : ImageConstants.whiteTick ,
                  height: Get.height * 0.024,
                ),
              ),
              SizedBox(width: Get.width * 0.02),
              AppText(
                text: community.name,
                fontSize: 14,
              ),
            ],
          ),
          if(selectedCommunityId.contains(community.id))
          Padding(
            padding: EdgeInsets.only(left: Get.width * 0.04),
            child: Column(
              children: community.channels
                  .map((subItem) => buildChannelCheckBoxItem(selectedChannels.map((e) => e.id).toList().contains(subItem.id), subItem))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildChannelCheckBoxItem(bool isChecked, ChannelModel channel) {
    return Padding(
      padding: EdgeInsets.only(
        left: Get.width * 0.04,
        bottom: Get.height * 0.01,
        top:  Get.height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if(isChecked){
                      for(int i=0;i<selectedChannels.length;i++){
                        if(selectedChannels[i].id == channel.id){
                          selectedChannels.removeAt(i);
                          break;
                        }
                      }
                    }else{
                      selectedChannels.add(channel);
                    }
                  });
                },
                child: SvgPicture.asset(
                  isChecked ? ImageConstants.orangeTick : ImageConstants.whiteTick ,
                  height: Get.height * 0.024,
                ),
              ),
              SizedBox(width: Get.width * 0.02),
              AppText(
                text: channel.title,
                fontSize: 14,
              ),
            ],
          )
        ],
      ),
    );
  }
}
