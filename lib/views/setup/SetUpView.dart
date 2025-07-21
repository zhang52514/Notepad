import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:notepad/views/setup/SettingsSection.dart';
import 'package:provider/provider.dart';

class SetUpView extends StatelessWidget {
  const SetUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainController>(
      builder: (context, app, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSection(
                title: "外观",
                children: [
                  SettingsTile(
                    icon: HugeIcons.strokeRoundedColors,
                    label: "主题",
                    child: _buildThemeSelector(context, app),
                  ),
                ],
              ),
              // 后续添加其他设置项
              const SizedBox(height: 24),
              SettingsSection(
                title: "通知",
                children: [
                  SettingsTile(
                    icon: Icons.notifications,
                    label: "消息通知",
                    child: Switch(value: true, onChanged: (v) {}),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSelector(BuildContext context, MainController app) {
    var isDark = ThemeUtil.isDarkMode(context);
    return DropdownMenu<String>(
      controller: ReadOnlyTextEditingController(text: isDark ? "深色" : "浅色"),
      width: 250,
      enableSearch: false,
      initialSelection: isDark ? "深色" : "浅色",
      selectedTrailingIcon: const HugeIcon(
        icon: HugeIcons.strokeRoundedArrowDown01,
      ),
      trailingIcon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          ThemeUtil.isDarkMode(context) ? Colors.black : Color(0xFFE6E6E9),
        ),
      ),
      dropdownMenuEntries: [
        DropdownMenuEntry<String>(
          value: "浅色",
          label: "浅色",
          leadingIcon:
              !isDark
                  ? const Icon(Icons.done_rounded, size: 16)
                  : const Icon(
                    Icons.done_rounded,
                    size: 16,
                    color: Colors.transparent,
                  ),
        ),
        DropdownMenuEntry<String>(
          value: "深色",
          label: "深色",
          leadingIcon:
              isDark
                  ? const Icon(Icons.done_rounded, size: 16)
                  : const Icon(
                    Icons.done_rounded,
                    size: 16,
                    color: Colors.transparent,
                  ),
        ),
      ],
      onSelected: (value) {
        if (value == "浅色") {
          app.setBrightness(Brightness.light);
        } else {
          app.setBrightness(Brightness.dark);
        }
      },
    );
  }
}

class ReadOnlyTextEditingController extends TextEditingController {
  ReadOnlyTextEditingController({super.text});

  @override
  set value(TextEditingValue newValue) {
    if (newValue.text != text) {
      super.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else {
      super.value = newValue;
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return TextSpan(text: text, style: style);
  }

  @override
  TextSelection get selection => TextSelection.collapsed(offset: text.length);

  @override
  set selection(TextSelection newSelection) {
    // 阻止外部设置 selection，始终保持折叠状态
    // super.selection = newSelection; // 不调用这个，因为它会允许改变 selection
  }
}
