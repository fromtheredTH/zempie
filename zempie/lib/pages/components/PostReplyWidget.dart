

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/PostModel.dart';
import 'package:app/models/PostReplyModel.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/components/item/TagDev.dart';
import 'package:app/pages/screens/profile/profile_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:html/dom.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:rich_text_view/rich_text_view.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/utils.dart';
import '../../models/res/btn_bottom_sheet_model.dart';
import '../base/base_state.dart';
import '../screens/bottomnavigationscreen/bottomNavBarScreen.dart';
import 'BtnBottomSheetWidget.dart';

class PostReplyWidget extends StatefulWidget {
  PostReplyWidget({super.key, required this.reply, this.isChild = false, required this.onTapChild, required this.onDelete,required this.onEditReply});
  PostReplyModel reply;
  bool isChild;
  Function(PostReplyModel) onTapChild;
  Function() onDelete;
  Function() onEditReply;

  @override
  State<PostReplyWidget> createState() => _PostReplyWidget();
}

class _PostReplyWidget extends BaseState<PostReplyWidget> {

  late PostReplyModel reply;

  @override
  void initState() {
    reply = widget.reply;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    reply = widget.reply;
    return Padding(
      padding: EdgeInsets.only(top: 15, left: widget.isChild ? 30 : 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      Get.to(ProfileScreen(user: reply.user));
                    },
                    child: ClipOval(
                      child: Container(
                        width: Get.height*0.045,
                        height: Get.height*0.045,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle
                        ),
                        child: ImageUtils.ProfileImage(
                            reply.user.picture,
                            Get.height*0.045,
                            Get.height*0.045
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Get.width*0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(text: reply.user.nickname,
                          fontSize: 13,
                          color: ColorConstants.white,
                          textAlign: TextAlign.start,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w700),

                      SizedBox(height: Get.height*0.005),
                      Row(
                        children: [
                          if(reply.user.profile.jobGroup == "1")
                            TagCreatorWidget(),
                          SizedBox(width: Get.width*0.01),
                          if(reply.user.profile.jobPosition == "0")
                            TagDevWidget()
                        ],
                      ),
                      SizedBox(height: Get.height*0.005),
                      AppText(
                          text: Utils.getTimePost(reply.createdAt),
                          fontSize: 12,
                          color: ColorConstants.halfWhite,
                          fontWeight: FontWeight.w400),
                    ],


                  ),
                ],
              ),
              GestureDetector(
                onTap: (){
                  List<BtnBottomSheetModel> items = [];
                  if(reply.user.id == Constants.user.id) {
                    items.add(BtnBottomSheetModel(
                        ImageConstants.editRoomIcon, "댓글 수정", 0));
                    items.add(BtnBottomSheetModel(
                        ImageConstants.deleteIcon, "댓글 삭제", 1));
                  }else{
                    items.add(BtnBottomSheetModel(
                        ImageConstants.report, "댓글 신고", 2));
                  }

                  Get.bottomSheet(BtnBottomSheetWidget(
                    btnItems: items,
                    onTapItem: (sheetIdx) async {
                      if(sheetIdx == 0){
                        widget.onEditReply!();
                      }else if(sheetIdx == 1) {
                        await DioClient.removePostComment(reply.id);
                        widget.onDelete();
                      }else{

                      }
                    },
                  ));
                },
                child: SvgPicture.asset(ImageConstants.moreIcon),
              )
            ],
          ),

          SizedBox(height: Get.height*0.015),

          if(reply.contents.isNotEmpty)
            Container(
              width: Get.width,
              child: RichTextView(
                  text: reply.contents,
                  truncate: false,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontFamily: FontConstants.AppFont,
                      fontWeight: FontWeight.w400
                  ),
                  linkStyle: TextStyle(
                      fontSize: 14,
                      color: ColorConstants.blue1,
                      fontFamily: FontConstants.AppFont,
                      fontWeight: FontWeight.w400
                  ),

                  supportedTypes: [
                    MentionParser(
                        onTap: (mention) {

                        }),
                    HashTagParser(
                        onTap: (hashtag) {
                          Get.offAll(BottomNavBarScreen(tagString: hashtag.value,));
                        }),
                    UrlParser(onTap: (url) {
                      Utils.urlLaunch(url.value ?? "");
                    }
                    ),
                  ]
              ),
            ),

          SizedBox(height: Get.height*0.015),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: () async {
                        setState(() {
                          if(reply.isLike){
                            reply.isLike = false;
                            reply.likeCount -= 1;
                          }else{
                            reply.isLike = true;
                            reply.likeCount += 1;
                          }
                        });
                        if(reply.isLike){
                          try{
                            var response = await DioClient.postPostReplyLike(reply.id);
                            print(response);
                          }catch(e){
                            setState(() {
                              reply.isLike = false;
                              reply.likeCount -= 1;
                            });
                          }
                        }else{
                          try{
                            var response = await DioClient.postPostReplyUnLike(reply.id);
                            print(response);
                          }catch(e){
                            setState(() {
                              reply.isLike = true;
                              reply.likeCount += 1;
                            });
                          }
                        }
                      },
                      child: Image.asset(reply.isLike ? ImageConstants.heart : ImageConstants.unHeart, width: 24, height: 24,)
                  ),

                  SizedBox(width: Get.width*0.015),

                  GestureDetector(
                    onTap: (){

                    },
                    child: AppText(text: "${reply.likeCount}",
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(width: 20),

                  if(!widget.isChild)
                    GestureDetector(
                      onTap: (){
                        widget.onTapChild(reply);
                      },
                      child: AppText(
                        text: "답글 ${reply.childrenComments.length}",
                        color: ColorConstants.blue1,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),

              GestureDetector(
                onTap: (){

                },
                child: AppText(
                    text: "번역보기",
                    fontSize: 12,
                    color: ColorConstants.white
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}