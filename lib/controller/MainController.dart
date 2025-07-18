import 'package:notepad/common/utils/ColorUtil.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:notepad/views/contact/ContactView.dart';
import 'package:notepad/views/find/FindView.dart';
import 'package:notepad/views/chat/HomeIndex.dart';
import 'package:notepad/views/chat/HomeView.dart';
import 'package:notepad/views/mine/MineView.dart';
import 'package:notepad/views/notpad/NotPadView.dart';
import 'package:notepad/views/setup/SetUpView.dart';

class MainController extends ChangeNotifier {
  /// Brightness
  /// 主题切换 默认light
  Brightness _brightness = Brightness.light;
  Brightness get brightness => _brightness;

  ///MAX | MIN
  ///最大最小化 图标切换
  bool _extended = false;
  bool get extended => _extended;
  set extendedValue(bool value) {
    _extended = value;
    notifyListeners();
  }

  ///PageController
  ///用于控制页面的切换
  PageController pageController = PageController(initialPage: 0);

  ///pageIndex
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int value) {
    _currentIndex = value;
    pageController.jumpToPage(value);
    notifyListeners();
  }

  //页面
  final List<Widget> views = [
    HomeView(),
    ContactView(),
    NotPadView(),
    FindView(),
    MineView(),
    SetUpView(),
  ];

  //applciation theme
  ThemeData appThemeData() {
    return ThemeData(
      useMaterial3: true,

      ///字体
      fontFamily: "HarmonyOS",
      textTheme: const TextTheme(
        // Display 系列
        displayLarge: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 34.0, fontWeight: FontWeight.w500),
        displaySmall: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w400),

        // Headline 系列
        headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),

        // Title 系列
        titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),

        // Body 系列
        bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
        bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),

        // Label 系列
        labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w400),
      ),

      ///主题模式
      brightness: brightness,
      splashColor: Colors.transparent,
      // 禁用水波纹效果
      highlightColor: Colors.transparent,

      ///边框按钮
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),

      ///侧边栏
      drawerTheme: DrawerThemeData(
        elevation: 20,
        shadowColor: Colors.grey,
        scrimColor: Colors.transparent,
        endShape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),

      ///填充按钮
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey;
            }
            return Colors.indigo;
          }),
          // 正常 / 禁用 文本色
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade300;
            }
            return Colors.white;
          }),
          // 正常 / 禁用 阴影（elevation）
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.disabled)) {
              return 0;
            }
            return 4;
          }),
          // 圆角、内边距
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),

      ///文本按钮
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),

      ///选择框
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
        splashRadius: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(width: 1, color: ColorUtil.border1),
      ),

      ///图标按钮
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),

      ///卡片
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      /// ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      ///底部导航栏
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(
          size: 25.0, // 选中图标大小
        ),
        // 自定义未选中项的图标主题
        unselectedIconTheme: const IconThemeData(
          size: 20.0, // 未选中图标大小
        ),
        // 自定义选中项的文字样式
        selectedLabelStyle: const TextStyle(
          fontSize: 14.0, // 选中文字大小
          fontWeight: FontWeight.bold, // 文字加粗
        ),

        // 自定义未选中项的文字样式
        unselectedLabelStyle: const TextStyle(
          fontSize: 12.0, // 未选中文字大小
        ),
      ),

      ///Windows 侧边栏
      navigationRailTheme: NavigationRailThemeData(
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 1,
        groupAlignment: 0.0,
      ),

      ///输入框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // 背景颜色
        hintStyle: const TextStyle(color: ColorUtil.subtitle1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 1.0, color: ColorUtil.border1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),

      ///弹窗
      dialogTheme: DialogTheme(
        actionsPadding: const EdgeInsets.all(8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // 设置对话框的圆角
        ),
      ),
    );
  }

  void setBrightness(Brightness color, {bool now = true}) {
    _brightness = color;
    if (now) {
      SpUtil.putString('key_brightness', brightness.name);
      notifyListeners();
    }
  }

  Brightness getBrightnessStart() {
    String brightnessString =
        SpUtil.getString('key_brightness', defValue: 'light') ?? 'light';
    if (brightnessString == 'light') {
      return Brightness.light;
    }
    return Brightness.dark;
  }
}
