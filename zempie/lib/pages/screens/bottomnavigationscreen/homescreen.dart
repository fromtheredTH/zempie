import 'dart:convert';

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/AttatchmentFile.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/loading_widget.dart';
import 'package:app/pages/components/post_widget.dart';
import 'package:app/pages/screens/communityScreens/nicknameScreen.dart';
import 'package:app/pages/screens/newPostScreen.dart';
import 'package:app/pages/screens/profile/profile_edit_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../models/PostModel.dart';
import '../../base/base_state.dart';
import '../../components/CutomTitleBar.dart';
import '../../components/app_text.dart';
import '../../components/fucus_detector.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> {

   RxInt activePage=0.obs;

   late Future postFuture;
   late List<PostModel> posts;

   int timerLoadingCnt = 0;
   bool isRandomPosting = false;
   bool hasFollowingNextPage = false;
   int followingPage = 0;
   bool hasDiscoverNextPage = false;
   int discoverPage = 0;
   bool hasRandomNextPage = false;
   int randomPage = 0;

   ScrollController scrollController = ScrollController();

   Future<List<PostModel>> initPosts() async {
     List<PostModel> results = Constants.timelinePosts;
     if(results.isEmpty){
       var randomResponse = await DioClient.getRandomPostings(10, 0);
       posts = randomResponse.data["result"] == null ? [] : randomResponse.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
       isRandomPosting = true;
       randomPage += 1;
       hasRandomNextPage = randomResponse.data["pageInfo"]?["hasNextPage"] ?? false;
     }else{
       followingPage += 1;
       hasFollowingNextPage = Constants.initTimelineHasNextPage;
       var disCoverResults = await DioClient.getDiscoverTimelinePostings(5, 0);
       List<PostModel> discoverResults = disCoverResults.data["result"] == null ? [] : disCoverResults.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
       discoverPage += 1;
       hasDiscoverNextPage = disCoverResults.data["pageInfo"]?["hasNextPage"] ?? false;
       posts = [];
       isRandomPosting = false;
       for(int i=0;i<5;i++){
         if(results.length > i) {
           posts.add(results[i]);
         }
         if(discoverResults.length > i) {
           posts.add(discoverResults[i]);
         }
       }
     }
     return posts;
   }

   Future<void> getNextPage() async {
     if(scrollController.position.extentAfter < 200 && !isLoading) {
       isLoading = true;
       if(isRandomPosting){
         var randomResponse = await DioClient.getRandomPostings(10, randomPage);
         List<PostModel> results = randomResponse.data["result"] == null ? [] : randomResponse.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
         isRandomPosting = true;
         randomPage += 1;
         hasRandomNextPage = randomResponse.data["pageInfo"]?["hasNextPage"] ?? false;
         isLoading = false;
         setState(() {
           posts.addAll(results);
         });
       }else{
         List<PostModel> results = [];
         if(hasFollowingNextPage) {
           var response = await DioClient.getFollowingPostings(5, followingPage);
           results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
           followingPage += 1;
           hasFollowingNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
         }
         List<PostModel> discoverResults = [];
         if(hasDiscoverNextPage){
           var discoverResponse = await DioClient.getDiscoverTimelinePostings(5, discoverPage);
           discoverResults = discoverResponse.data["result"] == null ? [] : discoverResponse.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
           discoverPage += 1;
           hasDiscoverNextPage = discoverResponse.data["pageInfo"]?["hasNextPage"] ?? false;
         }

         for(int i=0;i<5;i++){
           if(results.length > i) {
             posts.add(results[i]);
           }
           if(discoverResults.length > i) {
             posts.add(discoverResults[i]);
           }
         }
         isLoading = false;
         setState(() {

         });

         print("추가됨");
         getThreeTimelines();
       }

     }
   }

   Future<void> getRandomPosts() async {
     var randomResponse = await DioClient.getRandomPostings(10, randomPage);
     List<PostModel> results = randomResponse.data["result"] == null ? [] : randomResponse.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
     isRandomPosting = true;
     randomPage += 1;
     hasRandomNextPage = randomResponse.data["pageInfo"]?["hasNextPage"] ?? false;
     setState(() {
       posts.addAll(results);
     });
   }

   Future<void> getTimerNextPage() async {
     var response = await DioClient.getFollowingPostings(5, followingPage);
     List<PostModel> results = response.data["result"] == null ? [] : response.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
     followingPage += 1;
     hasFollowingNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
     var disCoverResults = await DioClient.getDiscoverTimelinePostings(5, discoverPage);
     List<PostModel> discoverResults = disCoverResults.data["result"] == null ? [] : disCoverResults.data["result"].map((json) => PostModel.fromJson(json)).toList().cast<PostModel>();
     discoverPage += 1;
     hasDiscoverNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
     isRandomPosting = false;
     for(int i=0;i<5;i++){
       if(results.length > i) {
         posts.add(results[i]);
       }
       if(discoverResults.length > i) {
         posts.add(discoverResults[i]);
       }
     }
     setState(() {

     });
     print("추가됨 2");
   }

   Future<void> getThreeTimelines() async {
     await getTimerNextPage();
     await getTimerNextPage();
     await getTimerNextPage();
   }

   @override
  void initState() {
    postFuture = initPosts();
    super.initState();
    scrollController.addListener(getNextPage);
    getThreeTimelines();
  }

  @override
  void dispose() {
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusLost: () {

      },
      onFocusGained: () {
        setState(() {

        });
      },
      child: PageLayout(
        child: Scaffold(
          backgroundColor: ColorConstants.colorBg1,
          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: CustomTitleBar(callBack: (){
                    Get.to(ProfileScreen(user: Constants.user,));
                  },)),
              SizedBox(height: Get.height*0.01),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    GestureDetector(
                      onTap: (){
                        // Get.to(ProfileScreen(user: Constants.user));
                        Get.to(NicknameScreen());
                      },
                      child: ImageUtils.ProfileImage(Constants.user.picture, 40, 40),
                    ),
                    SizedBox(width: Get.width*0.03),
                    SizedBox(
                      width: Get.width*0.8,
                      child: GestureDetector(
                        onTap: (){
                          Get.to(NewPostScreen(uploadedPost: (post){
                            setState(() {
                              posts.insert(0, post);
                            });
                          },));
                        },
                        child: TextFormField(
                          autofocus: false,
                          readOnly: true,
                          showCursor: false,
                          style: TextStyle(fontSize: 15.0,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w400,
                            color: ColorConstants.white,
                          ),
                          onTap: (){
                            Get.to(NewPostScreen(uploadedPost: (post){
                              setState(() {
                                posts.insert(0, post);
                              });
                            },));
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ColorConstants.textFieldBackground,
                            hintText: 'What’s on your mind?',
                            hintStyle: TextStyle(color:ColorConstants.white),
                            border: InputBorder.none,

                            contentPadding:
                            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorConstants.white),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ColorConstants.textFieldBackground),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: FutureBuilder(
                    future: postFuture,
                    builder: (context, snapShot) {
                      if(snapShot.hasData) {
                        return MediaQuery.removePadding(
                            removeTop: true,
                            removeRight: true,
                            removeLeft: true,
                            removeBottom: true,
                            context: context,
                            child: RefreshIndicator(
                              onRefresh: () async {
                                await initPosts();
                                setState(() {

                                });
                              },
                              child: ListView.builder(
                                  itemCount: !isRandomPosting
                                      ? hasFollowingNextPage ||
                                      hasDiscoverNextPage
                                      ? posts.length + 1
                                      : posts.length
                                      : hasRandomNextPage
                                      ? posts.length + 1
                                      : posts.length,
                                  shrinkWrap: true,
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    if (posts.length == index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: 30, bottom: 50),
                                        child: LoadingWidget(),
                                      );
                                    }
                                    Key key = Key(posts[index].id);
                                    return PostWidget(key: key, post: posts[index], onPostDeleteAction: (post, msg){
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
                            )
                        );
                      }
                      return LoadingWidget();
                    }
                ),
              ),
              SizedBox(height: Get.height*0.03),
            ],
          ),
        ),
      ),
    );
  }
}
