import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/CQController.dart';


/// @ USer ListView
/// click user created @ component
///
class AtUserListWidget extends StatelessWidget {
  final VoidCallback? closeSelected;
  final CQController cqController;

  const AtUserListWidget({
    super.key,
    required this.closeSelected,
    required this.cqController,
  });

  @override
  Widget build(BuildContext context) {
    Color? color =
        ThemeUtil.isDarkMode(context) ? Color(0xFF292929) : Colors.white;
    return Material(
      type: MaterialType.card,
      elevation: 8,
      child: Container(
        width: 100.w,
        height: 250.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://gd-filems.dancf.com/gaoding/cms/mcm79j/mcm79j/91878/c29d3bc0-0801-4ec7-a885-a52dedc3e5961503149.png',
                ),
                backgroundColor: Colors.transparent,
                radius: 18,
              ),
              title: Text("data$index"),
              hoverColor: Colors.indigo,
              onTap: () {
                if (closeSelected != null) {
                  closeSelected!();
                }
                cqController.deleteEmbedAtCursor();
                cqController.insertEmbedAtCursor('at',"data$index");
                cqController.showAtSuggestion = false;
              },
            );
          },
        ),
      ),
    );
  }
}
