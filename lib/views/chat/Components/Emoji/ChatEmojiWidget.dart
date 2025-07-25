import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/CQController.dart';

class ChatEmojiWidget extends StatelessWidget {
  final VoidCallback? closeSelected;
  final CQController cqController;
  const ChatEmojiWidget({super.key, required this.closeSelected, required this.cqController});

  @override
  Widget build(BuildContext context) {
    Color? color =
        ThemeUtil.isDarkMode(context) ? Color(0xFF292929) : Colors.white;
    return Material(
      elevation: 8,
      child: Container(
        color: Colors.indigo,
        width: 100.w,
        height: 250.h,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            if (closeSelected != null) {
              closeSelected!();
            }
            cqController.insertTextAtCursor(emoji.emoji);
            print("Emoji selected: ${emoji.emoji}");
          },
          config: Config(
            checkPlatformCompatibility: true,
            emojiViewConfig: EmojiViewConfig(
              columns: 10,
              emojiSizeMax: 20,
              backgroundColor: color,
              gridPadding: EdgeInsets.all(8),
            ),
            viewOrderConfig: const ViewOrderConfig(
              top: EmojiPickerItem.categoryBar,
              middle: EmojiPickerItem.emojiView,
              bottom: EmojiPickerItem.searchBar,
            ),
            skinToneConfig: const SkinToneConfig(),
            categoryViewConfig: CategoryViewConfig(
              backgroundColor: color,
              indicatorColor: Colors.indigo,
              iconColorSelected: Colors.indigo,
              backspaceColor: Colors.indigo,
            ),
            bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
            searchViewConfig: const SearchViewConfig(),
          ),
        ),
      ),
    );
  }
}
