
import 'dart:async';

import 'package:jovicionario/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {

  AnimationController animationController;
  Animation<double> animation;

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));

  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOutBack);

    animation.addListener(() => this.setState(() {}));
    animationController.forward(from: 0.4);

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/icon/Joviface.png',
                width: animation.value * 250,
                height: animation.value * 250,
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(bottom: 30.0),
                  child:Text('Jovicionário\npor Bruno P. Antonieto',textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)
              )
            ],
          ),
        ],
      ),
    );
  }
}