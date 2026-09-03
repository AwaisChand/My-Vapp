import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../res/components/brand_logo.dart';
import '../../view_models/auth_view_model/auth_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthViewModel>();
    authProvider.checkLoginStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthScreenBackground.bottomColor,
      body: LoaderBackground(
        child: Center(
          child: WebLoaderStage(
            stageSize: MediaQuery.sizeOf(context).width < 360 ? 140 : 160,
            showOrbit: true,
            animate: true,
          ),
        ),
      ),
    );
  }
}
