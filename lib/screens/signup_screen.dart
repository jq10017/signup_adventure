import 'package:flutter/material.dart';
import 'success_screen.dart'; // Import for navigation

String _selectedAvatar = '🙂'; // default avatar
final List<String> _avatars = ['😎', '🚀', '🐉', '🌈', '🦸‍♂️'];

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  double _passwordStrength = 0;
  String _passwordFeedback = '';
  Color _strengthColor = Colors.red;

  List<String> _achievements = [];
  double _progress = 0.0;
  String _progressMessage = '';

  // Update progress bar based on completed fields
  void _updateProgress() {
    int completed = 0;
    if (_nameController.text.isNotEmpty) completed++;
    if (_emailController.text.isNotEmpty) completed++;
    if (_dobController.text.isNotEmpty) completed++;
    if (_passwordController.text.isNotEmpty) completed++;

    double progress = completed / 4;

    String message;
    if (progress == 0.25) {
      message = 'Nice start! Keep going! 💪';
    } else if (progress == 0.5) {
      message = 'Halfway there! 🔥';
    } else if (progress == 0.75) {
      message = 'Almost done! 🌟';
    } else if (progress == 1.0) {
      message = 'All set! Ready for adventure! 🎉';
    } else {
      message = '';
    }

    setState(() {
      _progress = progress;
      _progressMessage = message;
    });
  }

  // Check password strength and assign achievements
  void _checkPasswordStrength(String password) {
    double strength = 0;

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordFeedback = '';
        _strengthColor = Colors.red;
      });
      return;
    }

    // Basic strength logic
    if (password.length >= 6) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25;

    // Achievements
    if (strength > 0.75 && !_achievements.contains('Strong Password Master')) {
      _achievements.add('Strong Password Master');
    }
    if (_nameController.text.length > 10 &&
        !_achievements.contains('Creative Name Hero')) {
      _achievements.add('Creative Name Hero');
    }

    Color color;
    String feedback;
    if (strength <= 0.25) {
      color = Colors.red;
      feedback = 'Weak';
    } else if (strength <= 0.5) {
      color = Colors.orange;
      feedback = 'Fair';
    } else if (strength <= 0.75) {
      color = Colors.yellow[700]!;
      feedback = 'Good';
    } else {
      color = Colors.green;
      feedback = 'Strong';
    }

    setState(() {
      _passwordStrength = strength;
      _passwordFeedback = feedback;
      _strengthColor = color;
    });

    _updateProgress();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Date picker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      _updateProgress();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text,
              avatar: _selectedAvatar,
              achievements: _achievements,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.deepPurple[800]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your adventure profile!',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Progress Tracker
                LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  backgroundColor: Colors.red[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(Colors.red, Colors.green, _progress)!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _progressMessage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.lerp(Colors.red, Colors.green, _progress),
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'What should we call you on this adventure?';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateProgress(),
                ),
                const SizedBox(height: 20),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'We need your email for adventure updates!';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Oops! That doesn\'t look like a valid email';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateProgress(),
                ),
                const SizedBox(height: 20),

                // DOB Field
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon:
                        const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'When did your adventure begin?';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Secret Password',
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Every adventurer needs a secret password!';
                    }
                    if (value.length < 6) {
                      return 'Make it stronger! At least 6 characters';
                    }
                    return null;
                  },
                  onChanged: _checkPasswordStrength,
                ),
                const SizedBox(height: 20),

                // Password Strength
                LinearProgressIndicator(
                  value: _passwordStrength,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  color: _strengthColor,
                ),
                const SizedBox(height: 8),
                Text(
                  _passwordFeedback,
                  style: TextStyle(
                    color: _strengthColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar Picker
                const Text(
                  'Choose Your Adventure Avatar:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  children: _avatars.map((emoji) {
                    final bool isSelected = _selectedAvatar == emoji;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = emoji;
                          if (_selectedAvatar == '🐉' &&
                              !_achievements.contains('Dragon Master')) {
                            _achievements.add('Dragon Master');
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple[100] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Submit Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Adventure',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for standard text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
