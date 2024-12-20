import 'package:tobacco_sellers/const/colors.dart';
import 'package:tobacco_sellers/const/shared_preferences.dart';
import 'package:tobacco_sellers/screens/add_user_details_page.dart';
import 'package:tobacco_sellers/widgets/page_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  /* Google Authentication and login function */
signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth?.accessToken,
      idToken: gAuth?.idToken,
    );
    UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);

    SharedPreferenceHelper().saveUserName(user.user?.displayName);
    SharedPreferenceHelper().saveEmail(user.user?.email);
    SharedPreferenceHelper().saveBalance("10000");

    if (user.user != null) {
      // Check if user details already exist
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user?.uid)
          .get();

      if (!userDoc.exists) {
        // If user details don't exist, navigate to UserDetailsPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserDetailsPage(
              email: user.user?.email,
              displayName: user.user?.displayName,
            ),
          ),
        );
      } else {
        // If user details exist, navigate to PageContainer
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => PageContainer()),
          (Route route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Limit the image height to a percentage of the screen height
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: Image.asset(
                        "assets/images/signup.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Sign up today and unlock exclusive access to thrilling bidding wars and unbeatable deals.",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () => signInWithGoogle(context),
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppColor.green,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/google.png",
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}