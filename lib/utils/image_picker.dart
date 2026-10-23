import 'dart:io';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImgPicker {
  ImgPicker._();

  /// Open image gallery and pick an image
  static Future<XFile?> pickImageFromCamera() async {
    return await ImagePicker().pickImage(source: ImageSource.camera);
  }

  /// Camera photo used as-is. Signup selfie skips the crop screen.
  static Future<File?> pickFromCamera() async {
    var pickedFile = await pickImageFromCamera();
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  static Future<File?> pickAndCropFromCamera() async {
    var pickedFile = await pickImageFromCamera();
    if (pickedFile == null) return null;
    var croppedFile = await cropSelectedImage(pickedFile.path);
    if (croppedFile == null) return null;
    return croppedFile;
  }

  static Future<XFile?> pickImageFromGallery() async {
    return await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  static Future<File?> pickAndCropFromGallery() async {
    var pickedFile = await pickImageFromGallery();
    if (pickedFile == null) return null;
    var croppedFile = await cropSelectedImage(pickedFile.path);
    if (croppedFile == null) return null;
    return croppedFile;
  }

  /// Pick Image From Gallery and return a File
  static Future<File?> cropSelectedImage(String filePath) async {
    debugPrint(filePath);
    return await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: ColorsUtil.blueColor,
          toolbarWidgetColor: ColorsUtil.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: const IOSUiSettings(
        title: 'Crop Image',
        aspectRatioLockEnabled: true,
        minimumAspectRatio: 1.0,
        aspectRatioPickerButtonHidden: true,
      ),
    );
  }
}
