import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/utils/themeUtil.dart';

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 90.w,
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => ListTile(
              title: Text("项目 ${index + 1}"),
            ),
          ),
        ),
        Expanded(child:Padding(
          padding: EdgeInsets.all(2),
          child: Card(
            color: ThemeUtil.isDarkMode(context)?Colors.grey.shade800: Colors.white,
            child: Container(
              child: const Center(
                child: Text("项目详情"),
              ),
            ),
          ),
        )),
      ],
    );
  }
}