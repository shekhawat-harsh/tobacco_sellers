import 'package:tobacCoSellers/const/colors.dart';
import 'package:tobacCoSellers/const/shared_preferences.dart';
import 'package:tobacCoSellers/screens/login_page.dart';
import 'package:tobacCoSellers/widgets/personal_detail_tab.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/Profile_item_containers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String? userName = SharedPreferenceHelper().getUserName();
  final String? userEmail = SharedPreferenceHelper().getEmail();

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = SharedPreferenceHelper();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColor.secondary,
              child: Image.asset("assets/images/avatar2.png", fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    userName != null && userName!.length > 15
                        ? '${userName!.substring(0, 15)}...'
                        : userName ?? '',
                    style: const TextStyle(color: AppColor.secondary, fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: AppColor.secondary),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.email, color: AppColor.secondary, size: 15),
                const SizedBox(width: 8),
                Text("$userEmail", style: const TextStyle(color: AppColor.secondary)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalDetailsTab()),
              ),
              child: const Text("Personal Details", style: TextStyle(color: AppColor.primary)),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColor.secondary)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text("Logout", style: TextStyle(color: AppColor.primary)),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColor.secondary)),
            ),
            const SizedBox(height: 20),
            Container(
              height: 30,
              width: 150,
              child: const Center(
                child: Text('Posted', style: TextStyle(color: AppColor.secondary)),
              ),
            ),
            const SizedBox(height: 20),
            PostedContainer(),
          ],
        ),
      ),
    );
  }
}
