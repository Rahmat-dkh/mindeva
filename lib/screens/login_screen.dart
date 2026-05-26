import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_login_button.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'main_navigation_screen.dart';

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
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? "Gagal masuk.");
    }
  }

  Future<void> _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();
    
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else if (mounted && authProvider.errorMessage != null && !authProvider.errorMessage!.contains('dibatalkan')) {
      _showErrorSnackBar(authProvider.errorMessage!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Section (Blue)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'MINDEVA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Let's Get You Set Up\nfor Success",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Organize your thoughts and track your emotional journey easily.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Section (White Rounded Container)
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't Have An Account? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email field
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: 14),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Masukkan format email yang valid';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email address',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey, size: 20),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Password field
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(fontSize: 14),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                                    if (value.length < 6) return 'Password minimal 6 karakter';
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Remember Me & Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (val) {
                                            setState(() {
                                              _rememberMe = val ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remember Me',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Login Button
                              CustomButton(
                                text: 'Login',
                                isLoading: authProvider.isLoading,
                                onTap: _submit,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or Continue With',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Social Login Buttons
                        SocialLoginButton(
                          text: 'Continue with Google',
                          icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.blue, size: 36),
                          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                          textColor: isDark ? Colors.white : Colors.black,
                          borderColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          onTap: _loginWithGoogle,
                        ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20), // Padding for keyboard
                      ],
                    ),
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

