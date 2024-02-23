import 'package:appchat/colors.dart';
import 'package:appchat/common/widgets/custom_button.dart';
import 'package:appchat/features/auth/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country country = Country(
    phoneCode: "84", 
    countryCode: "VN", 
    e164Sc: 0, 
    geographic: true, 
    level: 1, 
    name: "Vietnam", 
    example: "Vietnam", 
    displayName: "Vietnam", 
    displayNameNoCountryCode: "VN", 
    e164Key: ""
  );

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry(){
    showCountryPicker(  
      context: context, 
      onSelect: (Country _country){
        setState(() {
          country = _country;
      });
    });
  }

  void sendPhoneNumber(){
    String phoneNumber = phoneController.text.trim();
      ref
      .read(authControllerProvider)
      .signInWithPhone(context, '+${country.phoneCode}$phoneNumber');
  }

  _handleGoogleBtnClick() {
     signInWithGoogle().then((user) {
      ref.read(authControllerProvider).saveUserDataToFirebase(
            context,
            '',
            null,
            'email'
            );
    
     });
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = 
      await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = 
      await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneController.text.length)
      );
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title:  const Text(''),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.shade50,
                  ),
                  child: Image.asset(
                    "assets/login.png"
                  ),
                ),
            const SizedBox(height: 30,),
            const Text('WhatsApp will need to verify your phone number.'),
            const SizedBox(height: 20,),
            TextFormField(
                  controller: phoneController,
                  onChanged: (value) {
                    setState(() {
                      phoneController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText:  "Enter phone  number",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white12)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white12)
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.fromLTRB(12, 13, 5, 0.8),
                      child: InkWell(
                        onTap: (){
                          showCountryPicker(
                            context: context, 
                            countryListTheme: const CountryListThemeData(
                              bottomSheetHeight: 600,
                            ),
                            onSelect: (value) {
                              setState(() {
                                country = value;
                              });
                            });
                        },
                        child: Text("${country.flagEmoji} + ${country.phoneCode}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold                          
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: phoneController.text.length >= 9 
                    ? Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green),
                      child: const Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                    : null
                  ),
                ),
            const SizedBox(height: 14,),
            const Text('Or'),  
            const SizedBox(height: 14,),
            SizedBox(
              width: size.width * 0.9,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 1,
                ),
                onPressed: (){
                  _handleGoogleBtnClick();
                },
                icon: Image.asset('assets/google.png', height: size.height * .04,),
                label: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 16), 
                    children: [
                      TextSpan(text: 'Login with '),
                      TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    ]
                  )
                ),
              ),
            ),    
            SizedBox(height: size.height*0.2,),
            SizedBox(
              width: 90,
              child: CustomButton(
                onPressed: sendPhoneNumber,
                text: 'NEXT', ),
            ),
          ],
        ),
      ),      
    );
  }
}