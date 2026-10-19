import 'package:flutter/foundation.dart';

import 'constants.dart';
import 'enums.dart';

class BaseUrls {
  // static const String termsCondition =
  //     'https://docs.google.com/document/d/1G4Dt3YjxFbwOLB5pR6XVyLgVFDGsHvpHKmSe78UlD9g/edit?usp=sharing';
  static const String devBaseUrl = 'https://seclusion-repeater-habitual.ngrok-free.dev/api/v1/';
  static const String prodBaseUrl =
      'https://investor.monexo.co/monexo-service-v1/';
  static const String awsUrl =
      'https://uat-lender.monexo.co:8080/monexo-service-v1/'; //'http://3.7.66.156:8081/api/v1/';
}

class APIUrls {
  static final baseURL = getBaseUrlApis();

  static final termsCondition = '${baseURL}t-c';

  ///SDK Urls
  static const String hyperVergeOcrApi =
      'https://ind-docs.hyperverge.co/v2.0/readKYC';
  static const String hyperVergeFaceApi =
      'https://ind-faceid.hyperverge.co/v1/photo/verifyPair';

  // static final pinCodeGovApi =
  //     'https://api.data.gov.in/resource/0a076478-3fd3-4e2c-b2d2-581876f56d77?format=json&api-key=${Constants.pincodeApiKey}&filters[pincode]=';

  static final pinCodeApi = "${baseURL}getGovtDataByPinCode/";

  /// Backend urls
  static final panDetails = '${baseURL}pandetails';
  static final loginSendOtp = '${baseURL}login/sendOtp';
  static final loginVerifyOtp = '${baseURL}login/verifyOtp';
  static final signupSendOtp = '${baseURL}signup/sendOtp';
  static final signupVerifyOtp = '${baseURL}signup/verifyOtp';
  static final getBankDetails = '${baseURL}getBankDetails';
  static final saveBankDetails = '${baseURL}saveBankDetails';
  static final saveNomineeDetails = '${baseURL}savenomineeDetails';
  static final getNomineeDetails = '${baseURL}getnomineeDetails?customerId=';
  static final addUpdateAutoInvestments =
      '${baseURL}saveandModifyAutoInvestments';
  static final getAutoinvestmentDetails =
      '${baseURL}getAutoinvestmentDetails?customerId=';
  static final getCashFreeToken = '${baseURL}getCashFreeToken';
  static final saveChequeDepositoryUpload =
      '${baseURL}saveChequeDepositoryUpload';
  static final getAuthorizedSignatory =
      '${baseURL}getAuthorizedSignatory?customerId=';
  static final saveAuthorizedSignatory = '${baseURL}saveAuthorizedSignatory';
  static final pennyDropValidation = '${baseURL}validateAccount';
  static final aadharUpload = '${baseURL}aadharupload';
  static final getMipDetails = '${baseURL}getMipDetails';
  static final saveMipDetails = '${baseURL}saveMipDetails';
  static final saveFundTransferDetails = '${baseURL}saveFundTranserDetails';
  static final getCustomerList = '${baseURL}listOfCustomer?phoneNumber=';
  static final cashfreeWebToken = '${baseURL}cashfreeOrderCreate';
  static final hyperverseToken = '${baseURL}gethyperverse';
  static final kycAadhaarOcrFront = '${baseURL}kyc/aadhaar/ocr-front';
  static final kycAadhaarOcrBack = '${baseURL}kyc/aadhaar/ocr-back';
  static final kycFaceLiveness = '${baseURL}kyc/face/liveness';
  static final kycFaceMatch = '${baseURL}kyc/face/match';
  static final kycDigilockerCreateUrl = '${baseURL}kyc/digilocker/create-url';
  static final kycDigilockerStatus = '${baseURL}kyc/digilocker/status';
  static final kycDigilockerComplete = '${baseURL}kyc/digilocker/complete';
  static final getUserDetails = '${baseURL}getuserDetails?customerId=';
  static final getSipDetail = '${baseURL}getSipDetailsByCustomerIdAndSourceId';
  static final createSip = '${baseURL}createSip';
  static final validateMandate = '${baseURL}validateMandate';
  static final createMandate = '${baseURL}createMandate';
  static final checkMandateStatus = '${baseURL}checkMandateStatus';
  static final stepsStatus = '${baseURL}v2/checkstatus?customerId=';
  static final downloadFileUrl = '${baseURL}downloadFileUrl';
  static final uploadFileDetails = '${baseURL}uploadFileDetails';
  static final updateOfficeAddress = '${baseURL}updateOfficeAddress';
  static final updateResidentAddress = '${baseURL}updateResidentAddress';
  static final getOldSipDetails = '${baseURL}getSipDetails?customerId=';
  static final getOldMipDetail = '${baseURL}getMipDetail?customerId=';
  static final updateProfile = '${baseURL}updateProfile';
  static final uploadProfilePhoto = '${baseURL}uploadProfilePhoto';
  static final getAmountDetails = '${baseURL}v2/getAmountDetails?customerId=';
  static final getCashFreeOrderStatus = '${baseURL}getOrderStatusByOrderId/';
  static final getPrimaryMarketLoanList = '${baseURL}v2/getprimeryMarketLoans';
  static final getPrimaryMarketLoanDetailsByContract =
      '${baseURL}getPrimaryMarketLoanDetail';
  static final checoutPrimaryMarketLoans = '${baseURL}saveMarketLoanCheckOut';
  static final checoutSecondaryMarketLoans =
      '${baseURL}secondaryMarketLoanCheckOut';
  static final getSecondaryMarketLoanList =
      '${baseURL}v2/getSecondaryMarketList';
  static final getSecondaryMarketLoanDetailByInvestmentId =
      '${baseURL}getInvesmentDetails';
  static final getRedemptionData = '${baseURL}getRedimptionLoanAmount';
  static final submitRedemptionData = '${baseURL}getRedimptionLoanUpdated';
  static final getMyInvestments = '${baseURL}getMyInvestments';
  static final getMyInvestmentDetail = '${baseURL}getMyInvestmentDetail';
  static final getStatement = '${baseURL}getStatement';
  static final getAccountTransactions = '${baseURL}getAccountTransactions';
  static final emailStatement = '${baseURL}emailStatement';
  static final getAutoinvestDate = '${baseURL}getAutoinvestDate';
  static final getAppVersion = '${baseURL}getAppVersion';
  static final autoInvestSwitch = '${baseURL}autoTongle';
  static final mipSwitch = '${baseURL}mipTongle';
  static final saveandModifyAutoInvestments =
      '${baseURL}saveandModifyAutoInvestments';
  static final withdrawAmount = '${baseURL}withdrawal';
  static final logout = '${baseURL}jwt-logout';
  static final authSendOtp = '${baseURL}login/auth-sendOtp';
  static final authVerifyOtp = '${baseURL}login/auth-verifyOtp';
  static final flyyUserToken = '${baseURL}FlyyUserToken';
  static final autoLoginByUser = '${baseURL}autoLoginByUser';
  static final osType = '${baseURL}osUpdate';
  static final addUSerToSegment = '${baseURL}setSegementForUser?customerId=';
  static final appsFlyIdUpdate = '${baseURL}appsFlyIdUpdate';
  static final offer = '${baseURL}getOffer';
  static final videos = '${baseURL}getVideosData';
  static final portfolioAnalysis = '${baseURL}getPortfolioDetails?cid=';
  static final wylthyReferalData = '${baseURL}getReferByData?userName=';
  static final setWylthyRefer = '${baseURL}flyyRefer';
  static final portfolioRiskData = '${baseURL}portfolioRiskDetails?cid=';
  static final portfolioTabStatus = '${baseURL}portfolioTabStatus';
  static final delinquencyTabStatus = '${baseURL}getDeleqDetails?cid=';
  static final sipOption = '${baseURL}bankDetailByCid?cid=';
  static final sipSwitch = '${baseURL}sipTongle';
//////////////////////
//////////
///////
}

String getBaseUrlApis() {
  //if not in release mode always runs in dev enviroment
  if (Constants.environment == Environments.Dev) {
    print("dev");
    return BaseUrls.devBaseUrl;
  } else if (Constants.environment == Environments.QA) {
    print("qa");
    return BaseUrls.awsUrl;
  } else {
    print("prod");
    return BaseUrls.prodBaseUrl;
  }
}

class ApiParams {
  /// Pan detail api
  static final pan = 'pan';
  static final ip = 'ip';
  static final dob = 'dob';

  ///send SMS, OTP
  static final mobileNumber = 'mobileNumber';
  static final phoneNo = 'phoneNo';
  static final otp = 'otp';
  static final newMobileOtp = 'newMobileOtp';

  /// Bank details
  static final ifscCode = 'ifscCode';

  /// Auto-Investment
  static final investmentId = 'id';
  static final totalAmount = 'totalAmount';
  static final conservetiveRisk = 'conservetiveRisk';
  static final moderateRisk = 'moderateRisk';
  static final highRisk = 'highRisk';

  /// Nominee details
  static final nomineeFullName = 'nomineeFullName';
  static final date = 'date';
  static final address = 'address';
  static final pincode = 'pincode';
  static final city = 'city';
  static final state = 'state';
  static final relationship = 'relationship';
  static final panNumber = 'panNumber';

  /// Bank details
  static final orderAmount = 'orderAmount';
  static final orderCurrency = 'orderCurrency';

  /// Save bank Details
  static final customerId = 'customerId';
  static final acountHolderName = 'acountHolderName';
  static final accountNumber = 'accountNumber';
  static final bankName = 'bankName';
  static final branchName = 'branchName';
  static final micrCode = 'micrCode';
  static final accountType = 'accountType';

  /// Signup Send OTP
  static final email = 'email';
  static final fullName = 'fullName';
  static final aadharNumber = 'aadharNumber';

  /// Get CID
  static final phone = 'phone';

  /// Get CID
  static final chequeNumber = 'chequeNnumber';

  /// Authorized Signatory
  static final authorizedSignatoryName = 'authorizedSignatoryName';
  static final enterAmount = 'enterAmount';
  static final file = 'file';

  /// Aadhar Submit
  static final dateOfBirth = 'dateOfBirth';
  static final latitute = 'lat';
  static final longitute = 'lng';
  static final gender = 'gender';
  static final aadharCardNumber = 'aadharCardNumber';
  static final faceMatch = 'facematch';
  static final faceMatchScore = 'facematchScore';
  static final livenessScore = 'livenessScore';
  static final profileImage = 'profileImage';
  static final aadharFrontImage = 'aadharfrontImage';
  static final aadharBackImage = 'aadharbackImage';

  /// Penny Drop finalification
  static final cid = 'cid';
  static final accountNum = 'accountNum';

  /// Save Fund transfer
  static final paymentMode = 'paymentMode';
  static final amount = 'amount';
  static final paymentStatus = 'paymentStatus';
  static final orderId = 'orderId';
  static final upiId = 'upiId';

  /// Save mip details
  static final mipOptionId = 'mipOptionId';
  static final mipPartnerId = 'mipPartnerId';
  static final mipCauseId = 'mipCauseId';

  /// Customer List
  static final phoneNumber = 'phoneNumber';

  /// get Sip details
  static final sourceId = 'sourceId';

  /// Create Sip details
  static final monthDuration = 'month_duration';
  static final amountMaximum = 'amount_maximum';
  static final debtorAccountName = 'debtor_account_name';
  static final debtorAccountNumber = 'debtor_account_number';
  static final debtorAgentCode = 'debtor_agent_code';
  static final debtorEmail = 'debtor_email';
  static final authMode = 'auth_mode';
  static final dateValue = 'presdatevalue';
  static final custVirAdd = 'custVirAdd';
  static final presDate = 'presDate';

  /// Address Detail
  static final doorNo = 'doorNo';
  static final flatNo = 'flatNo';
  static final department = 'department';
  static final designation = 'designation';

  static final enable = 'enable';
  static final isNew = 'is_new';
  static final username = 'username';
  static final extUserId = 'extUserId';
  static final osType = 'osType';

  ///appsFlyIdUpdate
  static final appsflyerId = 'appsflyer_id';
  static final customer_user_id = 'customer_user_id';

  /// set Wylth Refer Web
  static final type = 'type';
  static final name = 'name';
  static final ext_user_id = 'ext_user_id';
  static final referrer_ext_user_id = 'referrer_ext_user_id';
  static final created_at = 'created_at';

  static final sipFlag = 'sipFlag';
  static final authSipMode = 'authMode';
}
