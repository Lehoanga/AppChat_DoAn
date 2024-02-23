import 'package:appchat/common/widgets/error.dart';
import 'package:appchat/features/account/screens/edit_user_information_screen.dart';
import 'package:appchat/features/auth/screens/login_screen.dart';
import 'package:appchat/features/auth/screens/otp_screen.dart';
import 'package:appchat/features/auth/screens/user_information_screen.dart';
import 'package:appchat/features/chat/screens/mobile_chat_screen.dart';
import 'package:appchat/features/chat/widgets/setting_group_chat.dart';
import 'package:appchat/features/chat/widgets/view_members.dart';
import 'package:appchat/features/group/screens/create_group_screen.dart';
import 'package:appchat/features/select_contacts/screens/contact_screen.dart';
import 'package:appchat/screens/mobile_layout_screen.dart';


import 'package:flutter/material.dart';

import 'features/select_contacts/screens/select_contacts_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch(settings.name) {
    case LoginScreen.routeName: 
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case OTPScreen.routeName: 
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
        ),
      );
      case UserInformationScreen.routeName: 
        return MaterialPageRoute(
          builder: (context) => const UserInformationScreen(),
      );
      case SelectContactsScreen.routeName: 
        return MaterialPageRoute(
          builder: (context) => const SelectContactsScreen(),
      );
      case ContactSelectScreen.routeName: 
        return MaterialPageRoute(
          builder: (context) => const ContactSelectScreen(),
      );      
      case MobileLayoutScreen.routeName: 
        return MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
      );
      case MobileChatScreen.routeName: 
        final arguments = settings.arguments as Map<String, dynamic>;
        final name = arguments['name'];
        final uid = arguments['uid'];
        final isGroupChat = arguments['isGroupChat'];
        final profilePic = arguments['profilePic'];
        final senderId = arguments['senderId'];
        return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
          isGroupChat: isGroupChat,
          profilePic: profilePic,
          senderId: senderId,
        ),
      );
      case CreateGroupScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => const CreateGroupScreen(),
      );
      case SettingGroupChat.routeName:
        final arguments = settings.arguments as Map<String, dynamic>;
        final name = arguments['name'];
        final uid = arguments['uid'];
        final isGroupChat = arguments['isGroupChat'];
        final profilePic = arguments['profilePic'];
        final senderId = arguments['senderId'];
        return MaterialPageRoute(
          builder: (context) => SettingGroupChat(
            name: name,
            uid: uid,
            isGroupChat: isGroupChat,
            profilePic: profilePic,
            senderId : senderId,
          ),
      );
      case EditUserInformation.routeName: 
        return MaterialPageRoute(
        builder: (context) => const EditUserInformation(),
      );    
      case ViewMembers.routeName: 
        final arguments = settings.arguments as Map<String, dynamic>;
        final groupId = arguments['groupId'];
        final uid = arguments['uid'];
        return MaterialPageRoute(
        builder: (context) => ViewMembers(
          groupId: groupId,
          uid: uid,
        ),
      ); 
      // case CallInvitatuinPage.routeName: 
      //   final arguments = settings.arguments as Map<String, dynamic>;
      //   bool isGroupChat =  arguments['isGroupChat'];
      //   return MaterialPageRoute(
      //   builder: (context) => CallInvitatuinPage(isGroupChat: isGroupChat),
      // );
      // case AudioInvitatuinPage.routeName: 
      //   final arguments = settings.arguments as Map<String, dynamic>;
      //   bool isGroupChat =  arguments['isGroupChat'];
      //   return MaterialPageRoute(
      //   builder: (context) => AudioInvitatuinPage(isGroupChat: isGroupChat),
      // );      
    default:
      return MaterialPageRoute(builder: (context) => const Scaffold(
        body: ErrorScreen(error: 'This page doesn\'t exist',),
      ),
    );
  }
}