import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/warm_scaffold.dart';

class CreateAccountScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final VoidCallback onBack;
  final void Function(String name, String email) onCreate;

  const CreateAccountScreen({
    super.key,
    this.initialName = '',
    this.initialEmail = '',
    required this.onBack,
    required this.onCreate,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onCreate(
      _nameCtrl.text.trim().isEmpty ? 'Azeem' : _nameCtrl.text.trim(),
      _emailCtrl.text.trim().isEmpty ? 'azeem@example.com' : _emailCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      child: SafeArea(
        child: Column(
          children: [
            TopLineBar(
              left: GestureDetector(
                onTap: widget.onBack,
                child: const AppVectorIcon(AppIconType.chevronLeft, size: 21),
              ),
              title: 'Create account',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroHeading(
                      plainLine: 'Make space for',
                      emphasizedLine: 'what matters.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your plans, reminders and memories stay yours.',
                      style: AppTheme.inter(
                        size: 13.5,
                        color: AppColors.mutedText,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _FieldLabel('Full name'),
                    _AuthTextField(
                      controller: _nameCtrl,
                      hint: 'Your name',
                      icon: AppIconType.user,
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel('Email address'),
                    _AuthTextField(
                      controller: _emailCtrl,
                      hint: 'name@example.com',
                      icon: AppIconType.mail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel('Password'),
                    _AuthTextField(
                      controller: _passCtrl,
                      hint: '••••••••••••',
                      icon: AppIconType.lock,
                      obscure: true,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const AppVectorIcon(
                          AppIconType.shieldCheck,
                          size: 18,
                          color: AppColors.indigo,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Private, secure and under your control',
                            style: AppTheme.inter(
                              size: 10.5,
                              color: const Color(0xFF7A7D96),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 6, 23, 24),
              child: Column(
                children: [
                  PrimaryButton(label: 'Create account', onTap: _submit),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'or continue with',
                      style: AppTheme.inter(
                        size: 10.5,
                        color: const Color(0xFF9B9AA8),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(label: 'G   Google', onTap: _submit),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _SocialButton(label: '●   Apple', onTap: _submit),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTheme.inter(size: 11.5, weight: FontWeight.w700),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final AppIconType icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: AppShadows.choose,
      ),
      child: Row(
        children: [
          AppVectorIcon(icon, size: 18, color: const Color(0xFFAAA9B5)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: AppTheme.inter(size: 12.5, color: AppColors.navy),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTheme.inter(size: 12, color: const Color(0xFFAAA9B5)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SocialButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE9E8ED)),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.inter(size: 12, weight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
