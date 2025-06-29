import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:milkmate/utils/images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  void _navigateToHome(){
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void initState(){
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2)
      );

    _fadeAnimation =
    Tween<double>(begin: 0.0,end: 1.0).animate(CurvedAnimation(
      parent: _fadeController, 
      curve: Curves.easeIn
    ));

    Future.delayed(const Duration(milliseconds: 300),(){
      _fadeController.forward();
    });

  }

  @override
  void dispose(){
    _fadeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body:
      Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Lottie.asset(
              ANIMATON_SPLASH_SCREEN,
               width: 600,
               height: 600,
               repeat: false,
               onLoaded: (composition) {
                 Future.delayed(composition.duration, _navigateToHome);
               },
            ),

            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                '''




 MilkMate''',
                style: GoogleFonts.eduNswActFoundation(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}