import 'dart:io';

import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/image_picker.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Camera-only selfie step before bank account details (registration).
/// Uploads selfie to S3 as the user's profile photo (no liveness).
class SelfieCaptureScreen extends StatefulWidget {
  const SelfieCaptureScreen({Key? key}) : super(key: key);

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  File? _selfieFile;
  bool _isCapturing = false;
  bool _isUploading = false;

  Future<void> _captureSelfie() async {
    if (_isCapturing || _isUploading) return;
    setState(() => _isCapturing = true);
    try {
      final file = await ImgPicker.pickAndCropFromCamera();
      if (!mounted) return;
      if (file != null) {
        setState(() => _selfieFile = file);
      }
    } catch (e) {
      if (mounted) {
        Utils.showToast(msg: 'Unable to open camera. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _continueToBankDetails() async {
    if (_selfieFile == null) {
      Utils.showToast(msg: 'Please take a selfie to continue.');
      return;
    }
    if (_isUploading) return;

    setState(() => _isUploading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.registrationSelfiePath, _selfieFile!.path);

    final ok = await context
        .read<AppStateProvider>()
        .uploadProfilePhoto(_selfieFile!.path);

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (!ok) {
      Utils.showToast(msg: 'Could not upload selfie. Please try again.');
      return;
    }

    context.pushNamed(RoutesName.BankDetail);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isUploading,
      child: Scaffold(
        backgroundColor: ColorsUtil.offWhite,
        body: PeerBridgeLoader(
          isLoading: _isUploading,
          child: SafeArea(
            child: Column(
              children: [
                Header(
                  isBackBtnVisible: true,
                  backOnPressed: () {
                    if (!_isUploading) context.pop();
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Take a selfie',
                          style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: ColorsUtil.blueColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This photo will be used as your profile picture. Please capture a clear photo of your face using the camera.',
                          style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontSize: 14,
                            color: ColorsUtil.lightBlack,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: GestureDetector(
                            onTap: (_isCapturing || _isUploading)
                                ? null
                                : _captureSelfie,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorsUtil.white,
                                border: Border.all(
                                  color: ColorsUtil.blueColor,
                                  width: 2,
                                ),
                                image: _selfieFile != null
                                    ? DecorationImage(
                                        image: FileImage(_selfieFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _selfieFile == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          size: 48,
                                          color: ColorsUtil.blueColor,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          _isCapturing
                                              ? 'Opening camera…'
                                              : 'Tap to capture',
                                          style: TextStyle(
                                            fontFamily: CustomFonts.nunito,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: ColorsUtil.blueColor,
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (_selfieFile != null) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: (_isCapturing || _isUploading)
                                ? null
                                : _captureSelfie,
                            child: Text(
                              'Retake selfie',
                              style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ColorsUtil.blueColor,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomButton(
                    titleStr: 'Continue',
                    isDisable:
                        _selfieFile == null || _isCapturing || _isUploading,
                    isLoader: _isUploading,
                    onPress: _continueToBankDetails,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
