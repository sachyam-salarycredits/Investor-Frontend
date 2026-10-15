import 'dart:convert';

import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CashfreeKycData {
  String frontUri;
  String backUri;
  String selfieUri;
  Map<String, dynamic>? frontFields;
  Map<String, dynamic>? backFields;
  int faceMatchScore;
  String livenessScore;
  bool live;

  CashfreeKycData({
    required this.frontUri,
    required this.backUri,
    required this.selfieUri,
    this.frontFields,
    this.backFields,
    this.faceMatchScore = 0,
    this.livenessScore = '0',
    this.live = false,
  });
}

class CashfreeKycSession {
  static var name = 'fullName';
  static var gender = 'gender';
  static var dob = 'dateOfBirth';
  static var aadhaar = 'aadharCardNumber';
  static var address = 'address';

  static Future<Map<String, dynamic>?> _postImage(
    BuildContext context,
    String url,
    String filePath,
    String fieldName,
  ) async {
    final apiClient = APICalling.getApiClient(context: context);
    final file = await http.MultipartFile.fromPath(fieldName, filePath);
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll({
      'Authorization': apiClient.getToken(),
    });
    request.files.add(file);
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (body.isEmpty) return null;
    final decoded = json.decode(body);
    if (decoded['statusCode'] == '200' && decoded['data'] != null) {
      return Map<String, dynamic>.from(decoded['data']);
    }
    return null;
  }

  static Future<CashfreeKycData?> runKycFlow(
    BuildContext context, {
    required String frontPath,
    required String backPath,
    required String selfiePath,
  }) async {
    final front = await _postImage(
      context,
      APIUrls.kycAadhaarOcrFront,
      frontPath,
      'image',
    );
    if (front == null) return null;

    final back = await _postImage(
      context,
      APIUrls.kycAadhaarOcrBack,
      backPath,
      'image',
    );
    if (back == null) return null;

    final liveness = await _postImage(
      context,
      APIUrls.kycFaceLiveness,
      selfiePath,
      'image',
    );

    final match = await _postMatch(
      context,
      selfiePath,
      frontPath,
    );

    final matchScore = match?['facematchScore'] ?? 0;
    return CashfreeKycData(
      frontUri: frontPath,
      backUri: backPath,
      selfieUri: selfiePath,
      frontFields: front,
      backFields: back,
      faceMatchScore: matchScore is int ? matchScore : int.tryParse('$matchScore') ?? 0,
      livenessScore: liveness?['livenessScore']?.toString() ?? '0',
      live: liveness?['live'] == true,
    );
  }

  static Future<Map<String, dynamic>?> _postMatch(
    BuildContext context,
    String selfiePath,
    String referencePath,
  ) async {
    final apiClient = APICalling.getApiClient(context: context);
    final request = http.MultipartRequest('POST', Uri.parse(APIUrls.kycFaceMatch));
    request.headers.addAll({
      'Authorization': apiClient.getToken(),
    });
    request.files.add(await http.MultipartFile.fromPath('selfie', selfiePath));
    request.files.add(
      await http.MultipartFile.fromPath('reference', referencePath),
    );
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (body.isEmpty) return null;
    final decoded = json.decode(body);
    if (decoded['statusCode'] == '200' && decoded['data'] != null) {
      return Map<String, dynamic>.from(decoded['data']);
    }
    return null;
  }
}
