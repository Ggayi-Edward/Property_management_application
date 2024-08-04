import 'dart:async';
import 'package:propertysmart2/export/file_exports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _scaleUpAnimation;
  late Animation<double> _scaleDownAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 6), // Total duration of 6 seconds
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn), // First 1.5 seconds for fade-in
    ));

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut), // Last 1.5 seconds for fade-out
    ));

    _scaleUpAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeInOut), // First 1.5 seconds for scaling up
    ));

    _scaleDownAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeInOut), // Last 1.5 seconds for scaling down
    ));

    _controller.forward();

    // Wait for the animations to complete and then navigate to the next page
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccountPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _controller.value <= 0.25
                  ? _fadeInAnimation.value
                  : (_controller.value >= 0.75 ? _fadeOutAnimation.value : 1.0), // Fully visible for the middle 3 seconds
              child: Transform.scale(
                scale: _controller.value <= 0.25
                    ? _scaleUpAnimation.value
                    : (_controller.value >= 0.75 ? _scaleDownAnimation.value : 1.0), // Fully scaled for the middle 3 seconds
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/splashscreen.png',
                    fit: BoxFit.contain,
                    width: 340,
                    height: 340,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
