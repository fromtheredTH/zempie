

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/PostModel.dart';
import 'package:app/models/ReplyModel.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/components/item/TagDev.dart';
import 'package:app/pages/components/report_dialog.dart';
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
import '../screens/profile/profile_screen.dart';
import 'BtnBottomSheetWidget.dart';

class ReplyWidget extends StatefulWidget {
  ReplyWidget({super.key, required this.reply, this.isGameComment=false, this.isChild = false, required this.onTapChild, required this.onDelete,required this.onEditReply});
  ReplyModel reply;
  bool isChild;
  Function(ReplyModel) onTapChild;
  Function() onDelete;
  Function() onEditReply;
  bool isGameComment;

  @override
  State<ReplyWidget> createState() => _ReplyWidget();
}

class _ReplyWidget extends BaseState<ReplyWidget> {

  late ReplyModel reply;

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
                        await DioClient.deleteGameReply(reply.id);
                        widget.onDelete();
                      }else{
                        showModalBottomSheet<dynamic>(
                            isScrollControlled: true,
                            context: context,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext bc) {
                              return ReportDialog(type: "comment", onConfirm: (reportList, reason) async {
                                if(widget.isGameComment) {
                                  var response = await DioClient.reportGameComment(
                                      reply.id, reportList, reason);
                                }else{
                                  var response = await DioClient.reportComment(
                                      reply.id, reportList, reason);
                                }
                                Utils.showToast("신고가 완료되었습니다");
                              },);
                            }
                        );
                      }
                    },
                  ));
                },
                child: SvgPicture.asset(ImageConstants.moreIcon),
              )
            ],
          ),

          SizedBox(height: Get.height*0.015),

          if(reply.content.isNotEmpty)
            Container(
                width: Get.width,
                child: RichTextView(
                    text: reply.content,
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
                            reply.countGood -= 1;
                          }else{
                            reply.isLike = true;
                            reply.countGood += 1;
                          }
                        });
                        if(reply.isLike){
                          try{
                            var response = await DioClient.postGameReplyLike(reply.id, true);
                            print(response);
                          }catch(e){
                            setState(() {
                              reply.isLike = false;
                              reply.countGood -= 1;
                            });
                          }
                        }else{
                          try{
                            var response = await DioClient.postGameReplyLike(reply.id, false);
                            print(response);
                          }catch(e){
                            setState(() {
                              reply.isLike = true;
                              reply.countGood += 1;
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
                    child: AppText(text: "${reply.countGood}",
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
                      text: "답글 ${reply.countReply}",
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