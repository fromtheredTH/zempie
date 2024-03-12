import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../components/app_text.dart';
import '../../base/base_state.dart';

class NicknameScreen extends StatefulWidget {
   NicknameScreen({Key? key}) : super(key: key);

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends BaseState<NicknameScreen> {


  final List<String> imgList = [
    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
    'https://images.pexels.com/photos/19254156/pexels-photo-19254156/free-photo-of-dock.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/20179666/pexels-photo-20179666/free-photo-of-miracle-experience-balloon-safaris-at-serengeti-and-tarangire-national-park.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/20184491/pexels-photo-20184491/free-photo-of-mountain.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
  ];

  int _current=0;


  int? _selectedIndex=0;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: Get.height * 0.06,
                  left: Get.width * 0.05,
                  right: Get.width * 0.05),
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
                    text: "닉네임",
                    fontSize:16,
                    color: Colors.white,
                    fontFamily: FontConstants.AppFont,
                    fontWeight: FontWeight.w700,
                  ),

                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: Get.height * 0.02,
                  left: Get.width * 0.05,
                  right: Get.width * 0.05),
              child: Image.asset(ImageConstants.bgBlock,height: Get.height*0.15,
              fit: BoxFit.fill,
              width: Get.width,),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: Get.height * 0.02,
                  left: Get.width * 0.05,
                  right: Get.width * 0.05),
              child: Row(

                children: [
                  Image.asset(ImageConstants.avatarBlock,height: Get.height*0.06,),
                  SizedBox(width: Get.width*0.02,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "닉네임",
                        fontSize: 0.018,
                        color: Colors.white,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: Get.height*0.003,),
                      Row(
                        children: [
                          AppText(
                            text: "@아이디",
                            fontSize: 0.016,
                            color: ColorConstants.gray3,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(width: Get.width*0.01,),
                          Container(
                            width: Get.width*0.15,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: ColorConstants.skyBlueColor,
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: Center(
                              child: AppText(
                                text: "CREATOR",
                                fontSize: 0.01,
                                color: Colors.black,
                                fontFamily: FontConstants.AppFont,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Get.height*0.003,),

                      SizedBox(
                        width: Get.width*0.75,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                AppText(
                                  text: "78",
                                  fontSize: 0.018,
                                  color: Colors.white,
                                  fontFamily: FontConstants.AppFont,
                                  fontWeight: FontWeight.w700,
                                ),
                                SizedBox(width: Get.width*0.01,),
                                AppText(
                                  text: "팔로잉",
                                  fontSize: 0.014,
                                  color: ColorConstants.gray3,
                                  fontFamily: FontConstants.AppFont,
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(width: Get.width*0.02,),
                                Container(height: Get.height*0.015,
                                width: 1,
                                  decoration: BoxDecoration(
                                    color: ColorConstants.gray3
                                  ),
                                ),
                                SizedBox(width: Get.width*0.02,),

                                AppText(
                                  text: "2,345",
                                  fontSize: 0.018,
                                  color: Colors.white,
                                  fontFamily: FontConstants.AppFont,
                                  fontWeight: FontWeight.w700,
                                ),
                                SizedBox(width: Get.width*0.01,),
                                AppText(
                                  text: "팔로워",
                                  fontSize: 0.014,
                                  color: ColorConstants.gray3,
                                  fontFamily: FontConstants.AppFont,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),

                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(padding:   EdgeInsets.only(
                    top: Get.height * 0.02,
                    left: Get.width * 0.05,
                    right: Get.width * 0.05),
              child: Column(
                children: [

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,color: ColorConstants.gryIcon,size: Get.height*0.025,),
                      SizedBox(width: Get.width*0.014,),
                      AppText(
                        text: "대한민국 서울",
                        fontSize: 0.018,
                        color: Colors.white,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  SizedBox(height: Get.height*0.003,),
                  Row(
                    children: [
                      Image.asset(ImageConstants.building,height: Get.height*0.02,),
                      // Icon(Icons.w,color: ColorConstants.gray3,size: Get.height*0.025,),
                      SizedBox(width: Get.width*0.014,),
                      AppText(
                        text: "(주)더프롬더레드 재직중",
                        fontSize: 0.018,
                        color: Colors.white,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  SizedBox(height: Get.height*0.003,),
                  Row(
                    children: [
                      Image.asset(ImageConstants.msg,height: Get.height*0.02,),
                      // Icon(Icons.w,color: ColorConstants.gray3,size: Get.height*0.025,),
                      SizedBox(width: Get.width*0.014,),
                      AppText(
                        text: "뭔가 재미있는 컨텐츠가 없는지 열심히 찾는 중...",
                        fontSize: 0.018,
                        color: Colors.white,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  SizedBox(height: Get.height*0.003,),
                  Row(
                    children: [
                      Image.asset(ImageConstants.link,height: Get.height*0.02,),
                       //Icon(Icons.link,color: ColorConstants.gray3,size: Get.height*0.025,),
                      SizedBox(width: Get.width*0.014,),
                      AppText(
                        text: "basketball.papa",
                        fontSize: 0.018,
                        color: ColorConstants.linkIcon,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  SizedBox(height: Get.height*0.01,),
                  AppText(
                    text: "Risus bibendum iaculis Risus bibendum iaculis metusmetu bibendum bibendum iaculis metusmetu iaculis metus metus  amet... 더 보기",
                    fontSize: 0.018,
                    color: ColorConstants.white,
                    fontFamily: FontConstants.AppFont,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: Get.height*0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){

                        },
                        child: Container(
                          height: Get.height*0.05,
                          width: Get.width*0.44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),

                            color: ColorConstants.yellow
                          ),
                          child:  Center(
                            child: AppText(
                              text: "메시지 보내기",
                              fontSize: 0.018,
                              color: ColorConstants.white,
                              fontFamily: FontConstants.AppFont,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){

                        },
                        child: Container(
                          height: Get.height*0.05,
                          width: Get.width*0.44,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),

                              border: Border.all(color: ColorConstants.yellow),

                          ),
                          child:  Center(
                            child: AppText(
                              text: "+ 팔로우",
                              fontSize: 0.018,
                              color: ColorConstants.yellow,
                              fontFamily: FontConstants.AppFont,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Get.height*0.01,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //
                  //     Image.asset(ImageConstants.person1Png,height: Get.height*0.04,),
                  //     Container(
                  //       width: Get.width*0.8, // Set width according to your needs
                  //       decoration: BoxDecoration(
                  //         color: ColorConstants.searchBackColor,
                  //         borderRadius:
                  //         BorderRadius.circular(6.0), // Adjust the value as needed
                  //       ),
                  //       child: TextFormField(
                  //         decoration: InputDecoration(
                  //           hintText: 'What’s on your mind?',
                  //
                  //           contentPadding: EdgeInsets.symmetric(
                  //               horizontal: 16.0,
                  //               vertical: 12.0), // Adjust vertical padding
                  //           border: InputBorder.none,
                  //
                  //           // Align hintText to center
                  //           hintStyle: TextStyle(
                  //               fontWeight: FontWeight.w500,
                  //               color: Colors.white, fontSize: Get.height * 0.016),
                  //           alignLabelWithHint: true,
                  //         ),
                  //       ),
                  //     ),
                  //
                  //   ],
                  // )
                ],
              ),
            ),
            DefaultTabController(
              length: 3,

              child: TabBar(
                indicatorColor: ColorConstants.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2,
                labelColor: Colors.white,
                dividerColor: ColorConstants.tabDividerColor,
                unselectedLabelColor: ColorConstants.tabTextColor,
                labelStyle: TextStyle(
                    fontSize: Get.height * 0.018, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: '포스트 23'),
                  Tab(text: '게임 4'),
                  Tab(text: '커뮤니티 5'),

                ],
                onTap: (index) {

                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),

            ),


            SizedBox(height: Get.height*0.01,),
            // (_selectedIndex==0)?
            MediaQuery.removePadding(
              removeTop: true,
              removeRight: true,
              removeLeft: true,
              removeBottom: true,
              context: context,
              child:ListView.builder(
                  itemCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),

                  itemBuilder: (context,index){
                    return  Stack(
                      children: [
                        Container(child: Image.asset(ImageConstants.homeBg, height: Get.height*0.67, width: Get.width, fit: BoxFit.cover,)),
                        Padding(
                          padding: EdgeInsets.all(Get.height*0.022),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(

                                    children: [
                                      ClipOval(
                                        child: Container(
                                          width: Get.height*0.045,
                                          height: Get.height*0.045,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle
                                          ),
                                          child: Image.asset(
                                            ImageConstants.jennyWilson,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Get.width*0.03),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText(text: "Jenny Wilson", fontSize: 0.016 ,
                                              color: ColorConstants.white,
                                              textAlign: TextAlign.start,
                                              fontFamily: FontConstants.AppFont,
                                              fontWeight: FontWeight.w700),

                                          SizedBox(height: Get.height*0.005),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: (){

                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: ColorConstants.skyBlueColor,
                                                      borderRadius: BorderRadius.circular(4)),
                                                  height: Get.height * 0.02,
                                                  width: Get.width * 0.17,
                                                  child: AppText(text: "CREATOR", fontSize: 0.013,
                                                      textAlign: TextAlign.center,
                                                      color: ColorConstants.black,
                                                      fontFamily: FontConstants.AppFont,
                                                      fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                              SizedBox(width: Get.width*0.01),
                                              Container(
                                                height: Get.height * 0.02,
                                                width: Get.width * 0.08,
                                                decoration: BoxDecoration(
                                                    color: ColorConstants.purple,
                                                    borderRadius: BorderRadius.circular(4)),
                                                child: AppText(text: "DEV", fontSize: 0.013,
                                                    textAlign: TextAlign.center,
                                                    color: ColorConstants.white,
                                                    fontFamily: FontConstants.AppFont,
                                                    fontWeight: FontWeight.w700),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: Get.height*0.005),
                                          AppText(
                                              text: "2024-01-13 10:30", fontSize: 0.015,
                                              textAlign: TextAlign.center,
                                              color: ColorConstants.gray3,
                                              fontFamily: FontConstants.AppFont,
                                              fontWeight: FontWeight.w400),
                                        ],


                                      ),
                                    ],
                                  ),
                                  SvgPicture.asset(ImageConstants.moreIcon),



                                  /*PageView.builder(
                   itemCount: imgList.length,
                   pageSnapping: true,

                   onPageChanged: (page) {
                   activePage.value = page;

                   },
                   itemBuilder: (context, pagePosition) {
                   return Container(
                   margin: EdgeInsets.all(10),
                   child: Image.network(imgList[pagePosition]),
                   );
                   }),*/

                                ],
                              ),
                              SizedBox(height: Get.height*0.005),
                              Stack(
                                children: [
                                  CarouselSlider(
                                    items: imgList.map((url) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(url),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    options: CarouselOptions(

                                      height: Get.height*0.24,
                                      autoPlay: false,
                                      viewportFraction: 1,
                                      autoPlayCurve: Curves.easeInOut,
                                      autoPlayAnimationDuration: Duration(milliseconds: 500),
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
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      child: Text(
                                        '${_current + 1}/${imgList.length}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Get.height*0.015,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // CarouselSlider(
                              //   items: [
                              //     Container(
                              //       decoration: BoxDecoration(
                              //         image: DecorationImage(
                              //           image: NetworkImage(imgList[index]),
                              //           fit: BoxFit.cover,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              //   options: CarouselOptions(
                              //     enlargeCenterPage: true,
                              //     // autoPlay: true,
                              //     // aspectRatio: 16 / 3,
                              //     // autoPlayCurve: Curves.fastOutSlowIn,
                              //     enableInfiniteScroll: true,
                              //     // autoPlayAnimationDuration: Duration(milliseconds: 800),
                              //     viewportFraction: 1,
                              //     // Set the desired options for the carousel
                              //     height: 200, // Set the height of the carousel
                              //     autoPlay: false, // Enable auto-play
                              //     autoPlayCurve: Curves.easeInOut, // Set the auto-play curve
                              //     autoPlayAnimationDuration: Duration(milliseconds: 500), // Set the auto-play animation duration
                              //     // Set the aspect ratio of each item
                              //     // You can also customize other options such as enlargeCenterPage, enableInfiniteScroll, etc.
                              //   ),
                              // ),
                              SizedBox(height: Get.height*0.01),
                              Container(
                                width: Get.width,
                                decoration: BoxDecoration(
                                    color: ColorConstants.darkGrey,
                                    borderRadius: BorderRadius.circular(5.0)),
                                padding: EdgeInsets.all(Get.height*0.015),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Lorem ipsum dolor sit amet consectetur. Egestas velit ut quam facilisi leo ',
                                            style: TextStyle(
                                              fontSize: 15, // Adjust the font size as needed
                                              fontFamily: FontConstants.AppFont, // Use your font family name here
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '@mattis',
                                            style: TextStyle(
                                              fontSize: 15, // Adjust the font size as needed
                                              fontFamily: FontConstants.AppFont, // Use your font family name here
                                              fontWeight: FontWeight.w400,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' tristique. Gravida ac aliquam ',
                                            style: TextStyle(
                                              fontSize: 15, // Adjust the font size as needed
                                              fontFamily: FontConstants.AppFont, // Use your font family name here
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '#euismod',
                                            style: TextStyle(
                                              fontSize: 15, // Adjust the font size as needed
                                              fontFamily: FontConstants.AppFont, // Use your font family name here
                                              fontWeight: FontWeight.w400,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' volutpat varius ut. Lacus massa id eros.... ',
                                            style: TextStyle(
                                              fontSize: 15, // Adjust the font size as needed
                                              fontFamily: FontConstants.AppFont, // Use your font family name here
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '더 보기',
                                            style: TextStyle(
                                              fontSize: 15, // Adjust the font size as needed
                                              fontFamily: FontConstants.AppFont, // Use your font family name here
                                              fontWeight: FontWeight.w400,
                                              color: ColorConstants.textDesGry,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // AppText(
                                    //     text: "Lorem ipsum dolor sit amet consectetur. Egestas velit ut quam facilisi leo @mattis tristique. Gravida ac aliquam #euismod volutpat varius ut. Lacus massa id eros.... 더 보기",
                                    //     fontSize: 0.015,
                                    //     fontFamily: FontConstants.AppFont,
                                    //     fontWeight: FontWeight.w400,
                                    //     color: ColorConstants.white),

                                    AppText(text: "번역보기",
                                        fontSize: 0.016,
                                        fontFamily: FontConstants.AppFont,
                                        fontWeight: FontWeight.w400,
                                        color: ColorConstants.skyBlueTextColor),



                                  ],
                                ),


                              ),
                              SizedBox(height: Get.height*0.01),
                              Row(
                                children: [
                                  Container(
                                    height: Get.height*0.038,
                                    width: Get.width*0.3,
                                    decoration: BoxDecoration(
                                        color: ColorConstants.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20.0)),
                                    padding: EdgeInsets.all(5.0),

                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // SizedBox(width: Get.width*0.01),
                                        SvgPicture.asset(ImageConstants.communityLogo,height: Get.height*0.02, width: Get.width*0.03),
                                        // SizedBox(width: Get.width*0.015),
                                        Center(
                                          child: AppText(text: "Community",
                                              fontSize: 0.014,
                                              fontFamily: FontConstants.AppFont,
                                              fontWeight: FontWeight.w400,
                                              color: ColorConstants.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: Get.width*0.01),
                                  Container(
                                    height: Get.height*0.038,
                                    width: Get.width*0.3,
                                    decoration: BoxDecoration(
                                        color: ColorConstants.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20.0)),
                                    padding: EdgeInsets.all(5.0),

                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // SizedBox(width: Get.width*0.01),
                                        SvgPicture.asset(ImageConstants.communityLogo, height: Get.height*0.02, width: Get.width*0.03),
                                        // SizedBox(width: Get.width*0.015),
                                        Center(
                                          child: AppText(text: "프롬더레드",
                                              fontSize: 0.015,
                                              fontFamily: FontConstants.AppFont,
                                              fontWeight: FontWeight.w400,
                                              color: ColorConstants.white),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(height: Get.height*0.01),
                              Row(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                                        child: Image.asset(ImageConstants.leagueOfLegends, width: Get.height*0.026, height: Get.height*0.026,),
                                      ),
                                      SizedBox(width: Get.width*0.015),
                                      Center(
                                        child: AppText(text: "League of legends",
                                            textAlign: TextAlign.center,
                                            fontSize: 0.016,
                                            fontFamily: FontConstants.AppFont,
                                            fontWeight: FontWeight.w700,
                                            color: ColorConstants.white),
                                      ),
                                    ],
                                  ),


                                ],
                              ),
                              SizedBox(height: Get.height*0.015),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(ImageConstants.heart),
                                      SizedBox(width: Get.width*0.015),
                                      AppText(text: "150",
                                          textAlign: TextAlign.center,
                                          fontSize: 0.016,
                                          fontFamily: FontConstants.AppFont,
                                          fontWeight: FontWeight.w700,
                                          color: ColorConstants.white),
                                      SizedBox(width: Get.width*0.015),
                                      SvgPicture.asset(ImageConstants.chatSquare),
                                      SizedBox(width: Get.width*0.015),
                                      AppText(text: "28",
                                          textAlign: TextAlign.center,
                                          fontSize: 0.016,
                                          fontFamily: FontConstants.AppFont,
                                          fontWeight: FontWeight.w700,
                                          color: ColorConstants.white),

                                    ],
                                  ),
                                  SvgPicture.asset(ImageConstants.shareIcon)

                                ],
                              ),
                              SizedBox(height: Get.height*0.03),
                            ],
                          ),
                        ),


                      ],
                    );
                  }),
            )
              //   : (_selectedIndex==1)?Container(
              // height: 20,
              // color: Colors.red,):SizedBox()

            ,

          ],
        ),
      ),
    );
  }


}

