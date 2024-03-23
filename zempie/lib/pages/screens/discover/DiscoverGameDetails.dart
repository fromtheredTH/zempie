


import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/ReplyModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/ReplyWidget.dart';
import 'package:app/pages/screens/discover/GameDetailReplyScreen.dart';
import 'package:app/pages/screens/discover/GameFollowerScreen.dart';
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
import 'package:share_plus/share_plus.dart';
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
import '../../components/report_dialog.dart';
import '../newPostScreen.dart';
import '../profile/profile_screen.dart';

class DiscoverGameDetails extends StatefulWidget {
   DiscoverGameDetails({super.key, required this.game, required this.refreshGame});
   GameModel game;
   Function(GameModel) refreshGame;

  @override
  State<DiscoverGameDetails> createState() => _DiscoverGameDetailsState();
}

class _DiscoverGameDetailsState extends BaseState<DiscoverGameDetails> {
   RxInt? currentIndex = 0.obs;
   late GameModel game;

  int? _selectedIndex = 0;
  int replySortedIndex = 0;

   late Future postFuture;
   late Future replyFuture;
   List<PostModel> posts = [];
   int postPage = 0;
   bool hasNextPosts = false;
   List<ReplyModel> replies = [];
   int replyPage = 0;
   bool hasNextReply = false;
   late SuggestionController suggestionController;
   List<UserModel> mentionUsers = [];

   late MentionTextEditingController mentionController;
   RxString replyText = "".obs;

   FocusNode _node = FocusNode();
   bool isEditMode = false;
   int? editId;

   ScrollController scrollController = ScrollController();

   Future<List<PostModel>> initGameTimelines() async {
    var response = await DioClient.getGameTimelines(game.pathname, 10, 0);
    List<PostModel> results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
    postPage = 1;
    hasNextPosts = response.data?["pageInfo"]?["hasNextPage"] ?? false;
    setState(() {
      posts = results;
    });
    return posts;
  }

  Future<List<ReplyModel>> initGameReplies() async {
    var response = await DioClient.getGameReplies(game.id, 10, 0 , replySortedIndex == 0 ? "count_good" : "created_at");
    List<ReplyModel> results = response.data["result"]?["replies"] == null ? [] : response.data["result"]["replies"].map((json) => ReplyModel.fromJson(json)).toList().cast<ReplyModel>();
    replyPage = 1;
    hasNextReply = response.data["result"]?["pageInfo"]?["hasNextPage"] ?? false;
    setState(() {
      replies = results;
    });
    return replies;
  }

   Future<void> getScrollNextPage() async {
     if (scrollController.position.extentAfter < 200 && !isLoading) {
       if(_selectedIndex == 0 && hasNextPosts){
         isLoading = true;
         var response = await DioClient.getGameTimelines(game.pathname, 10, postPage);
         List<PostModel> results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
         postPage += 1;
         hasNextPosts = response.data["pageInfo"]?["hasNextPage"] ?? false;
         setState(() {
           posts.addAll(results);
         });
         isLoading = false;
       }else if(_selectedIndex == 1 && hasNextReply){
         isLoading = true;
         var response = await DioClient.getGameReplies(game.id, 10, replyPage , replySortedIndex == 0 ? "count_good" : "created_at");
         List<ReplyModel> results = response.data["result"]?["replies"] == null ? [] : response.data["result"]["replies"].map((json) => ReplyModel.fromJson(json)).toList().cast<ReplyModel>();
         replyPage += 1;
         hasNextReply = response.data["result"]?["pageInfo"]?["hasNextPage"] ?? false;
         setState(() {
           replies.addAll(results);
         });
         isLoading = false;
       }
       isLoading = false;
     }
   }

  Future<void> initGameDetail() async {
    var response = await DioClient.getGameDetail(game.pathname);
    if(response.data["result"]?["game"] != null) {
      GameModel result = GameModel.fromJson(response.data["result"]["game"]);
      setState(() {
        game = result;
        widget.refreshGame(game);
      });
    }
  }

  @override
  void initState() {
    game = widget.game;
    postFuture = initGameTimelines();
    replyFuture = initGameReplies();
    initGameDetail();
    super.initState();
    scrollController.addListener(getScrollNextPage);
  }

  @override
  Widget build(BuildContext context) {

    return PageLayout(
        child: Scaffold(
            backgroundColor: ColorConstants.colorBg1,
            resizeToAvoidBottomInset: true,
            body: Column(
              children: [
                SizedBox(height: Get.height*0.07),
                Padding(
                  padding:EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back_ios, color:Colors.white)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: (){
                              Share.share("https://zempie.com/game/${game.pathname}");
                            },
                            child:SvgPicture.asset(ImageConstants.shareIcon),
                          ),
                          SizedBox(width: Get.width*0.03),
                          GestureDetector(
                            onTap: (){
                              List<BtnBottomSheetModel> items = [];
                              if(game.isFollow)
                                items.add(BtnBottomSheetModel(ImageConstants.unSubscribe, "follow_cancel".tr(), 0));
                              items.add(BtnBottomSheetModel(ImageConstants.report, "game_report".tr(), 1));

                              Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(btnItems: items, onTapItem: (menuIndex) async {
                                if(menuIndex == 0){
                                  await DioClient.postGameUnFollow(game.id);
                                  Constants.removeGameFollow(game.id);
                                  Utils.showToast("cancel_follow".tr());
                                  initGameDetail();
                                }else{
                                  showModalBottomSheet<dynamic>(
                                      isScrollControlled: true,
                                      context: context,
                                      useRootNavigator: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (BuildContext bc) {
                                        return ReportDialog(type: "game", onConfirm: (reportList, reason) async {
                                          var response = await DioClient.reportGame(game.id, reportList, reason);
                                          Utils.showToast("report_complete");
                                        },);
                                      }
                                  );
                                }
                              }));
                            },
                            child:
                            SvgPicture.asset(ImageConstants.moreIcon),
                          )

                        ],
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
                          Stack(
                            children: [
                              CarouselSlider(
                                items: game.urlBanner.map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Image.network(
                                        i,
                                        height: Get.height*0.2,
                                        width: Get.width,
                                        fit: BoxFit.fill,
                                      );
                                    },
                                  );
                                }).toList(),
                                options: CarouselOptions(
                                  height: Get.height*0.26,
                                  aspectRatio: 16/9,
                                  enlargeCenterPage: false,
                                  autoPlay: false,
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enableInfiniteScroll: true,
                                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                                  viewportFraction: 1,
                                  onPageChanged: (index, reason) {
                                    currentIndex!.value = index;
                                  },
                                ),
                              ),
                              if(game.urlBanner.length > 0)
                                Obx(() =>
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: DotsIndicator(
                                        decorator: DotsDecorator(activeColor: ColorConstants.yellow),
                                        dotsCount:  game.urlBanner.length,
                                        position: currentIndex!.value,
                                      ),
                                    )),
                            ],
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10,top: 8,bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(border:Border.all(color: ColorConstants.white, width: 1)),
                                  child: ImageUtils.setRectNetworkImage(game.urlThumb, 80, 80),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(text: game.title,
                                        fontSize: 16,
                                        maxLine: 2,
                                        fontWeight: FontWeight.w700,
                                        color: ColorConstants.white),
                                    AppText(text: "by @${game.user?.nickname ?? ""}",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: ColorConstants.halfWhite),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: GestureDetector(
                                      onTap: (){
                                        Utils.urlLaunch(game.urlGame);
                                      },
                                      child: Container(
                                        height: 50,
                                        margin: EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                                            color: ColorConstants.colorMain
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AppText(
                                              text: "play_game".tr(),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,),
                                            SizedBox(width: 10),
                                            SvgPicture.asset(ImageConstants.downArrow, width: 8, height: 8,)

                                          ],
                                        ),
                                      ),
                                    )
                                ),
                                Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        if(game.isFollow && game.user!.id == Constants.user.id){
                                          Get.to(GameFollowerScreen(game: game));
                                        }else{
                                          await DioClient.postGameFollow(game.id);
                                          Constants.addGameFollow(game);
                                          Utils.showToast("game_folow_complete".tr());
                                          initGameDetail();
                                        }
                                      },
                                      child: Container(
                                          height: 50,
                                          margin: EdgeInsets.only(left: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: ColorConstants.colorMain, width: 1.0),
                                            borderRadius: BorderRadius.all(Radius.circular(10)),

                                          ),
                                          child: !game.isFollow && (game.user?.id ?? 0) != Constants.user.id ? Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add, color: ColorConstants.colorMain, size: 16,),
                                              SizedBox(width: 5),
                                              AppText(text: "follow".tr(),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorConstants.colorMain),
                                            ],
                                          ) : Center(
                                            child: AppText(text: "${"follower".tr()} ${game.followerCount}",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: ColorConstants.colorMain),
                                          )
                                      ),
                                    )
                                )

                              ],
                            ),
                          ),
                          SizedBox(height: Get.height*0.02),
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: RichTextView(
                              text: game.description,
                              maxLines: 4,
                              truncate: true,
                              supportedTypes: [
                                MentionParser(
                                    onTap: (mention) async {
                                      if(mention.value!.length != 0){
                                        String nickname = mention.value!.substring(1,mention.value!.length);
                                        var response = await DioClient.getUser(nickname);
                                        UserModel user = UserModel.fromJson(response.data["result"]["target"]);
                                        Get.to(ProfileScreen(user: user));
                                      }
                                    }),
                                HashTagParser(
                                    onTap: (hashtag) =>
                                        print('is ${hashtag.value} trending?')),
                                UrlParser(onTap: (url) {
                                  Utils.urlLaunch(url.value ?? "");
                                }
                                ),
                              ],
                              viewLessText: 'less'.tr(),
                              viewMoreText: 'more'.tr(),
                              textAlign: TextAlign.left,
                              viewMoreLessStyle : TextStyle(
                                  fontSize: 14,
                                  color: ColorConstants.halfWhite,
                                  fontFamily: FontConstants.AppFont,
                                  fontWeight: FontWeight.w400
                              ),
                              style: TextStyle(
                                  color: ColorConstants.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: FontConstants.AppFont
                              ),
                              linkStyle: TextStyle(
                                  fontSize: 14,
                                  color: ColorConstants.blue1,
                                  fontFamily: FontConstants.AppFont,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ),

                          SizedBox(height: 15,),

                          if((game.user?.id ?? 0) == Constants.user.id)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                GestureDetector(
                                  onTap: (){
                                    Get.to(ProfileScreen(user: Constants.user));
                                  },
                                  child: ImageUtils.ProfileImage(Constants.user.picture, 40, 40),
                                ),

                                SizedBox(width: 10,),

                                Flexible(
                                    child: GestureDetector(
                                      onTap: (){
                                        Get.to(NewPostScreen(uploadedPost: (post){
                                          setState(() {
                                            posts.insert(0, post);
                                          });
                                        }, firstGame: game,));
                                      },
                                      child: Container(
                                        width: double.maxFinite, // Set width according to your needs
                                        decoration: BoxDecoration(
                                          color: ColorConstants.searchBackColor,
                                          borderRadius:
                                          BorderRadius.circular(6.0), // Adjust the value as needed
                                        ),
                                        child: TextFormField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            hintText: 'What’s on your mind?',

                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0), // Adjust vertical padding
                                            border: InputBorder.none,

                                            // Align hintText to center
                                            hintStyle: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white, fontSize: Get.height * 0.016),
                                            alignLabelWithHint: true,
                                          ),
                                        ),
                                      ),
                                    )
                                )
                              ],
                            ),

                          SizedBox(height: 10,),
                          DefaultTabController(
                            length: 2,
                            child: TabBar(
                              indicatorColor: ColorConstants.white,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorWeight: 2,
                              labelColor: Colors.white,
                              dividerColor: ColorConstants.tabDividerColor,
                              unselectedLabelColor: ColorConstants.tabTextColor,
                              labelStyle: TextStyle(
                                  fontSize: 14,
                                  fontFamily: FontConstants.AppFont,
                                  fontWeight: FontWeight.w700),
                              tabs: [
                                Tab(text: '${"post".tr()} ${game.postCount}'),
                                Tab(text: 'comment'.tr(args: [game.commentCount.toString()])),
                              ],
                              onTap: (index) {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },

                            ),
                          ),

                          (_selectedIndex==0)?
                          FutureBuilder(
                              future: postFuture,
                              builder: (context, snapShot) {
                                if(snapShot.hasData){
                                  if(posts.length == 0){
                                    return Padding(
                                      padding: EdgeInsets.only(top: 50,bottom: 50),
                                      child: Center(
                                        child: AppText(
                                          text: "empty_post".tr(),
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
                                        itemCount: posts.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context,index){
                                          Key key = Key(posts[index].id);
                                          return  PostWidget(key: key, post: posts[index], onPostDeleteAction: (post, msg){
                                            if(msg == "delete"){
                                              setState(() {
                                                posts.removeAt(index);
                                              });
                                            }else if(msg == "userBlock"){
                                              for(int i=0;i<posts.length; i++){
                                                if(posts[i].userId == post.userId){
                                                  posts.removeAt(i);
                                                  i--;
                                                }
                                              }
                                              setState(() {

                                              });
                                            }
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
                              : Padding(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: Get.height*0.02),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        replySortedIndex = 0;
                                        initGameReplies();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: replySortedIndex == 0 ? ColorConstants.white : ColorConstants.white10Percent,
                                            borderRadius: BorderRadius.circular(4)),
                                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                        child: Center(
                                          child: AppText(
                                              text: "TOP",
                                              fontSize: 14,
                                              textAlign: TextAlign.center,
                                              color: replySortedIndex == 0 ? ColorConstants.black : ColorConstants.halfWhite,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: Get.width*0.02),
                                    GestureDetector(
                                      onTap: (){
                                        replySortedIndex = 1;
                                        initGameReplies();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: replySortedIndex == 1 ? ColorConstants.white : ColorConstants.white10Percent,
                                            borderRadius: BorderRadius.circular(4)),
                                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                        child: Center(
                                          child: AppText(
                                              text: "recent".tr(),
                                              fontSize: 14,
                                              textAlign: TextAlign.center,
                                              color: replySortedIndex == 1 ? ColorConstants.black : ColorConstants.halfWhite,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 15,),
                                FutureBuilder(
                                    future: replyFuture,
                                    builder: (context, snapShot) {
                                      if(snapShot.hasData){
                                        if(replies.length == 0){
                                          return Padding(
                                            padding: EdgeInsets.only(top: 50,bottom: 50),
                                            child: Center(
                                              child: AppText(
                                                text: "empty_comment".tr(),
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
                                                return ReplyWidget(key: key, isGameComment: true, reply: replies[index], onTapChild: (parentReply){
                                                  Get.to(GameDetailReplyScreen(game: game, parentReply: parentReply, refreshReply: (reply){
                                                    setState(() {
                                                      replies[index] = reply;
                                                    });
                                                  }, deleteParentReply: (){
                                                    setState(() {
                                                      game.commentCount -= 1;
                                                      replies.removeAt(index);
                                                    });
                                                  },));
                                                },onDelete:(){
                                                  setState(() {
                                                    game.commentCount -= 1;
                                                    replies.removeAt(index);
                                                  });
                                                }, onEditReply: (){
                                                  setState(() {
                                                    replyText.value = replies[index].content;
                                                    mentionController.text = replies[index].content;
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
                                          padding: EdgeInsets.only(top: 50,bottom: 50),
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

                (_selectedIndex==0)?
                SizedBox() :
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
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(color: ColorConstants.backGry,
                                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
                              child: Row(
                                children:[
                                  SizedBox(
                                    width: Get.width * 0.025,
                                  ),
                                  Flexible(
                                      child: MentionableTextField(
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
                                      )
                                  )
                                ],
                              ),
                            ),
                          ),
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
                                  for(int i=0;i<replies.length;i++) {
                                    if(replies[i].id == result.id) {
                                      replies[i] = result;
                                      break;
                                    }
                                  }
                                });
                                Utils.showToast("comment_edited".tr());
                              }else {
                                var response = await DioClient.sendGameComment(
                                    game.id, replyContent, null);
                                ReplyModel result = ReplyModel.fromJson(response.data["result"]);

                                setState(() {
                                  replies.insert(0, result);
                                  game.commentCount += 1;
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