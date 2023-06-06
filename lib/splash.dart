import 'package:flutter/material.dart';

import 'webview_example.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(seconds: 2)).then((value){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>const  InAppWebViewExampleScreen()), (route) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1CC),
      body: Center(
        child: Image.asset("assets/images/logo.png",width: 200,height: 200,),
      ),
    );
  }
}
