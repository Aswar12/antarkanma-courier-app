// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import '../controllers/splash_controller.dart';
import 'dart:math' as math;

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: logoColor,
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff0d2841),
                    Color(0xff0a1f35),
                    Color(0xff071829),
                  ],
                ),
              ),
            ),

            // Decorative circles
            const Positioned(
              top: -80,
              right: -80,
              child: _DecorativeCircle(size: 280, opacity: 0.07),
            ),
            const Positioned(
              bottom: -60,
              left: -60,
              child: _DecorativeCircle(size: 240, opacity: 0.06),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: -40,
              child: const _DecorativeCircle(size: 150, opacity: 0.04),
            ),

            // Grid pattern overlay
            const Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),

            // Speed lines decoration (courier theme)
            const Positioned(
              left: 0,
              top: 300,
              child: _SpeedLines(),
            ),

            // Main content
            SafeArea(
              child: Obx(
                () => AnimatedOpacity(
                  opacity: controller.isInitializing.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _AnimatedLogo(),

                        SizedBox(height: Dimensions.height32),

                        // App name
                        Text(
                          'AntarkanMa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Dimensions.font24,
                            fontFamily: 'PalanquinDark',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),

                        SizedBox(height: Dimensions.height8),

                        // Subtitle - courier specific
                        Text(
                          'KURIR APP',
                          style: TextStyle(
                            color: logoColorSecondary.withValues(alpha: 0.9),
                            fontSize: Dimensions.font14,
                            fontFamily: 'PalanquinDark',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 4.0,
                          ),
                        ),

                        SizedBox(height: Dimensions.height48),

                        const _AnimatedLoadingDots(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom brand tagline
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Antar cepat, sampai tepat',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: Dimensions.font12,
                    fontFamily: 'PalanquinDark',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Speed lines decoration for courier feel
class _SpeedLines extends StatelessWidget {
  const _SpeedLines();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.06,
      child: Column(
        children: List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            width: 60 + (index * 20.0),
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xffFF6600),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

/// Animated logo with pulse effect
class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffFF6600)
                          .withValues(alpha: _glowAnim.value * 0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Logo container
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffFF6600)
                          .withValues(alpha: _glowAnim.value * 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/icon_courier_nobg.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.delivery_dining_rounded,
                        color: Color(0xffFF6600),
                        size: 64,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated loading dots
class _AnimatedLoadingDots extends StatefulWidget {
  const _AnimatedLoadingDots();

  @override
  State<_AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<_AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final progress = (_controller.value - delay).clamp(0.0, 0.6) / 0.6;
            final bounce = math.sin(progress * math.pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -10 * bounce),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0
                        ? const Color(0xffFF6600)
                        : index == 1
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xffFF6600).withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Decorative circle widget
class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}

/// Subtle grid pattern painter
class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
