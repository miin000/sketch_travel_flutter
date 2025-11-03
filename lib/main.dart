import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/constants.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cloudinary_controller.dart';
import 'controllers/theme_controller.dart';
import 'views/screens/auth/login_screen.dart';

import 'firebase_options.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/gestures.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  timeago.setLocaleMessages('vi', timeago.ViMessages());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    Get.put(AuthController());
    Get.put(CloudinaryController());
    Get.put(ThemeController());
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SketchTravel',

      theme: ThemeData.light(useMaterial3: true).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
        //theme SÁNG
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: backgroundColor, // Dùng biến constants
          appBarTheme: AppBarTheme(
            backgroundColor: backgroundColor,
            elevation: 0,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: backgroundColor,
            selectedItemColor: buttonColor, // Dùng biến constants
            unselectedItemColor: Colors.white,
          )
        //theme TỐI
      ),
      themeMode: themeController.theme,

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),

      home: LoginScreen(),
    );
  }
}