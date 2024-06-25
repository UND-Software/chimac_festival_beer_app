import 'package:chimaek_festival/providers/command_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart'; // 예시로 만들어진 메인 화면

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Future.delayed를 사용하여 context 접근을 지연시키기
      Future.delayed(Duration.zero, () {
        _initialize();
      });
    });
  }

  Future<void> _initialize() async {
    await Provider.of<CommandProvider>(context, listen: false).initCommand();
    await Provider.of<CommandProvider>(context, listen: false).connectRobot();
    
    await Future.delayed(const Duration(seconds: 3));
    
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(200, 0, 200, 0),
        child: Center(
          child: Image.asset('assets/images/magbot+und.png')
        ),
      )
    );
  }
}