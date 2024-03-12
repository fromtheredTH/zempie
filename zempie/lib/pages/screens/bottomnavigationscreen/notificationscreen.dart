import 'dart:convert';

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/AttatchmentFile.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/NotificationWidget.dart';
import 'package:app/pages/components/UserListItemWidget.dart';
import 'package:app/pages/components/loading_widget.dart';
import 'package:app/pages/components/post_widget.dart';
import 'package:app/pages/screens/newPostScreen.dart';
import 'package:app/pages/screens/profile/profile_edit_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../models/NotificationModel.dart';
import '../../../models/PostModel.dart';
import '../../base/base_state.dart';
import '../../components/CutomTitleBar.dart';
import '../../components/app_text.dart';
import '../../components/fucus_detector.dart';
import '../profile/profile_screen.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreen();
}

class _NotificationScreen extends BaseState<NotificationScreen> {

  List<NotificationModel> unReadLists = [];
  List<NotificationModel> todayLists = [];
  List<NotificationModel> weekLists = [];
  List<NotificationModel> monthLists = [];
  List<NotificationModel> previousLists = [];

  @override
  void initState() {
    super.initState();
  }

  void changeUesrFollowing(int userId){
    setState(() {
      for(int i=0;i<unReadLists.length;i++){
        if(unReadLists[i].user.id == userId){
          unReadLists[i].user.isFollowing = true;
        }
      }

      for(int i=0;i<todayLists.length;i++){
        if(todayLists[i].user.id == userId){
          todayLists[i].user.isFollowing = true;
        }
      }

      for(int i=0;i<weekLists.length;i++){
        if(weekLists[i].user.id == userId){
          weekLists[i].user.isFollowing = true;
        }
      }

      for(int i=0;i<monthLists.length;i++){
        if(monthLists[i].user.id == userId){
          monthLists[i].user.isFollowing = true;
        }
      }

      for(int i=0;i<previousLists.length;i++){
        if(previousLists[i].user.id == userId){
          previousLists[i].user.isFollowing = true;
        }
      }
    });
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
      onFocusGained: () async {
        DateTime now = DateTime.now();
        unReadLists.clear();
        todayLists.clear();
        weekLists.clear();
        monthLists.clear();
        previousLists.clear();
        await DioClient.alramRead();
        for(int i=0; i<Constants.notifications.length;i++){
          if(!Constants.notifications[i].isRead){
            Constants.notifications[i].isRead = true;
            unReadLists.add(Constants.notifications[i]);
          }else {
            DateTime createdAt = DateTime.parse(
                Constants.notifications[i].createdAt);
            int inDays = now.difference(createdAt).inDays;
            if(inDays < 1){
              todayLists.add(Constants.notifications[i]);
            }else if(inDays < 7){
              weekLists.add(Constants.notifications[i]);
            }else if(inDays < 30){
              monthLists.add(Constants.notifications[i]);
            }else{
              previousLists.add(Constants.notifications[i]);
            }
          }
        }
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
              SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    AppText(
                        text: "알림",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),

                    SizedBox(height: 12,),

                    Container(
                      height: 0.5,
                      color: ColorConstants.halfWhite,
                    )
                  ],
                ),
              ),

              SizedBox(height: 15),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      if(unReadLists.length != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                              child: AppText(
                                text: "읽지 않음",
                                fontSize: 14,
                              ),
                            ),
                            ListView.builder(
                                itemCount:  unReadLists.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context,index){
                                  Key key = Key(unReadLists[index].id.toString());
                                  return  Column(
                                    children: [
                                      SwipeActionCell(
                                        key: key,
                                        backgroundColor: ColorConstants.colorBg1,
                                        child: NotificationWidget(notification: unReadLists[index], deleteNotification: (){

                                        }, userFollowing: (){
                                          changeUesrFollowing(unReadLists[index].user.id);
                                        },),
                                        trailingActions: [
                                          SwipeAction(
                                              content: Center(
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffeb5757),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: ImageUtils.setImage(ImageConstants.deleteIcon, 30, 30),
                                                ),
                                              ),
                                              color: Colors.transparent,
                                              onTap: (handler) {
                                                showDeleteAlert(unReadLists[index], () async {
                                                  var response = await DioClient.deleteNotification(unReadLists[index].id);
                                                  setState(() {
                                                    unReadLists.removeAt(index);
                                                  });
                                                });
                                              }),
                                        ],
                                      ),

                                      SizedBox(height: 15,),
                                    ],
                                  );
                                }),

                            SizedBox(height: 10,),
                          ],
                        ),

                      if(todayLists.length != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                              child: AppText(
                                text: "오늘",
                                fontSize: 14,
                              ),
                            ),
                            ListView.builder(
                                itemCount:  todayLists.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context,index){
                                  Key key = Key(todayLists[index].id.toString());
                                  return  Column(
                                    children: [
                                      SwipeActionCell(
                                        key: key,
                                        backgroundColor: ColorConstants.colorBg1,
                                        child: NotificationWidget(notification: todayLists[index], deleteNotification: (){

                                        },userFollowing: (){
                                          changeUesrFollowing(todayLists[index].user.id);
                                        },),
                                        trailingActions: [
                                          SwipeAction(
                                              content: Center(
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffeb5757),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: ImageUtils.setImage(ImageConstants.deleteIcon, 30, 30),
                                                ),
                                              ),
                                              color: Colors.transparent,
                                              onTap: (handler) {
                                                showDeleteAlert(todayLists[index], () async {
                                                  var response = await DioClient.deleteNotification(todayLists[index].id);
                                                  setState(() {
                                                    todayLists.removeAt(index);
                                                  });
                                                });
                                              }),
                                        ],
                                      ),

                                      SizedBox(height: 15,),
                                    ],
                                  );
                                }),

                            SizedBox(height: 10,),
                          ],
                        ),

                      if(weekLists.length != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                              child: AppText(
                                text: "최근 7일",
                                fontSize: 14,
                              ),
                            ),
                            ListView.builder(
                                itemCount:  weekLists.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context,index){
                                  Key key = Key(weekLists[index].id.toString());
                                  return  Column(
                                    children: [
                                      SwipeActionCell(
                                        key: key,
                                        backgroundColor: ColorConstants.colorBg1,
                                        child: NotificationWidget(notification: weekLists[index], deleteNotification: (){

                                        },userFollowing: (){
                                          changeUesrFollowing(weekLists[index].user.id);
                                        },),
                                        trailingActions: [
                                          SwipeAction(
                                              content: Center(
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffeb5757),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: ImageUtils.setImage(ImageConstants.deleteIcon, 30, 30),
                                                ),
                                              ),
                                              color: Colors.transparent,
                                              onTap: (handler) {
                                                showDeleteAlert(weekLists[index], () async {
                                                  var response = await DioClient.deleteNotification(weekLists[index].id);
                                                  setState(() {
                                                    weekLists.removeAt(index);
                                                  });
                                                });
                                              }),
                                        ],
                                      ),

                                      SizedBox(height: 15,),
                                    ],
                                  );
                                }),

                            SizedBox(height: 10,),
                          ],
                        ),

                      if(monthLists.length != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                              child: AppText(
                                text: "최근 30일",
                                fontSize: 14,
                              ),
                            ),
                            ListView.builder(
                                itemCount:  monthLists.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context,index){
                                  Key key = Key(monthLists[index].id.toString());
                                  return  Column(
                                    children: [
                                      SwipeActionCell(
                                        key: key,
                                        backgroundColor: ColorConstants.colorBg1,
                                        child: NotificationWidget(notification: monthLists[index], deleteNotification: (){

                                        },userFollowing: (){
                                          changeUesrFollowing(monthLists[index].user.id);
                                        },),
                                        trailingActions: [
                                          SwipeAction(
                                              content: Center(
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffeb5757),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: ImageUtils.setImage(ImageConstants.deleteIcon, 30, 30),
                                                ),
                                              ),
                                              color: Colors.transparent,
                                              onTap: (handler) {
                                                showDeleteAlert(monthLists[index], () async {
                                                  var response = await DioClient.deleteNotification(monthLists[index].id);
                                                  setState(() {
                                                    monthLists.removeAt(index);
                                                  });
                                                });
                                              }),
                                        ],
                                      ),

                                      SizedBox(height: 15,),
                                    ],
                                  );
                                }),

                            SizedBox(height: 10,),
                          ],
                        ),

                      if(previousLists.length != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                              child: AppText(
                                text: "이전 활동",
                                fontSize: 14,
                              ),
                            ),
                            ListView.builder(
                                itemCount:  previousLists.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context,index){
                                  Key key = Key(previousLists[index].id.toString());
                                  return  Column(
                                    children: [
                                      SwipeActionCell(
                                        key: key,
                                        backgroundColor: ColorConstants.colorBg1,
                                        child: NotificationWidget(notification: previousLists[index], deleteNotification: (){

                                        },userFollowing: (){
                                          changeUesrFollowing(previousLists[index].user.id);
                                        },),
                                        trailingActions: [
                                          SwipeAction(
                                              content: Center(
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffeb5757),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: ImageUtils.setImage(ImageConstants.deleteIcon, 30, 30),
                                                ),
                                              ),
                                              color: Colors.transparent,
                                              onTap: (handler) {
                                                showDeleteAlert(previousLists[index], () async {
                                                  var response = await DioClient.deleteNotification(previousLists[index].id);
                                                  setState(() {
                                                    previousLists.removeAt(index);
                                                  });
                                                });
                                              }),
                                        ],
                                      ),

                                      SizedBox(height: 15,),
                                    ],
                                  );
                                }),

                            SizedBox(height: 10,),
                          ],
                        ),

                      SizedBox(height: 20,),
                    ],
                  ),
                )
              ),
              SizedBox(height: Get.height*0.03),
            ],
          ),
        ),
      ),
    );
  }

  void showDeleteAlert(NotificationModel notification, Function() onTapDelete){
    showDialog(
      context: context,
      barrierDismissible: true,
      //바깥 영역 터치시 닫을지 여부 결정
      builder: ((context) {
        return Dialog(
          backgroundColor: ColorConstants
              .colorBg1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius
                  .circular(16)
          ),
          child: Container(
            width: Get.width * 0.6,
            height: Get.width * 0.5,
            padding: EdgeInsets.only(
                left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .center,
              children: [
                SizedBox(height: 15,),

                AppText(
                  text: "알림 내역 삭제",
                  fontSize: 18,
                  fontWeight: FontWeight
                      .w700,
                ),

                SizedBox(height: 10,),

                Container(
                  width: double
                      .maxFinite,
                  height: 0.5,
                  color: ColorConstants
                      .halfWhite,
                ),

                SizedBox(height: 30,),

                AppText(
                  text: "알림 내역을 삭제하시겠습니까?",
                  fontSize: 16,
                ),

                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: GestureDetector(
                            onTap: (){
                              Get.back();
                            },
                            child: Container(
                                height: 40,
                                margin: EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: ColorConstants.textGry
                                ),
                                child: Center(
                                  child: AppText(
                                    text: "취소",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,),
                                )
                            ),
                          )
                      ),
                      Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              Get.back();
                              onTapDelete();
                            },
                            child: Container(
                                height: 40,
                                margin: EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: ColorConstants.colorMain
                                ),
                                child: Center(
                                  child: AppText(text: "확인",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700
                                  ),
                                )
                            ),
                          )
                      )

                    ],
                  ),
                ),

                SizedBox(height: 20,)

              ],
            ),
          ),
        );
      }),
    );
  }
}
