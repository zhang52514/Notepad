import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/CQController.dart';


/// @ USer ListView
/// click user created @ component
///
class AtUserListWidget extends StatelessWidget {
  final List<ChatUser> atUsers;
  final VoidCallback? closeSelected;
  final CQController cqController;

  const AtUserListWidget({
    super.key,
    required this.atUsers,
    required this.closeSelected,
    required this.cqController,
  });

  @override
  Widget build(BuildContext context) {
    Color? color = ThemeUtil.isDarkMode(context) ? Color(0xFF292929) : Colors.white;

    if(atUsers.isEmpty) {
      return SizedBox.shrink();
    }

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
          itemCount: atUsers.length,
          itemBuilder: (context, index) {
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(atUsers[index].avatarUrl),
                backgroundColor: Colors.transparent,
                radius: 18,
              ),
              title: Text(atUsers[index].nickname),
              hoverColor: Colors.indigo,
              onTap: () {
                if (closeSelected != null) {
                  closeSelected!();
                }
                cqController.deleteEmbedAtCursor();
                cqController.insertEmbedAtCursor('at', {'id': atUsers[index].id});
                cqController.showAtSuggestion = false;
              },
            );
          },
        ),
      ),
    );
  }
}
