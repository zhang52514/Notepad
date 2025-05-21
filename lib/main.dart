// Created by Anoxia on 2023/10/17.
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notepad/views/MainNavigatorWidgetWindows.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();

  ///Windows平台
  await windowManager.ensureInitialized();

  ///窗体设置
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 600),
    minimumSize: Size(1000, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    alwaysOnTop: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: "Anoxia-Windows",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    windowManager.setHasShadow(true);
  });

  print('''

 _______
< start >
 -------
        \\   ^__^
         \\  (oo)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||

  ''');

runApp(
    ScreenUtilInit(
      designSize: Size(375, 812), // 你的设计稿尺寸（比如 iPhone X）
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainController>(
          create: (ctx) => MainController(),
        ),
        ChangeNotifierProvider<ChatController>(
          create: (ctx) => ChatController(),
        ),
      ],
      child: Consumer<MainController>(
        builder: (BuildContext context, MainController appInfo, Widget? child) {
          print("MyApp ===================> build");

          ///获取主题
          appInfo.setBrightness(appInfo.getBrightnessStart(), now: false);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: BotToastInit(),
            navigatorObservers: [BotToastNavigatorObserver()],
            title: 'Anoxia',
            theme: appInfo.appThemeData(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'), // 中文简体
              Locale('en', 'US'), // 美国英语
            ],
            home: Scaffold(
              body: MainNavigatorWidgetWindows(),
            ),
          );
        },
      ),
    );
  }
}
