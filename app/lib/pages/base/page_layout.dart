import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'base_state.dart';

class PageLayout extends StatefulWidget {
  PageLayout(
      {Key? key,
      required this.child,
      this.onBack,
      this.onTap,
      this.isLoading,
      this.isAvoidResize,
      this.drawer,
      this.endDrawer,
      this.bgColor,
      this.safeAreaColor,
      this.floatingButton,
      this.orientation,
      this.scaffoldKey})
      : super(key: key) {
    isLoading ??= false;
    isAvoidResize ??= true;
    drawer ??= null;
    endDrawer ??= null;
    bgColor ??= Colors.white;
    orientation ??= Orientation.portrait;
    safeAreaColor ??= Colors.white;
  }

  Widget child;
  Future<bool> Function()? onBack;
  Future<bool> Function()? onTap;
  bool? isLoading;
  bool? isAvoidResize;
  Widget? drawer;
  Widget? endDrawer;
  Widget? floatingButton;
  Color? bgColor;
  Color? safeAreaColor;
  Orientation? orientation;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  PageLayoutState createState() => PageLayoutState();
}

class PageLayoutState extends BaseState<PageLayout> {
  @override
  void initState() {
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false; //<--
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark), // Or Brightness.dark
      );
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return WillPopScope(
      onWillPop: widget.onBack,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          color: widget.safeAreaColor,
          child: SafeArea(
            bottom: false,
            child: Container(
              child: Scaffold(
                key: widget.scaffoldKey,
                resizeToAvoidBottomInset: widget.isAvoidResize,
                drawer: widget.drawer,
                endDrawer: widget.endDrawer,
                body: ModalProgressHUD(
                  inAsyncCall: widget.isLoading ?? false,
                  child: SafeArea(
                    child: Container(
                      color: widget.bgColor,
                      height: MediaQuery.of(context).size.height,
                      child: GestureDetector(
                        onTap: widget.onTap ?? hideKeyboard,
                        child: Center(
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                floatingActionButton: widget.floatingButton,
              ),
              // child: ,
            ),
          ),
        ),
      ),
    );
  }
}
