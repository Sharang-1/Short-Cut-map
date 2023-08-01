import 'package:QensMAP/main.dart';
// import 'package:cipher/views/homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  // const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();

    Future.delayed(Duration(seconds:3)).then((value){
      Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (ctx) => MapApp()));
    });
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image(image:NetworkImage("https://www.cipherschools.com/static/media/Cipherschools_icon@2x.3b571d743ffedc84d039.png"), width: 200),
            Container(
              alignment: Alignment.center,
              child: Text('Loading Qen Maps...', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            ),
            SizedBox(
              height: 50,
            ),
            SpinKitSpinningCircle(
              color: Colors.blue,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}