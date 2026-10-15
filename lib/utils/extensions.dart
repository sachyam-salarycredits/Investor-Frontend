import 'package:peerbridge/utils/colours_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

extension StringValidator on String? {
  // Email Validation //
  bool get isEmailValid => RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(this ?? '');

  //r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")

  // PAN number validation for 10-character length has to be checked.
  // Initial 5 characters should be alphabets
  // 6-9 characters should be numeric
  // 10th character should be alphabet
  bool get isPanValid =>
      RegExp("[A-Z]{5}[0-9]{4}[A-Z]{1}").hasMatch(this ?? '');

  // Only numbers allowed
  // 10 integers should be allowed. Less than or greater than 10 integers should not be accepted.
  // Mobile numbers should start with  6, 7, 8, 9
  bool get isMobileNumberValid => RegExp(r"^[6-9]\d{9}$").hasMatch(this ?? '');

  // IFSC Code Format:
  // 1] Exact length should be 11
  // 2] First 4 alphabets
  // 3] Fifth character is 0 (zero)
  // 4] Last six characters (usually numeric, but can be alphabetic)
  bool get isIFSCValid =>
      RegExp(r"^[A-Z]{4}[0][A-Z0-9]{6}$").hasMatch(this ?? '');

  // BANK account validation:
  // The bank should have 9-18 digits
  bool get isBAccountValid => RegExp("[0-9]{9,18}").hasMatch(this ?? '');

  // Full name validation
  bool get isFullNameValid =>
      RegExp(r"^([a-zA-Z]{2,}\s[a-zA-z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)")
          .hasMatch(this ?? '');

  // Aadhar validation:
  // The first part specifies that the first digit is between 2 and 9.
  // The second part specifies that the remaining 11 digits should between 0 and 9.
  bool get isAdharCardValid =>
      RegExp(r"^[2-9]{1}[0-9]{11}$").hasMatch(this ?? '');

  //Multiple of thousand validation
  bool get isMultipleThousandValid => this.doubleValue() % 1000 == 0;

  // UPI ID Validation
  bool get isUpiIdValid =>
      RegExp(r"^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{3,64}").hasMatch(this ?? '');

  // Indian Pincode validation
  bool get isPincodeValid => RegExp(r"^[1-9][0-9]{5}$").hasMatch(this ?? '');

  bool get isNullEmptyOrWhitespace =>
      this == null || (this ?? '').isEmpty || (this ?? '').trim().isEmpty;

  bool get isValidChequeNumber => RegExp(r"^[0-9]{6}$").hasMatch(this ?? '');

  bool isFollowedBySpace() {
    if (this == null || this == '') {
      return false;
    }
    return this?[0] == ' ';
  }
}
// extension CapExtension on String {
//   String get inCaps => '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
//   String get allInCaps => this.toUpperCase();
//   String get capitalizeFirstofEach => this.split(" ").map((str) => str.inCaps).join(" ");
// }

extension StringToDouble on String? {
  double doubleValue() {
    try {
      return double.parse(this ?? '');
    } catch (e) {
      print(e);
    }
    return 0;
  }

  String commaAddedValue() {
    if (this == null || this == "") {
      return '0';
    }
    final value = this.doubleValue();
    var format =
        NumberFormat.currency(locale: 'en_IN', symbol: "", decimalDigits: 0);
    return format.format(value);
  }
}

extension DoubleToString on double? {
  String commaAddedValue({digit = 0}) {
    if (this == null || this == 0) {
      return '0';
    }
    var format = NumberFormat.currency(
        locale: 'en_IN', symbol: "", decimalDigits: digit);
    return format.format((this ?? 0.0));
  }
}

extension IntToString on int {
  String commaAddedValue() {
    if (this == 0) {
      return '0';
    }
    var format =
        NumberFormat.currency(locale: 'en_IN', symbol: "", decimalDigits: 0);
    return format.format((this).round());
  }
}

extension StringDate on String? {
  String getSimpleDateStr() {
    if (this == null || this == '') {
      return '';
    }
    var date = DateTime.parse(this ?? '');
    return DateFormat('dd-MM-yyyy').format(date);
  }

  DateTime getDateFromString() {
    if (this == null || this == '') {
      return DateTime.now();
    }
    return DateTime.parse(this ?? '');
  }

  DateTime getReverseNormalDate() {
    if (this == null || this == '') {
      return DateTime.now();
    }
    return new DateFormat("dd-MM-yyyy").parse(this ?? '');
  }
}

extension StringFrequency on String {
  String toFrequency() {
    return this.split(" ").map((e) => e.isNotEmpty ? e[0] : e).join();
  }
}

extension StatusString on String? {
  String removeSpace() {
    return this?.replaceAll(' ', '') ?? "";
  }

  String getStatusStr() {
    return this?.removeSpace() == '1'
        ? 'Complete'
        : this?.removeSpace() == '2'
            ? 'Incomplete'
            : 'Pending';
  }

  Color getStatusColor() {
    return this?.replaceAll(' ', '') == '1'
        ? ColorsUtil.blueColorText
        : ColorsUtil.darkOrange;
  }
}

extension TimeStamp on int? {
  String getSimpleDateStr() {
    if (this == null || this == 0) {
      return '';
    }
    // var date = DateTime.fromMillisecondsSinceEpoch(this!);
    var date = new DateTime.fromMicrosecondsSinceEpoch(this! * 1000);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String getReverseSimpleDateStr() {
    if (this == null || this == 0) {
      return '';
    }
    // var date = DateTime.fromMillisecondsSinceEpoch(this!);
    var date = new DateTime.fromMicrosecondsSinceEpoch(this! * 1000);
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

extension SimpleDateTime on DateTime? {
  String getSimpleDateStr() {
    if (this == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(this!);
  }
}

extension commaSeprateList on List {
  String toCommaSepratedValues() =>
      this.toString().replaceAll("[", "").replaceAll("]", "");
}
