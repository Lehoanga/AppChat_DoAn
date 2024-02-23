import 'package:appchat/common/widgets/error.dart';
import 'package:appchat/features/auth/controller/auth_controller.dart';
import 'package:appchat/features/landing/landing_screen.dart';
import 'package:appchat/features/notifications/firebase_api..dart';
import 'package:appchat/firebase_options.dart';
import 'package:appchat/router.dart';
import 'package:appchat/screens/mobile_layout_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:appchat/colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/widgets/loader.dart';


void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  await FirebaseMessaging.instance.getInitialMessage();
  runApp(const 
  ProviderScope(
    child: MyApp()
    )
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,    
      title: 'Whatsapp UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        )
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider)
        .when(
          data: (user){
            if(user ==null) {
              return LandingScreen();
            }                                      
            return const MobileLayoutScreen();
          }, 
          error: (err, trace) {
              return ErrorScreen(
                error: err.toString(),
              );
            }, 
          loading: () => const Loader(),
        )        
    );
  }
}
