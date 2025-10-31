import 'package:flutter/material.dart';
import 'success_screen.dart'; // Import for navigation

// Global avatar selection
String _selectedAvatar = '🙂'; // default avatar
final List<String> _avatars = ['😎', '🚀', '🐉', '🌈', '🦸‍♂️'];

class AnimatedFieldWrapper extends StatefulWidget {
  final Widget child;
  final bool isValid;
  final bool isInvalid;
  final String tooltipMessage;

  const AnimatedFieldWrapper({
    super.key,
    required this.child,
    required this.isValid,
    required this.isInvalid,
    required this.tooltipMessage,
  });

  @override
  State<AnimatedFieldWrapper> createState() => _AnimatedFieldWrapperState();
}

class _AnimatedFieldWrapperState extends State<AnimatedFieldWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _bounceAnimation;

  bool _showTooltip = false; // tooltip visibility

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

    _bounceAnimation = Tween(begin: 0.0, end: -10.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedFieldWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isInvalid && !oldWidget.isInvalid) {
      _controller.forward(from: 0); // shake animation
      _showTooltipBubble(); // show tooltip above field
    } else if (widget.isValid && !oldWidget.isValid) {
      _controller.forward(from: 0); // bounce animation
    }
  }

  void _showTooltipBubble() {
    setState(() => _showTooltip = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showTooltip = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        if (_showTooltip)
          Positioned(
            top: -35,
            child: AnimatedOpacity(
              opacity: _showTooltip ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info, color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      widget.tooltipMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = widget.isInvalid
                ? _shakeAnimation.value
                : widget.isValid
                    ? _bounceAnimation.value
                    : 0.0;

            return Transform.translate(
              offset: Offset(offset, 0),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  child!,
                  if (widget.isValid)
                    const Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Icon(Icons.check_circle,
                          color: Colors.green, size: 24),
                    ),
                ],
              ),
            );
          },
          child: widget.child,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  double _passwordStrength = 0;
  String _passwordFeedback = '';
  Color _strengthColor = Colors.red;
  List<String> _achievements = [];
  double _progress = 0.0;
  String _progressMessage = '';

  // Progress Tracker
  void _updateProgress() {
    int completed = 0;
    if (_nameController.text.isNotEmpty) completed++;
    if (_emailController.text.isNotEmpty) completed++;
    if (_dobController.text.isNotEmpty) completed++;
    if (_passwordController.text.isNotEmpty) completed++;

    double progress = completed / 4;
    String message = '';
    if (progress == 0.25) message = 'Nice start! Keep going! 💪';
    if (progress == 0.5) message = 'Halfway there! 🔥';
    if (progress == 0.75) message = 'Almost done! 🌟';
    if (progress == 1.0) message = 'All set! Ready for adventure! 🎉';

    setState(() {
      _progress = progress;
      _progressMessage = message;
    });
  }

  // Password Strength Check
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

    if (password.length >= 6) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25;

    if (strength > 0.75 &&
        !_achievements.contains('Strong Password Master')) {
      _achievements.add('Strong Password Master');
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

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
    _updateProgress();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
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

                // ✅ Progress Bar
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
                AnimatedFieldWrapper(
                  isValid: _nameController.text.isNotEmpty,
                  isInvalid: _nameController.text.isEmpty,
                  tooltipMessage: 'Please enter your adventure name!',
                  child: _buildTextField(
                    controller: _nameController,
                    label: 'Adventure Name',
                    icon: Icons.person,
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'What should we call you?'
                            : null,
                    onChanged: (_) => _updateProgress(),
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field
                AnimatedFieldWrapper(
                  isValid: _emailController.text.contains('@'),
                  isInvalid: _emailController.text.isNotEmpty &&
                      !_emailController.text.contains('@'),
                  tooltipMessage: 'Enter a valid email like hero@quest.com!',
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'We need your email for adventure updates!';
                      }
                      if (!value.contains('@')) {
                        return 'Oops! That doesn’t look right.';
                      }
                      return null;
                    },
                    onChanged: (_) => _updateProgress(),
                  ),
                ),
                const SizedBox(height: 20),

                // DOB Field
                AnimatedFieldWrapper(
                  isValid: _dobController.text.isNotEmpty,
                  isInvalid: false,
                  tooltipMessage: 'Tap to pick your adventure start date!',
                  child: TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'When did your adventure begin?'
                            : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                AnimatedFieldWrapper(
                  isValid: _passwordStrength > 0.75,
                  isInvalid: _passwordController.text.isNotEmpty &&
                      _passwordStrength < 0.25,
                  tooltipMessage: 'Try making your password stronger!',
                  child: TextFormField(
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
                          setState(() =>
                              _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                    ),
                    onChanged: _checkPasswordStrength,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Every adventurer needs a secret password!';
                      }
                      if (value.length < 6) {
                        return 'Make it stronger! At least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _passwordStrength,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  color: _strengthColor,
                  borderRadius: BorderRadius.circular(5),
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
                          if (emoji == '🐉' &&
                              !_achievements.contains('Dragon Master')) {
                            _achievements.add('Dragon Master');
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.deepPurple[100] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 32)),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Adventure',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch,
                                  color: Colors.white),
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

  // Helper Builder
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
