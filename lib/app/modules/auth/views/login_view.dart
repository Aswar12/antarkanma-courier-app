import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/modules/auth/controllers/auth_controller.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;
import 'package:antarkanma_courier/app/widgets/custom_text_field.dart';
import 'package:antarkanma_courier/theme.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor2, // Light background
      body: Stack(
        children: [
          // Background Design
          Positioned(
            top: -utils.Dimensions.height120,
            right: -utils.Dimensions.width40,
            child: Container(
              width: utils.Dimensions.height200,
              height: utils.Dimensions.height200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryGradient[0].withAlpha(51), // 0.2 opacity
                    secondaryGradient[1].withAlpha(38), // 0.15 opacity
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -utils.Dimensions.height100,
            left: -utils.Dimensions.width20,
            child: Container(
              width: utils.Dimensions.height180,
              height: utils.Dimensions.height180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    secondaryGradient[0].withAlpha(38), // 0.15 opacity
                    primaryGradient[1].withAlpha(26), // 0.1 opacity
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(utils.Dimensions.height24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: utils.Dimensions.height40),
                  // Logo with gradient background
                  Center(
                    child: Container(
                      height: utils.Dimensions.height120,
                      width: utils.Dimensions.height120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            backgroundColor1,
                            backgroundColor2,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryGradient[0].withAlpha(51), // Orange shadow
                            blurRadius: 20,
                            offset: const Offset(5, 5),
                          ),
                          BoxShadow(
                            color: primaryGradient[0].withAlpha(51), // Navy shadow
                            blurRadius: 20,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(utils.Dimensions.height16),
                      child: Image.asset(
                        'assets/Logo_AntarkanmaNoBg.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: utils.Dimensions.height24),
                  // Welcome Text with Gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: brandGradient,
                    ).createShader(bounds),
                    child: Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: utils.Dimensions.font24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: utils.Dimensions.height8),
                  Text(
                    'Silakan masuk untuk melanjutkan',
                    style: TextStyle(
                      fontSize: utils.Dimensions.font16,
                      color: secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: utils.Dimensions.height40),
                  // Login Form
                  Container(
                    padding: EdgeInsets.all(utils.Dimensions.height20),
                    decoration: BoxDecoration(
                      color: backgroundColor1,
                      borderRadius: BorderRadius.circular(utils.Dimensions.radius20),
                      boxShadow: [
                        BoxShadow(
                          color: secondaryGradient[0].withAlpha(26), // Subtle orange
                          blurRadius: 20,
                          offset: const Offset(5, 5),
                        ),
                        BoxShadow(
                          color: primaryGradient[0].withAlpha(26), // Subtle navy
                          blurRadius: 20,
                          offset: const Offset(-5, -5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: controller.emailController,
                            label: 'Email atau Nomor HP',
                            hint: 'Masukkan email atau nomor HP',
                            prefixIcon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email atau nomor HP tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: utils.Dimensions.height16),
                          Obx(() => CustomTextField(
                            controller: controller.passwordController,
                            label: 'Password',
                            hint: 'Masukkan password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: controller.isPasswordHidden.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: subtitleColor,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              return null;
                            },
                          )),
                          SizedBox(height: utils.Dimensions.height8),
                          // Lupa Password with hover effect
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: logoColorSecondary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: utils.Dimensions.width16,
                                  vertical: utils.Dimensions.height8,
                                ),
                              ),
                              child: Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  fontSize: utils.Dimensions.font14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: utils.Dimensions.height24),
                          // Login Button with Gradient and Loading State
                          Obx(() => Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: brandGradient,
                              ),
                              borderRadius: BorderRadius.circular(utils.Dimensions.radius12),
                              boxShadow: [
                                BoxShadow(
                                  color: secondaryGradient[0].withAlpha(77), // 0.3 opacity
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                                BoxShadow(
                                  color: primaryGradient[0].withAlpha(51), // 0.2 opacity
                                  blurRadius: 8,
                                  offset: const Offset(-2, -2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.login(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(utils.Dimensions.radius12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: utils.Dimensions.height16,
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Masuk',
                                          style: TextStyle(
                                            fontSize: utils.Dimensions.font16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: utils.Dimensions.width8),
                                        const Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
