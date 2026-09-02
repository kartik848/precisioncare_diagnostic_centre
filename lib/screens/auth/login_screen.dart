import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import '../home/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    setState(() {});
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: email,
      password: password,
    );

    if (success && mounted) {
      final user = authProvider.user;
      if (user != null) {
        context.read<BookingProvider>().fetchBookings(user.uid);
        context.read<ReportProvider>().fetchReports(user.uid);
        context.read<NotificationProvider>().fetchNotifications(user.uid);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3), // Soft soothing healthcare light pink
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. 3D AI GENERATED DOCTOR BITMOJI & BRAND BANNER
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFECDD3), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE11D48).withOpacity(0.18),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/3d/doctor_mascot.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFFECDD3), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/precisioncare_logo.jpeg',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        'PrecisionCare Diagnostics',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 13, color: Color(0xFFE11D48)),
                            SizedBox(width: 4),
                            Text(
                              'NABL Accredited • Pune Home Visits in 60 Mins',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. 3D BITMOJI FEATURE STRIP
                    Row(
                      children: [
                        Expanded(
                          child: _build3DFeaturePill(
                            imageAsset: 'assets/images/3d/female_doctor.jpg',
                            title: 'MD Doctors',
                            subtitle: 'Supervised',
                            tagColor: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _build3DFeaturePill(
                            imageAsset: 'assets/images/3d/fullbody_package.jpg',
                            title: 'Home Sample',
                            subtitle: 'In 60 Mins',
                            tagColor: const Color(0xFFEA580C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _build3DFeaturePill(
                            imageAsset: 'assets/images/3d/doc_pathologist.jpg',
                            title: 'NABL Lab',
                            subtitle: 'Fast Reports',
                            tagColor: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. MAIN LOGIN CARD
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFECDD3), width: 1.3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Patient Sign In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Access tests, reports & doctor prescriptions',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F3),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFECDD3)),
                                ),
                                child: const Icon(Icons.lock_person_rounded, size: 20, color: Color(0xFFE11D48)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Email Field
                          CustomTextField(
                            controller: _emailController,
                            label: 'Registered Email Address',
                            hint: 'e.g. rahul.sharma@gmail.com',
                            prefixIcon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password Field
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Account Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 4) {
                                return 'Password must be at least 4 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Quick Demo Fill Chips
                          Row(
                            children: [
                              const Text('Quick Test:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _fillDemoCredentials('kartik@test.com', 'password123'),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F3),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFECDD3)),
                                  ),
                                  child: const Text('kartik@test.com', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFBE123C))),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Sign In Button
                          CustomButton(
                            text: 'Sign In to Health Portal',
                            isLoading: authProvider.isLoading,
                            onPressed: _handleLogin,
                            icon: Icons.arrow_forward_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. REGISTER LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New to PrecisionCare? ",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            "Create Patient Account",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 5. SECURITY GUARANTEE FOOTER
                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: Color(0xFF94A3B8)),
                          SizedBox(width: 5),
                          Text(
                            '256-Bit SSL Encrypted & HIPAA Compliant Health Records',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build3DFeaturePill({
    required String imageAsset,
    required String title,
    required String subtitle,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCE7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: tagColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
