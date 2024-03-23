


import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/ReplyModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/ReplyWidget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
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

class GameDetailReplyScreen extends StatefulWidget {
  GameDetailReplyScreen({super.key, required this.game, required this.parentReply, required this.refreshReply, required this.deleteParentReply});
  GameModel game;
  ReplyModel parentReply;
  Function(ReplyModel) refreshReply;
  Function() deleteParentReply;

  @override
  State<GameDetailReplyScreen> createState() => _GameDetailReplyScreen();
}

class _GameDetailReplyScreen extends BaseState<GameDetailReplyScreen> {
  late GameModel game;
  late ReplyModel parentReply;

  late Future replyFuture;
  List<ReplyModel> replies = [];
  bool hasNextPage = false;
  int page = 0;

  ScrollController scrollController = ScrollController();

  FocusNode _node = FocusNode();
  bool isEditMode = false;
  int? editId;


  List<UserModel> mentionUsers = [];
  late MentionTextEditingController mentionController;
  RxString replyText = "".obs;

  Future<List<ReplyModel>> initChildReplies() async {
    var response = await DioClient.getGameReReplies(parentReply.id, 10, 0);
    List<ReplyModel> results = response.data["result"]?["replies"] == null ? [] : response.data["result"]["replies"].map((json) => ReplyModel.fromJson(json)).toList().cast<ReplyModel>();
    page = 1;
    hasNextPage = response.data["result"]?["pageInfo"]?["hasNextPage"] ?? false;
    replies = results;
    return replies;
  }

  Future<void> getNextChildReplies() async {
    if (scrollController.position.extentAfter < 200 && !isLoading && hasNextPage) {
      isLoading = true;
      var response = await DioClient.getGameReReplies(parentReply.id, 10, page);
      List<ReplyModel> results = response.data["result"]?["replies"] == null ? [] : response.data["result"]["replies"].map((json) => ReplyModel.fromJson(json)).toList().cast<ReplyModel>();
      page += 1;
      hasNextPage = response.data["result"]?["pageInfo"]?["hasNextPage"] ?? false;
      setState(() {
        replies.addAll(results);
      });
      isLoading = false;
    }
  }

  @override
  void initState() {
    game = widget.game;
    parentReply = widget.parentReply;
    replyFuture = initChildReplies();
    super.initState();
    scrollController.addListener(getNextChildReplies);
    _node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {

    return PageLayout(
        child: Scaffold(
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
                        text: "recomment".tr(),
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w700,
                      ),
                      AppText(
                        text: " ${parentReply.countReply}",
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
                      child: Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                            children: [

                              ReplyWidget(reply: parentReply, isChild: false, onTapChild: (parentReply){

                              },onDelete:(){
                                setState(() {
                                  setState(() {
                                    widget.deleteParentReply();
                                  });
                                });
                              }, onEditReply: (){
                                setState(() {
                                  replyText.value = parentReply.content;
                                  mentionController.text = parentReply.content;
                                  editId = parentReply.id;
                                  isEditMode = true;
                                });
                                _node.requestFocus();
                              },),

                              FutureBuilder(
                                  future: replyFuture,
                                  builder: (context, snapShot) {
                                    if(snapShot.hasData){
                                      if(replies.length == 0){
                                        return Padding(
                                          padding: EdgeInsets.only(top: 50,bottom: 50),
                                          child: Center(
                                            child: AppText(
                                              text: "empty_rereply".tr(),
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
                                              return ReplyWidget(key: key, reply: replies[index], isChild : true, onTapChild: (parentReply){

                                              },onDelete:(){
                                                setState(() {
                                                  setState(() {
                                                    replies.removeAt(index);
                                                    parentReply.countReply -= 1;
                                                    widget.refreshReply(parentReply);
                                                  });
                                                });
                                              }, onEditReply: (){
                                                setState(() {
                                                  replyText.value = replies[index].content;
                                                  mentionController.text = replies[index].content;
                                                  editId = replies[index].id;
                                                  isEditMode = true;
                                                });
                                                _node.requestFocus();
                                              },);
                                            }),
                                      );
                                    }

                                    return Padding(
                                        padding: EdgeInsets.only(top: 50,bottom: 50),
                                        child: LoadingWidget()
                                    );
                                  }
                              )
                            ]),
                      )
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
                              text: "editing_comment".tr(),
                              fontSize: 13,
                            ),

                            GestureDetector(
                                onTap: (){
                                  setState(() {
                                    replyText.value = "";
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
                                    replyText.value = "@${parentReply.user.nickname} ";
                                    mentionController.text = "@${parentReply.user.nickname} ";
                                    _node.requestFocus();
                                  },
                                  mentionables: Constants.myFollowings,
                                  onChanged: (text){
                                    replyText.value = text;
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
                          Obx(() => GestureDetector(
                            onTap: () async {
                              String replyContent = mentionController.buildMentionedValue();
                              if(replyContent.isEmpty){
                                Utils.showToast("please_input_comment".tr());
                                return;
                              }
                              if(isEditMode){
                                var response = await DioClient.editGameComment(
                                    editId ?? 0, replyContent);
                                ReplyModel result = ReplyModel.fromJson(response.data["result"]);

                                setState(() {
                                  isEditMode = false;
                                  editId = null;
                                  if(parentReply.id == result.id){
                                    parentReply = result;
                                    widget.refreshReply(parentReply);
                                  }else {
                                    for (int i = 0; i < replies.length; i++) {
                                      if (replies[i].id == result.id) {
                                        replies[i] = result;
                                        break;
                                      }
                                    }
                                  }
                                });
                                Utils.showToast("comment_edited".tr());
                              }else {
                                var response = await DioClient.sendGameComment(game
                                    .id, replyContent, parentReply.id);
                                ReplyModel result = ReplyModel.fromJson(response
                                    .data["result"]);
                                setState(() {
                                  replies.insert(0, result);
                                  parentReply.countReply += 1;
                                  widget.refreshReply(parentReply);
                                });
                                Utils.showToast("comment_added".tr());
                              }
                              replyText.value = "";
                              mentionController.text = "";
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Image.asset(replyText.value.isNotEmpty ? ImageConstants.sendChatBnt : ImageConstants.sendChatDisableBnt, width: 30, height: 30,),
                          ),)
                        ],

                      ),
                    )
                  ],
                )
              ],
            )
        )
    );

  }
}


class TopModel{

  RxBool? isSelected=false.obs;
  TopModel({this.isSelected});
}