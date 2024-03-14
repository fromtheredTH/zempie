


import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/PostReplyModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/PostReplyWidget.dart';
import 'package:app/pages/screens/discover/PostReCommentScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:rich_text_view/rich_text_view.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';
import '../../../models/PostModel.dart';
import '../../../models/res/btn_bottom_sheet_model.dart';
import '../../components/BtnBottomSheetWidget.dart';
import '../../components/UserListItemWidget.dart';
import '../../components/app_text.dart';
import '../../base/base_state.dart';
import '../../components/item/mentionable_text_field/src/mentionable_text_field.dart';
import '../../components/loading_widget.dart';
import '../../components/post_widget.dart';
import '../profile/profile_screen.dart';

class PostCommentScreen extends StatefulWidget {
  PostCommentScreen({super.key, required this.post, required this.refreshPost});
  PostModel post;
  Function(PostModel) refreshPost;

  @override
  State<PostCommentScreen> createState() => _PostCommentScreen();
}

class _PostCommentScreen extends BaseState<PostCommentScreen> {
  RxInt? currentIndex = 0.obs;
  late PostModel post;

  int replySortedIndex = 1;

  late Future replyFuture;

  List<PostReplyModel> replies = [];
  int replyPage = 0;
  bool hasNextReply = false;
  late SuggestionController suggestionController;
  List<UserModel> mentionUsers = [];

  late MentionTextEditingController mentionController;
  String replyText = "";

  FocusNode _node = FocusNode();
  bool isEditMode = false;
  String? editId;

  ScrollController scrollController = ScrollController();


  Future<List<PostReplyModel>> initPostReplies() async {
    var response = await DioClient.getPostComments(post.id, 10, 0);
    List<PostReplyModel> results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostReplyModel.fromJson(json)).toList().cast<PostReplyModel>();
    replyPage = 1;
    hasNextReply = response.data["pageInfo"]?["hasNextPage"] ?? false;
    setState(() {
      replies = results;
    });
    return replies;
  }

  Future<void> getScrollNextPage() async {
    if (scrollController.position.extentAfter < 200 && !isLoading && hasNextReply) {
      isLoading = true;
      var response = await DioClient.getPostComments(post.id, 10, replyPage);
      List<PostReplyModel> results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostReplyModel.fromJson(json)).toList().cast<PostReplyModel>();
      replyPage += 1;
      hasNextReply = response.data["pageInfo"]?["hasNextPage"] ?? false;
      setState(() {
        replies.addAll(results);
      });
      isLoading = false;
    }
  }

  @override
  void initState() {
    post = widget.post;
    replyFuture = initPostReplies();
    super.initState();
    scrollController.addListener(getScrollNextPage);
    _node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: Get.height * 0.06,
                  left: Get.width * 0.05,
                  right: Get.width * 0.05,
                  bottom: 15),
              child:Row(
                children: [
                  GestureDetector(
                    onTap:(){
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.01,
                  ),
                  AppText(
                    text: "댓글",
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: FontConstants.AppFont,
                    fontWeight: FontWeight.w700,
                  ),
                  AppText(
                    text: " ${post.commentCount}",
                    fontSize: 16,
                    color: ColorConstants.yellow,
                    fontFamily: FontConstants.AppFont,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),

            SizedBox(height: Get.height*0.02),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row(
                            //   children: [
                            //     GestureDetector(
                            //       onTap: (){
                            //         replySortedIndex = 0;
                            //         initPostReplies();
                            //       },
                            //       child: Container(
                            //         decoration: BoxDecoration(
                            //             color: replySortedIndex == 0 ? ColorConstants.white : ColorConstants.white10Percent,
                            //             borderRadius: BorderRadius.circular(4)),
                            //         padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                            //         child: Center(
                            //           child: AppText(
                            //               text: "TOP",
                            //               fontSize: 14,
                            //               textAlign: TextAlign.center,
                            //               color: replySortedIndex == 0 ? ColorConstants.black : ColorConstants.halfWhite,
                            //               fontWeight: FontWeight.w700),
                            //         ),
                            //       ),
                            //     ),
                            //     SizedBox(width: Get.width*0.02),
                            //     GestureDetector(
                            //       onTap: (){
                            //         replySortedIndex = 1;
                            //         initPostReplies();
                            //       },
                            //       child: Container(
                            //         decoration: BoxDecoration(
                            //             color: replySortedIndex == 1 ? ColorConstants.white : ColorConstants.white10Percent,
                            //             borderRadius: BorderRadius.circular(4)),
                            //         padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                            //         child: Center(
                            //           child: AppText(
                            //               text: "최근",
                            //               fontSize: 14,
                            //               textAlign: TextAlign.center,
                            //               color: replySortedIndex == 1 ? ColorConstants.black : ColorConstants.halfWhite,
                            //               fontWeight: FontWeight.w700),
                            //         ),
                            //       ),
                            //     )
                            //   ],
                            // ),
                            FutureBuilder(
                                future: replyFuture,
                                builder: (context, snapShot) {
                                  if(snapShot.hasData){
                                    if(replies.length == 0){
                                      return Padding(
                                        padding: EdgeInsets.only(top: Get.height*0.3),
                                        child: Center(
                                          child: AppText(
                                            text: "댓글이 없습니다",
                                            fontSize: 14,
                                            color: ColorConstants.halfWhite,
                                          ),
                                        ),
                                      );
                                    }
                                    return MediaQuery.removePadding(
                                      removeTop: true,
                                      removeRight: true,
                                      removeLeft: true,
                                      removeBottom: true,
                                      context: context,
                                      child: ListView.builder(
                                          itemCount: replies.length,
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (context,index){
                                            Key key = Key(replies[index].id.toString());
                                            return PostReplyWidget(key: key, reply: replies[index], onTapChild: (parentReply){
                                              Get.to(PostReCommentScreen(post: post, parentReply: parentReply, refreshReply: (reply){
                                                setState(() {
                                                  replies[index] = reply;
                                                });
                                              }, deleteParentReply: (){
                                                setState(() {
                                                  post.commentCount -= 1;
                                                  replies.removeAt(index);
                                                  widget.refreshPost(post);
                                                });
                                              },));
                                            },onDelete:(){
                                              setState(() {
                                                post.commentCount -= 1;
                                                replies.removeAt(index);
                                                widget.refreshPost(post);
                                              });
                                            }, onEditReply: (){
                                              setState(() {
                                                replyText = replies[index].contents;
                                                mentionController.text = replies[index].contents;
                                                editId = replies[index].id;
                                                isEditMode = true;
                                              });
                                              _node.requestFocus();
                                            },
                                            );
                                          }),
                                    );
                                  }

                                  return Padding(
                                      padding: EdgeInsets.only(top: Get.height*0.3),
                                      child: LoadingWidget()
                                  );
                                }
                            )


                          ],
                        ),
                      )
                    ]),
              ),
            ),

            Column(
              children: [

                if(mentionUsers.isNotEmpty)
                  Container(
                    color: Color(0xff424451),
                    constraints: BoxConstraints(
                        maxHeight: Get.height*0.2,
                        minHeight: Get.height*0.05
                    ),
                    child: ListView.builder(
                        itemCount: mentionUsers.length,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        shrinkWrap: true,
                        itemBuilder: (context, index){
                          Key key = Key(mentionUsers[index].id.toString());
                          return Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: GestureDetector(
                              onTap: () {
                                mentionController.pickMentionable(mentionUsers[index]);
                                setState(() {
                                  mentionUsers.clear();
                                });
                              },
                              child: UserListItemWidget(key: key, user: mentionUsers[index], isShowAction: false, isMini : true, deleteUser: (){},),
                            ),
                          );
                        }
                    ),
                  ),

                if(isEditMode)
                  Container(
                    color: Color(0xff424451),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppText(
                          text: "댓글 수정 중 입니다",
                          fontSize: 13,
                        ),

                        GestureDetector(
                            onTap: (){
                              setState(() {
                                replyText = "";
                                mentionController.text = "";
                                editId = null;
                                isEditMode = false;
                              });
                            },
                            child: Icon(Icons.close_rounded, size: 18,color: ColorConstants.white,)
                        )
                      ],
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.only(right: 15, left: 10, top: 15, bottom: MediaQuery.of(context).padding.bottom+15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Get.to(ProfileScreen(user: Constants.user));
                        },
                        child: ImageUtils.ProfileImage(Constants.user.picture, 30, 30),
                      ),
                      SizedBox(width: 15,),
                      Flexible(child: Container(
                        decoration: BoxDecoration(color: ColorConstants.backGry,
                            borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        child: Row(
                          children:[
                            SizedBox(
                              width: Get.width * 0.025,
                            ),
                            Flexible(child: MentionableTextField(
                              maxLines: 4,
                              minLines: 1,
                              focusNode: _node,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: FontConstants.AppFont,
                                  color: ColorConstants.white
                              ),
                              decoration: InputDecoration(
                                  hintText: "comment_hint".tr(),
                                  hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontFamily: FontConstants.AppFont,
                                      color: ColorConstants.halfWhite
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero
                              ),
                              onControllerReady: (value) {
                                mentionController = value;
                              },
                              mentionables: Constants.myFollowings,
                              onChanged: (text){
                                replyText = text;
                              },
                              mentionStyle: TextStyle(
                                  fontSize: 14,
                                  fontFamily: FontConstants.AppFont,
                                  color: ColorConstants.blue1
                              ),
                              onMentionablesChanged: (users) {
                                if(users.length == 0 && !replyText.endsWith("@")) {
                                  setState(() {
                                    mentionUsers.clear();
                                  });
                                  return;
                                }
                                mentionUsers.clear();
                                for(int i=0;i<users.length;i++){
                                  UserModel model = users[i] as UserModel;
                                  mentionUsers.add(model);
                                }
                                List<int> followIdList = mentionUsers.map((e) => e.id).toList();
                                for(int i=0;i<Constants.myFollowings.length;i++){
                                  if(!followIdList.contains(Constants.myFollowings[i].id)){
                                    mentionUsers.add(Constants.myFollowings[i]);
                                  }
                                }
                                setState(() {

                                });
                              },
                            ))
                          ],
                        ),
                      ),),
                      SizedBox(width: 15,),
                      GestureDetector(
                        onTap: () async {
                          String replyContent = mentionController.buildMentionedValue();
                          if(replyContent.isEmpty){
                            Utils.showToast("input_reply".tr());
                            return;
                          }

                          if(isEditMode){
                            var response = await DioClient.editPostComment(
                                editId ?? "", replyContent);
                            PostReplyModel result = PostReplyModel.fromJson(response.data);

                            setState(() {
                              isEditMode = false;
                              editId = null;
                              for(int i=0;i<replies.length;i++) {
                                if(replies[i].id == result.id) {
                                  replies[i] = result;
                                  break;
                                }
                              }
                            });
                            Utils.showToast("edited_reply".tr());
                          }else {
                            var response = await DioClient.sendPostComment(
                                post.id, replyContent, null);
                            PostReplyModel result = PostReplyModel.fromJson(response.data);

                            setState(() {
                              replies.insert(0, result);
                              post.commentCount += 1;
                              widget.refreshPost(post);
                            });
                            Utils.showToast("complete_reply".tr());
                          }
                          replyText = "";
                          mentionController.text = "";
                          FocusManager.instance.primaryFocus?.unfocus();

                        },
                        child: Image.asset(ImageConstants.sendChatBnt, width: 30, height: 30,),
                      ),
                    ],

                  ),
                )
              ],
            )
          ],
        )
    );

  }
}


class TopModel{

  RxBool? isSelected=false.obs;
  TopModel({this.isSelected});
}