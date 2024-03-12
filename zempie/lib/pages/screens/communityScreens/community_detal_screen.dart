import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';
import '../../../global/DioClient.dart';
import '../../../models/CommunityModel.dart';
import '../../../models/PostModel.dart';
import '../../../models/res/btn_bottom_sheet_model.dart';
import '../../components/BtnBottomSheetWidget.dart';
import '../../components/app_text.dart';
import '../../components/loading_widget.dart';
import '../../components/post_widget.dart';
import '../newPostScreen.dart';
import '../profile/profile_screen.dart';
import 'memberScreen.dart';
import '../../base/base_state.dart';

class CommunityDetailScreen extends StatefulWidget {
   bool? showFill;
   CommunityModel community;
   Function(CommunityModel) refreshCommunity;
   CommunityDetailScreen({Key? key,this.showFill, required this.community, required this.refreshCommunity}) : super(key: key);

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreen();
}

class _CommunityDetailScreen extends BaseState<CommunityDetailScreen> {

   late CommunityModel community;
   RxInt selectedChannel = 0.obs;

  late Future postFuture;
  List<PostModel> posts = [];

  ScrollController postScrollController = ScrollController();
  bool hasPostNextPage = false;
  int postPage = 0;
  bool isLoading = false;
  bool isInit = false;

   Future<List<PostModel>> initCommunityChannelTimelines() async {
     if(!isInit) {
       var deetailResponse = await DioClient.getCommunityDetail(community.id);
       CommunityModel result = CommunityModel.fromJson(deetailResponse.data);
       setState(() {
         community = result;
         widget.refreshCommunity(community);
       });
       isInit = true;
     }
     var response = await DioClient.getCommunityChannelTimelines(community.id, community.channels[selectedChannel.value].id, 10, 0);
     List<PostModel> results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
     postPage = 1;
     hasPostNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
     setState(() {
       posts = results;
     });
     return posts;
   }

   Future<void> getPostNextPage() async {
     if (!isLoading && postScrollController.position.extentAfter < 200 && hasPostNextPage) {
       isLoading = true;
       var response = await DioClient.getCommunityChannelTimelines(community.id, community.channels[selectedChannel.value].id, 10, postPage);
       List<PostModel> postResults = response.data["result"] == null ? [] : response
           .data["result"].map((json) => PostModel.fromJson(json)).toList().cast<
           PostModel>();
       postPage += 1;
       hasPostNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
       setState(() {
         posts.addAll(postResults);
       });
       isLoading = true;
     }
   }

  Future<void> getCommunityDetail() async {
    var response = await DioClient.getCommunityDetail(community.id);
    CommunityModel result = CommunityModel.fromJson(response.data);
    setState(() {
      community = result;
      widget.refreshCommunity(community);
    });
  }
   
   @override
  void initState() {
    community = widget.community;
    postFuture = initCommunityChannelTimelines();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: Get.height * 0.06,
                left: Get.width * 0.05,
                right: Get.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                      text: community.name,
                      fontSize: 0.02,
                      color: Colors.white,
                      fontFamily: FontConstants.AppFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: (){
                    List<BtnBottomSheetModel> items = [];
                    if(community.isSubscribed) {
                      items.add(BtnBottomSheetModel(
                          ImageConstants.unSubscribe, "팔로우 취소", 0));

                      Get.bottomSheet(BtnBottomSheetWidget(
                          btnItems: items, onTapItem: (menuIndex) async {
                        if (menuIndex == 0) {
                          await DioClient.getCommunityUnSubscribe(community.id);
                          Constants.removeCommunityFollow(community.id);
                          getCommunityDetail();
                        }
                      }));
                    }
                  },
                  child: SvgPicture.asset(ImageConstants.dotsThree),
                )
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 15,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ImageUtils.setCommunityListNetworkImage(community.bannerImg),
                            Padding(
                              padding:  EdgeInsets.only(top: Get.width/2.55 - 32),
                              child: Center(child: ImageUtils.ProfileImage(community.profileImg, 64, 64)),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: (){
                            // Get.to(ZemTalkScreen());
                          },
                          child: Row(
                            children: [
                              AppText(
                                text: community.name,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              SizedBox(
                                width: Get.width * 0.02,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: Get.height*0.015,
                              ),


                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: (){

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: AppText(
                                    text: community.description,
                                    fontSize: 12,
                                    maxLine: 1,
                                    color: Colors.white70,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ),
                              SizedBox(width: 10,),

                              GestureDetector(
                                onTap: (){
                                  Get.to(MemberScreen(community: community,));
                                },
                                child: Row(
                                  children: [
                                    Image.asset(ImageConstants.users,height: Get.height*0.02,),
                                    SizedBox(
                                      width: Get.width * 0.01,
                                    ),
                                    AppText(
                                      text: "${community.memberCnt}",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ],
                                ),
                              )

                            ],
                          ),
                        ),

                        SizedBox(height: 15,),

                        community.isSubscribed ?
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
                                    }, firstChannel: community.channels[selectedChannel.value],));
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
                        ) :
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if(community.isSubscribed){
                                  await DioClient.getCommunityUnSubscribe(community.id);
                                  Constants.removeCommunityFollow(community.id);
                                  getCommunityDetail();
                                  Utils.showToast("가입취소가 완료되었습니다.");
                                }else{
                                  await DioClient.getCommunitySubscribe(community.id);
                                  Constants.addCommunityFollow(community);
                                  getCommunityDetail();
                                  Utils.showToast("가입이 완료되었습니다.");
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: ColorConstants.yellow,
                                ),
                                child:  Center(
                                  child: AppText(
                                      text: "가입하기",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            AppText(
                                text: "커뮤니티에 가입하신 후 포스트 작성이 가능합니다.",
                                fontSize: 12,
                                color: ColorConstants.halfWhite,
                                textAlign: TextAlign.start,
                            ),
                          ],
                        ),

                        SizedBox(height: 5),

                        if(community.channels.length != 0)
                        Container(
                          height: 35,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(top: 15),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: community.channels.length,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap:(){
                                      selectedChannel.value = index;
                                      initCommunityChannelTimelines();
                                    },
                                    child:
                                    Obx(() =>
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: Get.width * 0.01),
                                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: selectedChannel == index ? ColorConstants.yellow : ColorConstants.colorBg1,
                                              border: Border.all(color: ColorConstants.yellow)
                                          ),
                                          child: Center(
                                            child: AppText(
                                              maxLine: 1,
                                              text: community.channels[index].title,
                                              fontSize: 0.014,
                                              color: selectedChannel == index ? ColorConstants.white : ColorConstants.yellow,
                                              fontFamily: FontConstants.AppFont,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )),
                                  ),

                                ],
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),



                  SizedBox(height: Get.height*0.02,),

                  FutureBuilder(
                      future: postFuture,
                      builder: (context, snapShot) {
                        if(snapShot.hasData){
                          if(posts.length == 0){
                            return Padding(
                              padding: EdgeInsets.only(top: 50,bottom: 50),
                              child: Center(
                                child: AppText(
                                  text: "포스팅이 없습니다",
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
                                itemCount: hasPostNextPage ? posts.length+1 : posts.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context,index){
                                  if(posts.length == index){
                                    return Padding(
                                      padding: EdgeInsets.only(top: 30, bottom: 50),
                                      child: LoadingWidget(),
                                    );
                                  }
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
class OptionModel{
  String? title;
  RxBool? isSelect=false.obs;
  OptionModel({this.title,this.isSelect});
}