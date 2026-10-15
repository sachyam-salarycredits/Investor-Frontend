import 'dart:convert';

import 'package:peerbridge/modules/authentication/models/pan_details.dart';
import 'package:peerbridge/modules/bankDetails/models/user_bank_detail.dart';
import 'package:peerbridge/utils/extensions.dart';

class UserDetails {
  int userStage;
  BankAccountDetails? bankAccountDetails;
  ProfileDetails? profileDetails;
  bool mip;
  NomineeDetails? nomineeDetails;
  String aadharNumber;
  OfficeAddress? officeAddress;
  ResidenceAddress? residenceAddress;
  PanDetails? panDetails;
  String? enableDialogFiled;

  UserDetails({
    this.userStage = 1,
    this.bankAccountDetails,
    this.profileDetails,
    this.mip = false,
    this.nomineeDetails,
    this.aadharNumber = '',
    this.officeAddress,
    this.residenceAddress,
    this.panDetails,
    this.enableDialogFiled,
  });

  //TODO NAMES NEED TO CHANGE TO CAMEL CASE AFTER TESTING
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userStage: json["userStage"] ?? 1,
      mip: json['mip'] ?? false,
      profileDetails: json["profileDetails"] == null
          ? ProfileDetails()
          : ProfileDetails.fromJson(json["profileDetails"]),
      aadharNumber: json["aadharNumber"] ?? '',
      bankAccountDetails: json["bankAccountDetails"] == null
          ? BankAccountDetails()
          : BankAccountDetails.fromJson(json["bankAccountDetails"]),
      residenceAddress: json["residenceAddress"] == null
          ? null
          : ResidenceAddress.fromJson(json["residenceAddress"]),
      officeAddress: json["officeAddress"] == null
          ? null
          : OfficeAddress.fromJson(json["officeAddress"]),
      nomineeDetails: json["nomineeDetails"] == null
          ? NomineeDetails()
          : NomineeDetails.fromJson(json["nomineeDetails"]),
      panDetails: json["panDetails"] == null
          ? PanDetails()
          : PanDetails.fromJson(json["panDetails"]),
      enableDialogFiled: json["enableDialogFiled"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userStage'] = this.userStage;
    if (this.bankAccountDetails != null) {
      data['bankAccountDetails'] = this.bankAccountDetails!.toJson();
    }
    if (this.profileDetails != null) {
      data['profileDetails'] = this.profileDetails!.toJson();
    }
    data['mip'] = this.mip;
    if (this.nomineeDetails != null) {
      data['nomineeDetails'] = this.nomineeDetails!.toJson();
    }
    data['aadharNumber'] = this.aadharNumber;
    if (this.officeAddress != null) {
      data['officeAddress'] = this.officeAddress!.toJson();
    }
    if (this.residenceAddress != null) {
      data['residenceAddress'] = this.residenceAddress!.toJson();
    }
    if (this.panDetails != null) {
      data['panDetails'] = this.panDetails!.toJson();
    }
    data['enableDialogFiled'] = this.enableDialogFiled;

    return data;
  }
}

class BankAccountDetails {
  String accountNumber;
  String bankName;
  String branchName;
  String ifscCode;
  String micrCode;
  String accountType;
  String address;
  String upiId;

  BankAccountDetails({
    this.accountNumber = "12989898989980",
    this.bankName = "IDFC",
    this.branchName = "IDFS",
    this.ifscCode = "",
    this.micrCode = "",
    this.accountType = "",
    this.address = "",
    this.upiId = "",
  });

  factory BankAccountDetails.getDummyModel() => BankAccountDetails();

  factory BankAccountDetails.fromJson(Map<String, dynamic> json) {
    return BankAccountDetails(
      accountNumber: json['accountNumber'] ?? "",
      bankName: json['bankName'] ?? "",
      accountType: json['accountType'] ?? "",
      address: json['address'] ?? "",
      branchName: json['branchName'] ?? "",
      ifscCode: json['ifscCode'] ?? "",
      micrCode: json['micrCode'] ?? "",
      upiId: json['upiId'] ?? "",
    );
  }

  get fullName => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accountNumber'] = this.accountNumber;
    data['bankName'] = this.bankName;
    data['branchName'] = this.branchName;
    data['ifscCode'] = this.ifscCode;
    data['micrCode'] = this.micrCode;
    data['upiId'] = this.upiId;
    data['accountType'] = this.accountType;
    data['address'] = this.address;
    return data;
  }
}

class ProfileDetails {
  String customerId;
  String email;
  String phoneNumber;
  String fullName;
  String profileUrl;
  String aadharNumber;

  ProfileDetails({
    this.customerId = "",
    this.email = "",
    this.phoneNumber = "",
    this.fullName = "",
    this.profileUrl = "",
    this.aadharNumber = "",
  });

  factory ProfileDetails.fromJson(Map<String, dynamic> json) {
    return ProfileDetails(
      customerId: json["customerId"] ?? "",
      email: json["email"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      fullName: (json["fullName"] ?? ""),
      profileUrl: json["profileUrl"] ?? "",
      aadharNumber: json["aadharNumber"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerId'] = this.customerId;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['fullName'] = this.fullName;
    data['profileUrl'] = this.profileUrl;
    data['aadharNumber'] = this.aadharNumber;
    return data;
  }
}

class NomineeDetails {
  String customerId;
  String nomineeFullName;
  String dob;
  String address;
  String pincode;
  String city;
  String state;
  String relationship;
  String panNumber;

  NomineeDetails({
    this.customerId = "",
    this.nomineeFullName = "",
    this.dob = "",
    this.address = "",
    this.pincode = "",
    this.city = "",
    this.state = "",
    this.relationship = "",
    this.panNumber = "",
  });

  factory NomineeDetails.fromJson(Map<String, dynamic> json) {
    return NomineeDetails(
      customerId: json['customerId'] ?? "",
      address: json['address'] ?? "",
      city: json["city"] ?? "",
      dob: json["dob"] ?? "",
      nomineeFullName: json["nomineeFullName"] ?? "",
      pincode: json['pincode'] ?? "",
      relationship: json['relationship'] ?? "",
      state: json['state'] ?? "",
      panNumber: json['panNumber'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerId'] = this.customerId;
    data['nomineeFullName'] = this.nomineeFullName;
    data['dob'] = this.dob;
    data['address'] = this.address;
    data['pincode'] = this.pincode;
    data['city'] = this.city;
    data['state'] = this.state;
    data['relationship'] = this.relationship;
    data['panNumber'] = this.panNumber;
    return data;
  }
}

class OfficeAddress {
  String city;
  String department;
  String designation;
  String doorNo;
  String flatNo;
  String pincode;
  String state;

  OfficeAddress({
    this.city = "",
    this.department = "",
    this.designation = "",
    this.doorNo = "",
    this.flatNo = "",
    this.pincode = "",
    this.state = "",
  });

  factory OfficeAddress.fromJson(Map<String, dynamic> json) {
    return OfficeAddress(
      city: json['city'] ?? "",
      department: json['department'] ?? "",
      designation: json['designation'] ?? "",
      doorNo: json['doorNo'] ?? "",
      flatNo: json['flatNo'] ?? "",
      pincode: json['pincode'] ?? "",
      state: json['state'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city'] = this.city;
    data['department'] = this.department;
    data['designation'] = this.designation;
    data['doorNo'] = this.doorNo;
    data['flatNo'] = this.flatNo;
    data['pincode'] = this.pincode;
    data['state'] = this.state;
    return data;
  }
}

class ResidenceAddress {
  String flatNo;
  String doorNo;
  String city;
  String pincode;
  String state;

  ResidenceAddress({
    this.flatNo = "",
    this.doorNo = "",
    this.city = "",
    this.pincode = "",
    this.state = "",
  });

  factory ResidenceAddress.fromJson(Map<String, dynamic> json) {
    return ResidenceAddress(
        flatNo: json['flatNo'] ?? "",
        doorNo: json['doorNo'] ?? "",
        city: json['city'] ?? "",
        pincode: json['pincode'] ?? "",
        state: json['state'] ?? "");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flatNo'] = this.flatNo;
    data['doorNo'] = this.doorNo;
    data['city'] = this.city;
    data['pincode'] = this.pincode;
    data['state'] = this.state;
    return data;
  }
}
