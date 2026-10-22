import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/theme/app_colors.dart';
import 'package:peerbridge/theme/app_text_styles.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanVerification extends StatefulWidget {
  const PanVerification({Key? key}) : super(key: key);

  @override
  _PanVerificationState createState() => _PanVerificationState();
}

class _PanVerificationState extends State<PanVerification> {
  bool isPanError = false;
  var panController = TextEditingController();
  bool _isLoading = false;
  final FocusNode _panFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _panFocus.addListener(() => setState(() {}));
    SetRegistrationStatus();
    resetOnbaordingScreenStatus();
  }

  Future<void> resetOnbaordingScreenStatus() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('show_onboarding', true);
  }

  Future<void> SetRegistrationStatus() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('set_registrationStatus', true);
  }

  @override
  void dispose() {
    panController.dispose();
    _panFocus.dispose();
    super.dispose();
  }

  bool checkValidation() {
    if (!panController.text.isPanValid || panController.text == '') {
      setState(() {
        isPanError = true;
      });
      return false;
    }
    return true;
  }

  void submitBtnTap() async {
    if (checkValidation()) {
      setState(() {
        _isLoading = true;
      });
      var panDetail = await context
          .read<AppStateProvider>()
          .getPanDetails(panController.text, '');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (panDetail != null) {
        context.pushNamed(RoutesName.PersonalDetail);
      }
    }
  }

  void _openTerms() {
    if (Utils.isWeb) {
      Utils.launchURL(APIUrls.termsCondition);
    } else {
      context.pushNamed(RoutesName.TermsWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _CircleButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => context.pop(),
                          ),
                          const Spacer(),
                          _CircleButton(
                            icon: Icons.question_mark_rounded,
                            onTap: () => Utils.launchSupportCall(),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 36, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Enter your PAN to\ncreate an account',
                                style: AppTextStyles.semiBold(30)
                                    .copyWith(height: 1.2, letterSpacing: -0.3),
                              ),
                              const SizedBox(height: 28),
                              _PlainField(
                                controller: panController,
                                focusNode: _panFocus,
                                hint: 'ABCDE1234F',
                                hasError: isPanError,
                                maxLength: 10,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Za-z0-9]')),
                                ],
                                onChanged: (input) {
                                  setState(() {
                                    isPanError = false;
                                  });
                                },
                              ),
                              if (isPanError) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Enter a valid PAN, like ABCDE1234F',
                                  style: AppTextStyles.regular(13,
                                      color: AppColors.error),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          style: AppTextStyles.regular(13.5, color: AppColors.ink)
                              .copyWith(height: 1.45),
                          children: [
                            const TextSpan(
                              text: 'By entering your PAN and tapping Next, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms & conditions',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _openTerms,
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _PillButton(
                              label: 'Log in',
                              filled: false,
                              onTap: () => context.pushNamed(RoutesName.Login),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PillButton(
                              label: 'Next',
                              filled: true,
                              onTap: submitBtnTap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xffF2F2F2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _PlainField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final bool hasError;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;

  const _PlainField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.focusNode,
    this.hasError = false,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final focused = focusNode?.hasFocus ?? false;
    final borderColor = hasError
        ? AppColors.error
        : focused
            ? AppColors.green
            : const Color(0xffD8D8D8);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      cursorColor: AppColors.green,
      style: AppTextStyles.medium(16),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: AppTextStyles.regular(16, color: const Color(0xffB0B0B0)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.greenDeep : const Color(0xffF2F2F2),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.semiBold(16,
                  color: filled ? Colors.white : AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
