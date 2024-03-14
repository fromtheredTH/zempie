

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/PostModel.dart';
import 'package:app/pages/components/BtnBottomSheetWidget.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/components/item/TagDev.dart';
import 'package:app/pages/components/report_dialog.dart';
import 'package:app/pages/components/report_user_dialog.dart';
import 'package:app/pages/screens/communityScreens/community_detal_screen.dart';
import 'package:app/pages/screens/discover/DiscoverGameDetails.dart';
import 'package:app/pages/screens/discover/PostCommentScreen.dart';
import 'package:app/pages/screens/postLikeScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:html/dom.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:rich_text_view/rich_text_view.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/utils.dart';
import '../../models/User.dart';
import '../../models/res/btn_bottom_sheet_model.dart';
import '../base/base_state.dart';
import '../screens/bottomnavigationscreen/bottomNavBarScreen.dart';
import '../screens/newPostScreen.dart';
import '../screens/profile/profile_screen.dart';
import 'dialog.dart';

class PostWidget extends StatefulWidget {
  PostWidget({super.key, required this.post, required this.onPostDeleteAction});
  PostModel post;
  Function(PostModel, String) onPostDeleteAction;

  @override
  State<PostWidget> createState() => _PostWidget();
}

class _PostWidget extends BaseState<PostWidget> {

  late PostModel post;
  late String contents;
  String translationContents = "";
  bool isTranslation = false;
  int _current = 0;

  @override
  void initState() {
    post = widget.post;
    contents = post.contents;
    // 특정 태그 처리
    contents = contents.replaceAll("</p>", "</p>\n");
    contents = contents.replaceAll("<br>", "<br>\n");
    contents = contents.replaceAll("<hr>", "<hr>\n");
    contents = contents.replaceAll("<strong>", "<strong>\n\n");
    contents = contents.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: post.backgroundId == -1 ? BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(Constants.getBg(post.backgroundId).imgUrl),
              fit: BoxFit.cover
          )
      ) : BoxDecoration(
        color: ColorConstants.colorBg1
      ),
      child: Padding(
        padding: EdgeInsets.all(Get.height*0.022),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    Get.to(ProfileScreen(user: post.user));
                  },
                  child: Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: Get.height*0.045,
                          height: Get.height*0.045,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle
                          ),
                          child: ImageUtils.ProfileImage(
                              post.user.picture,
                              Get.height*0.045,
                              Get.height*0.045
                          ),
                        ),
                      ),
                      SizedBox(width: Get.width*0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(text: post.user.nickname,
                              fontSize: 13,
                              color: ColorConstants.white,
                              textAlign: TextAlign.start,
                              fontFamily: FontConstants.AppFont,
                              fontWeight: FontWeight.w700),

                          SizedBox(height: Get.height*0.005),
                          Row(
                            children: [
                              if(post.user.profile.jobGroup == "1")
                                TagCreatorWidget(),
                              SizedBox(width: Get.width*0.01),
                              if(post.user.profile.jobPosition == "0")
                                TagDevWidget()
                            ],
                          ),
                          SizedBox(height: Get.height*0.005),
                          AppText(
                              text: Utils.getTimePost(post.createdAt),
                              fontSize: 12,
                              color: ColorConstants.halfWhite,
                              fontWeight: FontWeight.w400),
                        ],


                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    List<BtnBottomSheetModel> items = [];
                    if(Constants.user.id == post.user.id){
                      items.add(BtnBottomSheetModel("", "포스팅 수정", 0));
                      items.add(BtnBottomSheetModel("", "포스팅 삭제", 1));
                    }else{
                      items.add(BtnBottomSheetModel(ImageConstants.report, "포스팅 신고", 2));
                      items.add(BtnBottomSheetModel(ImageConstants.block, "유저 차단", 3));
                      items.add(BtnBottomSheetModel(ImageConstants.report, "유저 신고", 4));
                    }

                    Get.bottomSheet(BtnBottomSheetWidget(btnItems: items, onTapItem: (menuIndex) async {
                      if(menuIndex == 0){
                        Get.to(NewPostScreen(uploadedPost: (post){
                          setState(() {
                            this.post = post;
                            contents = post.contents;
                            // 특정 태그 처리
                            contents = contents.replaceAll("</p>", "</p>\n");
                            contents = contents.replaceAll("<br>", "<br>\n");
                            contents = contents.replaceAll("<hr>", "<hr>\n");
                            contents = contents.replaceAll("<strong>", "<strong>\n\n");
                            contents = contents.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
                          });
                        }, post: post,
                        ));
                      }else if(menuIndex == 1){
                        AppDialog.showConfirmDialog(context, "delete_post".tr(), "delete_description".tr(), () async {
                          var response = await DioClient.removePost(post.id);
                          Utils.showToast("delete_complete".tr());
                          widget.onPostDeleteAction(post, "delete");
                        });
                      }else if(menuIndex == 2){
                        showModalBottomSheet<dynamic>(
                            isScrollControlled: true,
                            context: context,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext bc) {
                              return ReportDialog(type: "post", onConfirm: (reportList, reason) async {
                                var response = await DioClient.reportPost(post.id, reportList, reason);
                                widget.onPostDeleteAction(post, "delete");
                                Utils.showToast("report_complete".tr());
                              },);
                            }
                        );

                      }else if(menuIndex == 3){
                        var response = await DioClient.postUserBlock(post.user.id);
                        widget.onPostDeleteAction(post, "userBlock");
                        Utils.showToast("ban_complete".tr());
                      }else{
                        showModalBottomSheet<dynamic>(
                            isScrollControlled: true,
                            context: context,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext bc) {
                              return ReportUserDialog(onConfirm: (reportList, reason) async {
                                var response = await DioClient.reportUser(post.user.id, reportList, reason);
                                widget.onPostDeleteAction(post, "userBlock");
                                Utils.showToast("report_complete".tr());
                              },);
                            }
                        );
                      }
                    }));
                  },
                  child: SvgPicture.asset(ImageConstants.moreIcon),
                )
              ],
            ),
            SizedBox(height: Get.height*0.015),
            if(post.attachmentFiles.length != 0)
              Column(
                children: [
                  Stack(
                    children: [
                      CarouselSlider(
                        items: post.attachmentFiles.map((attachmentFile) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(attachmentFile.url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),

                        options: CarouselOptions(

                          height: Get.height*0.24,
                          autoPlay: false,
                          viewportFraction: 1,
                          enableInfiniteScroll: false,
                          autoPlayCurve: Curves.easeInOut,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 2,
                              bottom: 2,
                              right: 8,
                              left: 8
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.halfBlack,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: AppText(
                            text: '${_current + 1}/${post.attachmentFiles.length}',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Get.height*0.015),
                ],
              ),

            if(post.contents.isNotEmpty)
            Container(
              width: Get.width,
              decoration: BoxDecoration(
                  color: ColorConstants.postContentBg,
                  borderRadius: BorderRadius.circular(5.0)),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  RichTextView(
                      text: isTranslation ? translationContents : contents,
                      maxLines: 4,
                      truncate: true,
                      viewLessText: 'less'.tr(),
                  viewMoreText: 'more'.tr(),
                  viewMoreLessStyle : TextStyle(
                      fontSize: 13,
                      color: ColorConstants.halfWhite,
                      fontFamily: FontConstants.AppFont,
                      fontWeight: FontWeight.w400
                  ),
                      style: TextStyle(
                          fontSize: 13,
                          color: ColorConstants.white,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400
                      ),
                      linkStyle: TextStyle(
                          fontSize: 13,
                          color: ColorConstants.blue1,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400
                      ),
                      supportedTypes: [
                        MentionParser(
                            onTap: (mention)  async {
                              if(mention.value!.length != 0){
                                String nickname = mention.value!.substring(1,mention.value!.length);
                                var response = await DioClient.getUser(nickname);
                                UserModel user = UserModel.fromJson(response.data["result"]["target"]);
                                Get.to(ProfileScreen(user: user));
                              }
                            } ),
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

                  SizedBox(height: 10,),

                  GestureDetector(
                    onTap: () async {
                      if(!isTranslation){
                        if(contents.isNotEmpty && translationContents.isEmpty) {
                          var response = await DioClient.translate(contents);
                          List<dynamic> results = response.data["result"]["translations"];
                          if(results.isNotEmpty){
                            translationContents = results[0]["translatedText"];
                          }
                        }
                      }
                      setState(() {
                        isTranslation = !isTranslation;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 0),
                      child: AppText(
                          text: isTranslation ? "원문보기" : "번역보기",
                          fontSize: 12,
                          color: ColorConstants.skyBlueTextColor
                      ),

                    ),
                  ),

                  SizedBox(height: 5,),
                ],
              ),


            ),
            SizedBox(height: Get.height*0.01),
            if(post.postedAt.communities.length != 0)
              Column(
                children: [
                  Container(
                      width: double.maxFinite,
                      height: 30,
                      child: ListView.builder(
                          itemCount: post.postedAt.communities.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context,index){
                            return  GestureDetector(
                              onTap: (){
                                Get.to(CommunityDetailScreen(community: post.postedAt.communities[index], refreshCommunity: (community){

                                }));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    color: ColorConstants.white10Percent,
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // SizedBox(width: Get.width*0.01),
                                    SvgPicture.asset(ImageConstants.communityLogo,height: 16, width: 16),
                                    SizedBox(width: Get.width*0.015),
                                    Center(
                                      child: AppText(text: "${post.postedAt.communities[index].name}",
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                  ),

                ],
              ),

            if(post.postedAt.games.length != 0)
              Column(
                children: [
                  SizedBox(height: 8,),

                  Container(
                    width: double.maxFinite,
                    height: 30,
                    child: ListView.builder(
                        itemCount: post.postedAt.games.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context,index){
                          return  GestureDetector(
                            onTap: (){
                              Get.to(DiscoverGameDetails(game: post.postedAt.games[index], refreshGame: (game){

                              }));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                                  child: ImageUtils.setGameListSmallNetworkImage(post.postedAt.games[index].urlThumb)
                                  // Image.asset(ImageConstants.leagueOfLegends, width: Get.height*0.026, height: Get.height*0.026,),
                                ),
                                SizedBox(width: Get.width*0.015),
                                Center(
                                  child: AppText(
                                      text: post.postedAt.games[index].title,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          );
                        }
                        ),
                  ),

                  SizedBox(height: Get.height*0.015),
                ],
              ),

            SizedBox(height: Get.height*0.005),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {

                        if(post.liked){
                          setState(() {
                            post.liked = !post.liked;
                            post.likeCount -= 1;
                          });
                          try{
                            var response = await DioClient.unLikePost(post.id);
                            print(response);
                          }catch(e){
                            setState(() {
                              post.liked = !post.liked;
                              post.likeCount += 1;
                            });
                          }
                        }else{
                          setState(() {
                            post.liked = !post.liked;
                            post.likeCount += 1;
                          });
                          try{
                            var response = await DioClient.likePost(post.id);
                            print(response);
                          }catch(e){
                            setState(() {
                              post.liked = !post.liked;
                              post.likeCount -= 1;
                            });
                          }
                        }
                      },
                      child: Image.asset(post.liked ? ImageConstants.heart : ImageConstants.unHeart, width: 24, height: 24,)
                    ),

                    SizedBox(width: Get.width*0.015),

                    GestureDetector(
                      onTap: (){
                        Get.to(PostLikeScreen(post: post));
                      },
                      child: AppText(text: "${post.likeCount}",
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(width: Get.width*0.02),

                    GestureDetector(
                      onTap: (){
                        Get.to(PostCommentScreen(post: post, refreshPost: (post){
                          setState(() {
                            this.post = post;
                          });
                        }));
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(ImageConstants.chatSquare, width: 24, height: 24),
                          SizedBox(width: Get.width*0.015),
                          AppText(text: "${post.commentCount}",
                            fontSize: 14,
                          ),
                        ],
                      )
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: (){

                  },
                  child: SvgPicture.asset(ImageConstants.shareIcon),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}