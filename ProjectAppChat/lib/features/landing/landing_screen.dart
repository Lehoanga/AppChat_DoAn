import 'package:appchat/colors.dart';
import 'package:appchat/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../auth/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

   void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Welcome to AppChat',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: size.height / 9),
            Image.asset('assets/bg.png',
              height: 340,
              width: 340,
              color: tabColor
              ,),
            SizedBox(height: size.height / 9,),
            Padding(
          padding: EdgeInsets.all(15.0),
          child: GestureDetector(
            onTap: () {
              _showPrivacyPolicyModal(context);
            },
            child: Text(
              'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
            const SizedBox(height: 10,),
            SizedBox(
              width: size.width*0.75,
                child: CustomButton(
                    text: 'AGREE AND CONTINUE',
                    onPressed: () => navigateToLoginScreen(context)))
          ],
        ),
      ),
    );
  }


  
   void _showPrivacyPolicyModal(BuildContext context) {
  final size = MediaQuery.of(context).size;
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          width: size.width,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Use a SingleChildScrollView or ListView for scrollable content
              SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      '1. Use Messenger your way.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      'You decide whose messages go into the Chat list, who goes into the Pending Messages folder, and who cant text or call you at all. With Privacy Settings, you can control message delivery, blocked contacts, App lock, Secret conversations, who sees your stories, and stories you muted in one place.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.justify,
                    ),
                    Text(
                      '2. Control who can message you.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      'Messenger continually innovates to protect you from threats, and tools like blocking multiple people help you control your experience. You decide whose messages go into the Chat list, who goes into the Pending Messages folder, and who cant text or call you at all.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.justify,
                    ),
                    Text(
                      '3. One-Time Notification.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      'Messenger Platforms One-Time Notification API (Beta) allows a page to send a time-sensitive and personally relevant notification for use cases (e.g. back in stock alert) where someone has explicitly requested to receive a one-time follow up message. Once the user asks to be notified, the page will receive a token which is an equivalent to a permission to send a single message to the user. The token can only be used once and will expire within 1 year of creation. Learn more here. Note, One-Time Notification is not available for IG Messaging API.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                )                
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(tabColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

}