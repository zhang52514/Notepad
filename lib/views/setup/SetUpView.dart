// Created by zhangyong on 2023/10/12.
import 'package:flutter/material.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:provider/provider.dart';


class SetUpView extends StatefulWidget {
  const SetUpView({super.key});

  @override
  State<SetUpView> createState() => _SetUpViewState();
}

class _SetUpViewState extends State<SetUpView> {
  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.titleLarge;
    var body = Theme.of(context).textTheme.titleSmall;
    print("SetUpView ==============>");

    return Consumer<MainController>(
        builder: (BuildContext context, MainController app, Widget? child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getColorThemeSetting(app, style, body),
              ],
            ),
          );
        },
    );
  }

  Widget getColorThemeSetting(MainController app, var style, var body) {
    var isDark = Theme.of(context).brightness.index == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("外观", style: style),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20,
            ),
            leading: Icon(
              Icons.brightness_6_rounded,
      
            ),
            title: Text("主题", style: body),
            trailing: DropdownMenu(
              width: 250,
              enableSearch: false,
              initialSelection: isDark ? "深色" : "浅色",
              textStyle: body,
              trailingIcon: const Icon(Icons.keyboard_arrow_down),
              selectedTrailingIcon: const Icon(Icons.keyboard_arrow_down),
              dropdownMenuEntries: [
                DropdownMenuEntry<String>(
                  leadingIcon:
                      isDark
                          ? const Icon(
                            Icons.done_rounded,
                            color: Colors.transparent,
                            size: 16,
                          )
                          : const Icon(Icons.done_rounded, size: 16),
                  value: "浅色",
                  label: "浅色",
                ),
                DropdownMenuEntry<String>(
                  leadingIcon:
                      isDark
                          ? const Icon(Icons.done_rounded, size: 16)
                          : const Icon(
                            Icons.done_rounded,
                            color: Colors.transparent,
                            size: 16,
                          ),
                  value: "深色",
                  label: "深色",
                ),
              ],
              onSelected: (String? value) {
                if (value == "浅色") {
                  app.setBrightness(Brightness.light);
                  return;
                }
                app.setBrightness(Brightness.dark);
              },
            ),
          ),
        ),
      
      ],
    );
  }
}
