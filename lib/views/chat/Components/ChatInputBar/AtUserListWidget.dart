import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/domain/ChatUser.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/CQController.dart';
import 'package:provider/provider.dart';

/// @ USer ListView
/// click user created @ component
///
class AtUserListWidget extends StatefulWidget {
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
  State<AtUserListWidget> createState() => _AtUserListWidgetState();
}

class _AtUserListWidgetState extends State<AtUserListWidget> {
  @override
  Widget build(BuildContext context) {
    return Selector<CQController, String>(
      selector: (_, controller) => controller.currentMentionKeyword,
      builder: (_, keyword, __) {
        final isDark = ThemeUtil.isDarkMode(context);
        final hoverColor =
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05);
        final textColor = isDark ? Colors.white : Colors.black87;

        if (widget.atUsers.isEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '没有可以@的用户',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          );
        }
        // 模糊过滤：只保留昵称包含 keyword 的用户
        final filteredUsers =
            widget.atUsers.where((user) {
              final nickname = user.nickname.toLowerCase();
              return nickname.contains(keyword.toLowerCase());
            }).toList();

        return Material(
          type: MaterialType.card,
          elevation: 12,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 90.w,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300.h),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: filteredUsers.length + 1,
                separatorBuilder: (_, index) {
                  if (index == 0) {
                    return const SizedBox.shrink();
                  }
                  return Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    indent: 12,
                    endIndent: 12,
                  );
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '推荐用户',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          filteredUsers.isEmpty?Center(child: Text("没有匹配的用户")):SizedBox.shrink(),
                        ],
                      ),
                    );
                  }
                  
                  final user = filteredUsers[index - 1];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.avatarUrl),
                      backgroundColor: Colors.transparent,
                      radius: 18,
                    ),
                    title: Text(
                      user.nickname,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    hoverColor: hoverColor,
                    onTap: () {
                      widget.closeSelected?.call();
                      widget.cqController.deleteEmbedAtCursor();
                      widget.cqController.insertEmbedAtCursor('at', {
                        'id': user.id,
                        'name': user.nickname,
                      });
                      widget.cqController.showAtSuggestion = false;
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
