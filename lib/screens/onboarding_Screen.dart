import 'package:tobacCoSellers/const/colors.dart';
import 'package:tobacCoSellers/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 80,
            right: -50,
            child: Transform.rotate(
              angle: -50,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: SizedBox(
                  width: 240,
                  height: 180,
                  child: Image.asset("assets/images/img3.png", height: 200, width: 300, fit: BoxFit.cover),
                ),
              ),
            ),
          ), //Container
          Positioned(
            top: 260,
            right: -10,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: SizedBox(
                width: 300,
                height: 220,
                child: Image.asset("assets/images/img2.jpg", height: 200, width: 300, fit: BoxFit.cover),
              ),
            ),
          ), //Container
          Positioned(
            top: 480,
            right: -50,
            child: Transform.rotate(
              angle: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: SizedBox(
                  height: 180,
                  width: 240,
                  child: Image.asset("assets/images/img1.png", fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                Text("Tobacco", style: TextStyle(color: AppColor.secondary, fontSize: 42, fontWeight: FontWeight.bold)),
                Container(
                  height: 5,
                  width: 100,
                  color: AppColor.secondary,
                )
              ],
            )
          ),
          Positioned(
            bottom: 60,
              left: 20,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text("-Put auctions and list your products\n-Handle sales", style: TextStyle(fontWeight: FontWeight.w700 ,color: AppColor.secondary, fontSize: 18)),
              SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.secondary
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: AppColor.primary,
                    size: 40,
                  ),
                ),
              ),
            ],
          ))//Container
        ], //<Widget>[]
      ),
    );
  }
}
