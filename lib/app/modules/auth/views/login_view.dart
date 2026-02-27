import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/modules/auth/controllers/auth_controller.dart';
import 'package:antarkanma_courier/app/widgets/custom_input_field.dart';
import 'package:antarkanma_courier/app/widgets/custom_button.dart';
import 'package:antarkanma_courier/theme.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.height20),
          child: Column(
            children: [
              SizedBox(height: Dimensions.height40),
              header(),
              SizedBox(height: Dimensions.height40),
              loginForm(),
              SizedBox(height: Dimensions.height30),
              loginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Column(
      children: [
        Image.asset(
          'assets/Logo_AntarkanmaNoBg.png',
          height: Dimensions.height80,
          fit: BoxFit.contain,
        ),
        SizedBox(height: Dimensions.height20),
        Text(
          'Selamat Datang',
          style: primaryTextStyle.copyWith(
            fontSize: Dimensions.font24,
            fontWeight: semiBold,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        Text(
          'Silahkan masuk untuk melanjutkan',
          style: subtitleTextStyle.copyWith(
            fontSize: Dimensions.font16,
          ),
        ),
      ],
    );
  }

  Widget loginForm() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor2,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(Dimensions.height20),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            CustomInputField(
              label: 'Email atau Nomor HP',
              hintText: 'Masukkan email atau nomor HP',
              controller: controller.emailController,
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email atau nomor HP tidak boleh kosong';
                }
                return null;
              },
            ),
            SizedBox(height: Dimensions.height15),
            CustomInputField(
              label: 'Password',
              hintText: 'Masukkan password',
              controller: controller.passwordController,
              icon: Icons.lock_outline,
              initialObscureText: true,
              showVisibilityToggle: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget loginButton() {
    return Obx(
      () => CustomButton(
        text: 'Masuk',
        isLoading: controller.isLoading.value,
        backgroundColor: logoColorSecondary,
        onPressed: () {
          if (controller.formKey.currentState!.validate()) {
            controller.login();
          }
        },
      ),
    );
  }
}
