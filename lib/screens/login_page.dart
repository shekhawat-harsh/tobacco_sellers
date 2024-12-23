import 'package:tobacCoSellers/const/colors.dart';
import 'package:tobacCoSellers/const/shared_preferences.dart';
import 'package:tobacCoSellers/screens/wharehouse_regestrarion_screen.dart';
import 'package:tobacCoSellers/widgets/page_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      // Check if user details already exist in sellers collection by email
      final sellerQuery = await FirebaseFirestore.instance
          .collection('sellers')
          .where('email', isEqualTo: user.user?.email)
          .get();

      if (sellerQuery.docs.isNotEmpty) {
        // If user details exist, navigate to PageContainer
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => PageContainer()),
          (Route route) => false,
        );
      } else {
        // If user details don't exist, navigate to WarehouseRegistrationPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WarehouseRegistrationPage(email: user.user?.email)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Tobacco Console",
                        style: GoogleFonts.pacifico(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColor.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.smoking_rooms,
                        color: AppColor.secondary,
                        size: 36,
                      ),
                    ],
                  ),
                  Text(
                    "For sellers",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColor.secondary,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: Image.asset(
                        "assets/images/signup_now.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Sign up today to start selling prodocuts on Tobacco and reach millions of customers, after you sign up we will verify your details and you can start selling your products.",
                      style: TextStyle(fontSize: 16, color: AppColor.secondary),
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
                          color: AppColor.secondary,
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
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}