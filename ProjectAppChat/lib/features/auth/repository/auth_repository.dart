
import 'dart:io';

import 'package:appchat/common/repositories/common_firebase_storage_repository.dart';
import 'package:appchat/features/auth/screens/user_information_screen.dart';
import 'package:appchat/features/landing/landing_screen.dart';
import 'package:appchat/screens/mobile_layout_screen.dart';
import 'package:appchat/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../models/user_model.dart';
import '../screens/otp_screen.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);


class AuthRepository{
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  AuthRepository({
    required this.auth,
    required this.firestore,
  });

   Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('user').doc(auth.currentUser?.uid).get();

    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }
  
  void  signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber, 
        verificationCompleted: (PhoneAuthCredential credential) async {
        }, 
        verificationFailed: (e) {
          throw Exception(e.message);
        }, 
        codeSent: ((String verificationId, int? resendToken) async {
            Navigator.pushNamed(
              context,
              OTPScreen.routeName,
              arguments: verificationId,
            );
          }),
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } on FirebaseAuthException catch (e){
        showSnackBar(context: context, content: e.message!);
    }
  }
  
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
    }) async {
    try {
      
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, 
        smsCode: userOTP);
      await auth.signInWithCredential(credential);

      var userData = await firestore.collection('user').doc(auth.currentUser?.uid).get();
      if (userData.data() != null) {
        setToken();
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(
          context, 
          MobileLayoutScreen.routeName, 
          (route) => false);
      } else{
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(
          context, 
          UserInformationScreen.routeName, 
          (route) => false);
      }      
    } on FirebaseAuthException catch(e) {
     showSnackBar(context: context, content: e.message!);
    }
   }

  void saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
    required String typeSign,
  }) async {
    try {
      final UserModel? userData = await getCurrentUserData();

      String uid = auth.currentUser!.uid;
      String photoUrl = 'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
      if(typeSign == 'email'){
        photoUrl = auth.currentUser!.photoURL!;
      }

      if(profilePic != null && typeSign == 'none'){
        photoUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase('profilePic/$uid', profilePic,);
      }
      
      if (userData != null && profilePic == null){
        photoUrl = userData.profilePic;
      }

      if(userData == null && typeSign == 'email'){
        name = auth.currentUser!.displayName!;
      }
      if(userData != null && typeSign == 'email'){
        name = userData.name;
      }  

      String? token = await FirebaseMessaging.instance.getToken();

      var user = UserModel(
        name: name, 
        uid: uid, 
        profilePic: photoUrl, 
        isOnline: true, 
        phoneNumber: auth.currentUser!.phoneNumber.toString(),
        gmail: auth.currentUser!.email.toString(), 
        groupId: [],
        token: token ?? '',
      );

      await firestore.collection('user').doc(uid).set(user.toMap());
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ), 
        (route) => false
      );
    } catch(e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userData(String userId) {
    return firestore.collection('user').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }

  void setUserState(bool isOnline) async {
    await firestore.collection('user').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }
 
  void setToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    await firestore.collection('user').doc(auth.currentUser!.uid).update({
      'token': token,
    });
  }

 Future<void> signOut(BuildContext context) async {
    try {
      await auth.signOut();
      await GoogleSignIn().signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(
          builder: (context) =>LandingScreen(),
        ), 
        (route) => false);
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }

  Future<String?> getUserNameByID(String uid) async {
    var userData = await firestore.collection('user').doc(uid).get();

    if (userData.exists) {
      return UserModel.fromMap(userData.data()!).name;
    } else {
      return null;
    }
  } 

}