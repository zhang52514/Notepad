// Created by Anoxia on 2023/10/17.
import 'package:bot_toast/bot_toast.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:notepad/controller/ChatController.dart';
import 'package:notepad/controller/MainController.dart';
import 'package:notepad/views/MainNavigatorWidgetWindows.dart';
import 'package:notepad/views/chat/ChatMessage/AudioMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/EmojiMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/FileMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/ImageMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/LinkMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/LocationMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/MarkdownMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/QuillMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/TextMessageRenderer.dart';
import 'package:notepad/views/chat/ChatMessage/VideoMessageRenderer.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'controller/CQController.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  registerAllMessageRenderers();

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

void registerAllMessageRenderers() {
  MarkdownMessageRenderer.register();
  QuillMessageRenderer.register();
  TextMessageRenderer.register();
  EmojiMessageRenderer.register();
  ImageMessageRenderer.register();
  AudioMessageRenderer.register();
  VideoMessageRenderer.register();
  FileMessageRenderer.register();
  LocationMessageRenderer.register();
  LinkMessageRenderer.register();
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
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(),
        ),
        ChangeNotifierProxyProvider<AuthController, ChatController>(
          create:
              (ctx) =>
                  ChatController(authController: ctx.read<AuthController>()),
          update: (_, authController, previous) {
            if (previous == null) {
              return ChatController(authController: authController);
            } else {
              previous.authController = authController;
              return previous;
            }
          },
        ),
        ChangeNotifierProvider<CQController>(create: (ctx) => CQController()),
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
            home: Scaffold(body: MainNavigatorWidgetWindows()),
          );
        },
      ),
    );
  }
}
