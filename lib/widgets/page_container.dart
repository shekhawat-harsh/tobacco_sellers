import 'package:tobacCoSellers/const/colors.dart';
import 'package:tobacCoSellers/screens/home_screen.dart';
import 'package:tobacCoSellers/screens/login_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tobacCoSellers/screens/order_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/dashboard_page.dart';
import '../screens/profile_page.dart';

class PageContainer extends StatefulWidget {
  const PageContainer({Key? key}) : super(key: key);

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    DashboardPage(),
    HomeScreen(),
    ProfilePage(),
  ];

  Future<bool> _checkApprovalStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final sellerQuery = await FirebaseFirestore.instance
          .collection('sellers')
          .where('email', isEqualTo: user.email)
          .get();

      if (sellerQuery.docs.isNotEmpty) {
        return sellerQuery.docs.first.data()['isApproved'] ?? false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data == null) {
            return LoginPage();
          } else {
            return FutureBuilder<bool>(
              future: _checkApprovalStatus(),
              builder: (context, approvalSnapshot) {
                if (approvalSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: AppColor.secondary));
                }
                if (approvalSnapshot.data == true) {
                  return Scaffold(
                    backgroundColor: AppColor.primary,
                    bottomNavigationBar: CurvedNavigationBar(
                      backgroundColor: Colors.transparent,
                      color: AppColor.secondary,
                      height: 60,
                      index: _currentIndex,
                      animationDuration: Duration(milliseconds: 600),
                      onTap: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      items: const [
                        Icon(Icons.store, color: AppColor.primary),
                        Icon(Icons.home_filled, color: AppColor.primary),
                        Icon(Icons.person, color: AppColor.primary),
                      ],
                    ),
                    body: _pages[_currentIndex],
                  );
                } else {
                  return Scaffold(
                    backgroundColor: AppColor.primary,
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Thanks for registering with us. We will get back to you in 2 business days. Until then, have a good time!",
                          style: TextStyle(color: AppColor.secondary, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(
            color: AppColor.secondary,
          ),
        );
      },
    );
  }
}