import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;
import '../../../../theme.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: primaryGradient,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 1500),
                child: SizedBox(
                  width: utils.Dimensions.width150,
                  height: utils.Dimensions.height150,
                  child: Image.asset(
                    'assets/Logo_AntarkanmaNoBg.png',
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.error_outline,
                        color: alertColor,
                        size: utils.Dimensions.iconSize24,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: utils.Dimensions.height32),
              // Loading Indicator
              SizedBox(
                width: utils.Dimensions.width40,
                height: utils.Dimensions.height40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(backgroundColor1),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: utils.Dimensions.height16),
              // Version Text
              Text(
                'Version 1.0.0',
                style: secondaryTextStyle.copyWith(
                  fontSize: utils.Dimensions.font14,
                  color: backgroundColor1.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
