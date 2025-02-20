import 'package:flutter/material.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: utils.Dimensions.font16,
            fontWeight: FontWeight.w600,
            foreground: Paint()..shader = LinearGradient(
              colors: [
                const Color(0xff020238), // Deep navy blue
                const Color(0xff03034d), // Slightly lighter navy blue
              ],
            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
        SizedBox(height: utils.Dimensions.height8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(utils.Dimensions.radius12),
            gradient: LinearGradient(
              colors: [
                isFocused ? const Color(0xff020238) : const Color(0xff020238).withAlpha(26), // 0.1 opacity
                isFocused ? const Color(0xffF66000) : const Color(0xffF66000).withAlpha(26), // 0.1 opacity
              ],
            ),
          ),
          padding: const EdgeInsets.all(1.5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(utils.Dimensions.radius12 - 1),
            ),
            child: Focus(
              onFocusChange: (focused) {
                setState(() {
                  isFocused = focused;
                });
              },
              child: TextFormField(
                controller: widget.controller,
                obscureText: widget.obscureText,
                validator: widget.validator,
                keyboardType: widget.keyboardType,
                enabled: widget.enabled,
                style: TextStyle(
                  fontSize: utils.Dimensions.font14,
                  color: const Color(0xff1F1D2B),
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: const Color(0xff999999),
                    fontSize: utils.Dimensions.font14,
                  ),
                  prefixIcon: widget.prefixIcon != null 
                    ? Icon(
                        widget.prefixIcon,
                        color: isFocused ? const Color(0xffF66000) : const Color(0xff999999),
                        size: utils.Dimensions.font20,
                      ) 
                    : null,
                  suffixIcon: widget.suffixIcon,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: utils.Dimensions.width20,
                    vertical: utils.Dimensions.height16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
