import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_login_button.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.redAccent;
  double _passwordStrengthVal = 0.0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthVal = 0.0;
      });
      return;
    }

    // Perhitungan kekuatan password sederhana
    bool hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasDigits = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    if (password.length < 6) {
      setState(() {
        _passwordStrength = 'Lemah';
        _passwordStrengthColor = Colors.redAccent;
        _passwordStrengthVal = 0.2;
      });
    } else if (password.length >= 6 && hasLetters && hasDigits && !hasSpecial) {
      setState(() {
        _passwordStrength = 'Sedang';
        _passwordStrengthColor = Colors.orangeAccent;
        _passwordStrengthVal = 0.6;
      });
    } else if (password.length >= 8 && hasLetters && hasDigits && hasSpecial) {
      setState(() {
        _passwordStrength = 'Kuat';
        _passwordStrengthColor = Colors.greenAccent.shade400;
        _passwordStrengthVal = 1.0;
      });
    } else {
      setState(() {
        _passwordStrength = 'Sedang';
        _passwordStrengthColor = Colors.orangeAccent;
        _passwordStrengthVal = 0.5;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Konfirmasi password tidak cocok dengan password');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? "Gagal mendaftar.");
    }
  }

  Future<void> _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();
    
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
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
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16), // space for back button
                          Text(
                            "Create Your Account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Join us and simplify your workday",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Section (White Rounded Container)
            Expanded(
              flex: 7,
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
                          'Sign up',
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
                              "Already Have An Account? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Login',
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
                              // Name
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Enter your full name',
                                icon: Icons.person_outline,
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Nama lengkap tidak boleh kosong';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Email
                              _buildTextField(
                                controller: _emailController,
                                hint: 'Enter your email address',
                                icon: Icons.email_outlined,
                                isDark: isDark,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Format email tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password
                              _buildTextField(
                                controller: _passwordController,
                                hint: 'Password',
                                icon: Icons.lock_outline,
                                isDark: isDark,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                                  if (value.length < 6) return 'Password minimal 6 karakter';
                                  return null;
                                },
                              ),
                              
                              if (_passwordStrength.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: _passwordStrengthVal,
                                        color: _passwordStrengthColor,
                                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                        minHeight: 4,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _passwordStrength,
                                      style: TextStyle(color: _passwordStrengthColor, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Confirm Password
                              _buildTextField(
                                controller: _confirmPasswordController,
                                hint: 'Confirm your password',
                                icon: Icons.lock_outline,
                                isDark: isDark,
                                isPassword: true,
                                obscureText: _obscureConfirmPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              // Register Button
                              CustomButton(
                                text: 'Sign Up',
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
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
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

