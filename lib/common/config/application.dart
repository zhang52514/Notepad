import 'package:flutter/material.dart';

class Application{
  static Widget getAppLogo({double width=48,double height=48}){
    return Image.asset("assets/app_icon.png",width: width,height: height);
  }
}