import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/authentication/models/WylthReferDataModel.dart';
import 'package:peerbridge/modules/bankDetails/models/penny_drop_response.dart';
import 'package:peerbridge/modules/home/models/DelinquencyStatusModel.dart';
import 'package:peerbridge/modules/home/models/PortfolioAnalysisModel.dart';
import 'package:peerbridge/modules/home/models/portfolio_summary.dart';
import 'package:peerbridge/modules/home/models/PortfolioTabStatusModel.dart';
import 'package:peerbridge/modules/home/models/ViewRiskDataModel.dart';
import 'package:peerbridge/modules/marketplace/models/common_loan_cart.dart';
import 'package:peerbridge/modules/marketplace/models/filter_data.dart';
import 'package:peerbridge/modules/marketplace/models/primary_loan_details.dart';
import 'package:peerbridge/modules/marketplace/models/primary_market_loan.dart';
import 'package:peerbridge/modules/marketplace/models/primary_market_loan_response.dart';
import 'package:peerbridge/modules/marketplace/models/redemption_data.dart';
import 'package:peerbridge/modules/marketplace/models/my_investments_data.dart';
import 'package:peerbridge/modules/marketplace/models/secondary_market_loan.dart';
import 'package:peerbridge/modules/marketplace/models/secondary_market_loan_detail.dart';
import 'package:peerbridge/modules/marketplace/models/secondary_market_response.dart';
import 'package:peerbridge/modules/marketplace/models/account_transactions.dart';
import 'package:peerbridge/modules/marketplace/models/statement_data.dart';
import 'package:peerbridge/modules/marketplace/widgets/loan_cart_button.dart';
import 'package:peerbridge/modules/onboardingSteps/models/BankDetailSIPModel.dart';
import 'package:peerbridge/modules/onboardingSteps/models/authorized_signatory.dart';
import 'package:peerbridge/modules/onboardingSteps/models/auto_invest_detail.dart';
import 'package:peerbridge/modules/bankDetails/models/bank_detail.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashFree_details.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashfree_web_token_response.dart';
import 'package:peerbridge/modules/authentication/models/customerId_list.dart';
import 'package:peerbridge/modules/onboardingSteps/models/mip_details.dart';
import 'package:peerbridge/modules/authentication/models/pan_details.dart';
import 'package:peerbridge/modules/authentication/models/personal_detail.dart';
import 'package:peerbridge/modules/onboardingSteps/models/pincode_details.dart';
import 'package:peerbridge/modules/onboardingSteps/models/sip_details.dart';
import 'package:peerbridge/modules/onboardingSteps/models/steps_data.dart';
import 'package:peerbridge/modules/bankDetails/models/user_bank_detail.dart';
import 'package:peerbridge/modules/marketplace/models/fundTransferDetails.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/sip_screen.dart';
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/routes_management/app_router.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/supporting_file/appsFlyerSdk.dart';
import 'package:peerbridge/supporting_file/fly_sdk.dart';
import 'package:peerbridge/supporting_file/flyy_web_sdk.dart';
import 'package:peerbridge/supporting_file/sfmc_flutter.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

import '../modules/home/models/NewOfferModel.dart';
import '../modules/home/models/ViewDataModel.dart';
import '../modules/home/models/YoutubeVediosModel.dart';
import '../modules/onboardingSteps/models/auto_invest_category_model.dart';

class AppStateProvider with ChangeNotifier {
  SharedPreferences? pref;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  final isMarketPlaceLoading = ValueNotifier(false);

  final audioPlayer = AudioPlayer();
  bool _isLoggedIn = false;
  bool _isLoggingIn = false;
  bool _onBoardingComplete = false;

  BuildContext _context;
  late APICalling apiCalling;
  String _customerId = "";
  PanDetails? panDetails;
  PersonalDetail? personalDetail;
  UserBankDetail? userBankDetail;
  UserDetails? userDetails;
  List<CustomerIdDetail>? customerIdList;
  YoutubeVideosModel? youtubeVideos;
  WylthReferDataModel? wylthReferalData;
  PortfolioAnalysisModel? portfolioAnalysis;
  PortfolioSummary? portfolioSummary;
  ViewDataModel? portfolioRiskAnalysis;
  PortfolioTabStatusModel? portfolioTabStatusData;
  DelinquencyStatusModel? delinquencyTabStatusData;
  BankDetailSipModel? bankDetailData;

  StepsData? stepsData;
  bool isNewUser = false;

  String? token;
  String? mobileNo;
  String? appFlyId;

  UserFundTransferDetails? userFundTransferDetails;

  GlobalKey<LoanCartButtonState> loanButtonState =
      GlobalKey<LoanCartButtonState>();

  List<PrimaryMarketLoan>? primaryMarketLoans;
  LoanOverViewDetail primaryLoanOverView = LoanOverViewDetail();
  LoanOverViewDetail secondaryLoanOverView = LoanOverViewDetail();
  LoanOverViewDetail overViewDetail = LoanOverViewDetail();
  List<SecondaryMarketLoan>? secondaryMarketLoans;

  List<CommonLoanCart> primaryCartList = [];
  List<CommonLoanCart> secondaryCartList = [];

  List<String> filterProducts = [];
  FilterDetails _primaryMarketFilter = FilterDetails();
  FilterDetails _secondaryMarketFilter = FilterDetails();
  bool _isPrimaryMarketSelected = true;
  String appVersion = "";

  List<StatementData> statementList = [];
  List<AutoInvestCategoryModel> autoInvestCategoryDetailList = [];

  //MARK: AdGyde SDK initialization
  // Adgydesdk adGydeInstance = new Adgydesdk();

  AppStateProvider(this._context) {
    apiCalling = APICalling.getApiClient(context: _context);
  }

  initPref() async {
    pref = await SharedPreferences.getInstance();
  }

  initAudioPlayer() {}

  saveUserState() async {
    if (pref == null) {
      await initPref();
    }

    // saving user state to prefs
    debugPrint('save called $customerId');
    await pref!.setBool(Constants.isLoggedIn, true);
    await pref!.setString(Constants.customerId, customerId);
    await pref!.setString(Constants.token, token ?? "");
    await pref!.setString(Constants.mobileNumber, mobileNo ?? "");

    //getting customer details according to customer id;
    await getCustomerDetails();
  }

  getUserState() async {
    //checking is user previously Login
    if (pref == null) {
      await initPref();
    }
    debugPrint('this called');
    isLoggingIn = true;
    _isLoggedIn = pref?.getBool(Constants.isLoggedIn) ?? false;
    customerId = pref?.getString(Constants.customerId) ?? "";
    token = pref?.getString(Constants.token) ?? "";
    mobileNo = pref?.getString(Constants.mobileNumber) ?? "";

    if (token != "" && customerId.isNotEmpty && Utils.isWeb) {
      await getStepsStatus();
      await getCustomerDetails();
    }
  }

  void clearUserState() async {
    if (pref == null) {
      await initPref();
    }

    //checking is user previously Login
    isLoggingIn = false;
    customerId = '';
    panDetails = null;
    userBankDetail = null;
    personalDetail = null;
    userDetails = null;
    stepsData = null;
    (await SharedPreferences.getInstance()).clear();
    primaryCartList.clear();
    secondaryCartList.clear();
    primaryMarketLoans = null;
    secondaryMarketLoans = null;
    filterProducts.clear();
    _primaryMarketFilter = FilterDetails();
    _secondaryMarketFilter = FilterDetails();
    _isPrimaryMarketSelected = true;
    loanButtonState = GlobalKey<LoanCartButtonState>();
    userFundTransferDetails = null;
    statementList = [];
    token = null;
  }

  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  bool get onBoardingComplete => _onBoardingComplete;

  set onBoardingComplete(bool value) {
    _onBoardingComplete = value;
    notifyListeners();
  }

  bool get isLoggingIn => _isLoggingIn;

  set isLoggingIn(bool value) {
    _isLoggingIn = value;
    notifyListeners();
  }

  bool isFilterClear() {
    return filterData.maxAmount == 0 &&
        filterData.tenure == 0 &&
        filterData.grade.isEmpty &&
        filterData.products.isEmpty;
  }

  // String getFilterCount() {
  //   var count = 0;
  //   if (filterData.maxAmount > 1000) count++;
  //   if (filterData.tenure > 0) count++;
  //   if (filterData.grade.length > 0) count++;
  //   if (filterData.products.length > 0) count++;
  //   if (count > 0) return '($count)';
  //   return '';
  // }

  int getProfilePercentage() {
    if (userDetails != null && stepsData != null) {
      /// Static percentages
      final registrationPer = 25.0;
      final officeAddressPer = 5.0;
      final homeAddressPer = 5.0;
      final gender = userDetails?.panDetails?.gender;
      final otherEntityCount = (gender == null || gender == '') ? 7 : 6;

      final oneEntityPer =
          (100 - registrationPer - officeAddressPer - homeAddressPer) /
              otherEntityCount;

      var completedPer = registrationPer;

      if (userDetails?.officeAddress != null) {
        completedPer = completedPer + officeAddressPer;
      }

      if (userDetails?.residenceAddress != null) {
        completedPer = completedPer + homeAddressPer;
      }

      var completedCount = int.parse(stepsData!.fundTransfer) +
          int.parse(stepsData!.kyc) +
          int.parse(stepsData!.autoInvestment) +
          int.parse(stepsData!.mip) +
          int.parse(stepsData!.sip) +
          int.parse(stepsData!.nominee);
      if (otherEntityCount == 7) {
        completedCount =
            completedCount + int.parse(stepsData!.authorizedSignatory);
      }
      completedPer = completedPer + completedCount * oneEntityPer;
      return completedPer.ceil();
    }
    return 0;
  }

  /// //////////////////////////////////
  /// //// API CAll //////////////////////
  /// //////////////////////////////////

  /// Get pan details
  Future<PanDetails?> getPanDetails(String pan, String dob) async {
    try {
      var url = APIUrls.panDetails;

      var param = Map<String, String>();
      param[ApiParams.pan] = pan;
      param[ApiParams.dob] = dob;

      var otpResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param, addToken: false);

      var response = json.decode(otpResponse);
      if (response["statusCode"] == "200") {
        final detailJson = response["data"] ?? null;
        if (detailJson != null) {
          final detail = PanDetails.fromJson(detailJson);
          panDetails = detail;
          return detail;
        }
        return null;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Send Login OTP API
  Future<bool> loginSendOTP(String phoneNo, [newMobileOtp]) async {
    try {
      var url = APIUrls.loginSendOtp;

      var param = Map<String, dynamic>();
      param[ApiParams.phoneNo] = phoneNo;
      if (newMobileOtp != null) {
        param[ApiParams.newMobileOtp] = newMobileOtp;
      }

      var otpResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param, isAlert: true);

      var response = json.decode(otpResponse);
      if (response["statusCode"] == "200") {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// user to verify otp in different part of app
  Future<bool> sendOtpForUser() async {
    return (await authSendOTP(userDetails?.profileDetails?.phoneNumber ?? ""));
  }

  /// Verify Login OTP APi
  Future<bool> loginVerifyOTP(String phoneNo, String otp,
      [newMobileOtp]) async {
    try {
      var url = APIUrls.loginVerifyOtp;

      var param = Map<String, dynamic>();
      param[ApiParams.mobileNumber] = phoneNo;
      param[ApiParams.ip] = await Utils.getIpAddress();
      param[ApiParams.otp] = otp;
      if (newMobileOtp != null) {
        param[ApiParams.newMobileOtp] = newMobileOtp;
        param[ApiParams.customerId] = customerId;
      }

      var otpResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(otpResponse);
      if (response["statusCode"] == "200") {
        final data = response['data'];
        final responseToken =
            data is Map ? data['token'] : null;
        if (responseToken != null &&
            (token == null || token == '' || newMobileOtp == null)) {
          token = responseToken;
          mobileNo = phoneNo;
        }
        mobileNo = phoneNo;
        isNewUser = false;
        if (!isLoggedIn) {
          getCustomerDetails();
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Send SignUp OTP API
  Future<bool> signupSendOTP(param) async {
    try {
      var url = APIUrls.signupSendOtp;
      var otpResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(otpResponse);
      if (response["statusCode"] == "200") {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Verify SignUp OTP APi
  Future<String?> signupVerifyOTP(String phoneNo, String otp) async {
    try {
      var url = APIUrls.signupVerifyOtp;

      var ip = await Utils.getIpAddress();

      var param = Map<String, String>();
      param[ApiParams.phone] = phoneNo;
      param[ApiParams.email] = personalDetail?.email ?? '';
      param[ApiParams.pan] = panDetails?.pan ?? '';
      param[ApiParams.otp] = otp;
      param[ApiParams.aadharNumber] = personalDetail?.aadharNo ?? "";
      param[ApiParams.ip] = ip;

      var otpResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(otpResponse);
      if (response["statusCode"] == "200") {
        final cid = response["data"]["customerId"] ?? null;
        final jwtToken = response["data"]["jwtResponse"]['token'] ?? null;
        if (jwtToken != null) {
          token = jwtToken;
          mobileNo = phoneNo;
        }
        if (cid != null) {
          customerId = cid;
          await FlySdk.signUpUser(cid);
          isNewUser = true;
          _isLoggedIn = true;
          AFSdk.setUser(cid);
          AFSdk.logEvent(AFSdk.af_register, null);
          return cid;
        }
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Bank detail APi
  Future<BankDetail?> getBankDetails(String ifscCode) async {
    try {
      var url = APIUrls.getBankDetails;

      var param = Map<String, String>();
      param[ApiParams.ifscCode] = ifscCode;

      var bankResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(bankResponse);
      if (response["statusCode"] == "200") {
        return BankDetail.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  ///Get Auto-Investment APi
  Future<AutoInvestDetail?> getAutoInvestment() async {
    try {
      var url = APIUrls.getAutoinvestmentDetails + customerId;

      var autoInvestRes = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(autoInvestRes);
      if (response["statusCode"] == "200") {
        return AutoInvestDetail.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Save Auto-Investment APi
  Future<AutoInvestDetail?> saveAutoInvestment(param) async {
    try {
      var url = APIUrls.addUpdateAutoInvestments;

      var autoInvestRes = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(autoInvestRes);
      if (response["statusCode"] == "200") {
        //updating status data
        getStepsStatus();

        return AutoInvestDetail.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Save Nominee details api
  Future<NomineeDetails?> saveNomineeDetails(param) async {
    try {
      var url = APIUrls.saveNomineeDetails;
      var nomineeResp = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(nomineeResp);
      if (response["statusCode"] == "200") {
        //updating status

        await getStepsStatus();
        await getCustomerDetails();

        return NomineeDetails.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get Nominee details api
  Future<NomineeDetails?> getNomineeDetails() async {
    try {
      var url = APIUrls.getNomineeDetails + customerId;
      var nomineeResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(nomineeResp);
      if (response["statusCode"] == "200") {
        return NomineeDetails.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get CashFreeToken api
  Future<CashFreeDetail?> getCashFreeToken(param) async {
    try {
      var url = APIUrls.getCashFreeToken;

      var tokenResp = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(tokenResp);
      if (response["statusCode"] == "200") {
        return CashFreeDetail.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<CashFreeOrderResponse?> getCashFreeTokenWeb(param) async {
    try {
      var url = APIUrls.cashfreeWebToken;

      var tokenResp = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      debugPrint(tokenResp);
      var response = json.decode(tokenResp);
      // if (response["statusCode"] == 200) {
      return CashFreeOrderResponse.fromJson(response["data"]);
      // }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Persist profile UPI on bank_details_save (full bank row + upiId).
  Future<bool> saveProfileUpi(String upiId) async {
    final trimmed = upiId.trim();
    if (trimmed.isEmpty || customerId.isEmpty) {
      return false;
    }
    final bank = userDetails?.bankAccountDetails;
    if (bank == null) {
      return false;
    }
    final ok = await saveBankDetails({
      ApiParams.customerId: customerId,
      ApiParams.acountHolderName: userDetails?.profileDetails?.fullName ?? '',
      ApiParams.accountNumber: bank.accountNumber,
      ApiParams.ifscCode: bank.ifscCode,
      ApiParams.bankName: bank.bankName,
      ApiParams.branchName: bank.branchName,
      ApiParams.accountType: bank.accountType,
      ApiParams.upiId: trimmed,
    });
    if (ok) {
      await getCustomerDetails();
    }
    return ok;
  }

  /// Upload registration selfie to S3 and set as profile photo.
  Future<bool> uploadProfilePhoto(String filePath) async {
    try {
      if (customerId.isEmpty || filePath.isEmpty) return false;
      final platformFile = Utils.getPlatformFile(filePath);
      if (platformFile == null) return false;

      final files = <String, PlatformFile>{
        ApiParams.profileImage: platformFile,
      };
      final param = <String, String>{
        ApiParams.customerId: customerId,
      };

      final resp = await apiCalling.dataPostRequestAllPlatform(
        url: APIUrls.uploadProfilePhoto,
        headers: null,
        parameters: param,
        files: files,
      );
      final response = json.decode(resp);
      if (response["statusCode"] == "200") {
        await getCustomerDetails();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Get CashFreeToken api
  Future<bool> saveBankDetails(param) async {
    try {
      var url = APIUrls.saveBankDetails;

      var bankDetailResp = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(bankDetailResp);
      if (response["statusCode"] == "200") {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Pincode Geocoding api
  Future<PinCodeDetail?> getCityState(pincode) async {
    try {
      var url = APIUrls.pinCodeApi + pincode;

      var pincodeResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(pincodeResp);

      if (response["data"].containsKey('records')) {
        var firstRecord = response["data"]['records'][0];
        return PinCodeDetail.fromJson(firstRecord);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get Authorized Signatory Details
  Future<AuthorizedSignatory?> getAuthorizedSignatory() async {
    try {
      var url = APIUrls.getAuthorizedSignatory + customerId;

      var signatoryResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(signatoryResp);
      if (response["statusCode"] == "200") {
        return AuthorizedSignatory.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Save Authorized Signatory Details
  Future<AuthorizedSignatory?> saveAuthorizedSignatory(param, files) async {
    try {
      var url = APIUrls.saveAuthorizedSignatory;

      var signatoryResp = await apiCalling.dataPostRequestAllPlatform(
          url: url, headers: null, parameters: param, files: files);

      var response = json.decode(signatoryResp);
      if (response["statusCode"] == "200") {
        //updating status data
        getStepsStatus();
        return AuthorizedSignatory.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Fund Transfer with cheque
  Future<bool> chequeFundTransfer(param, files, isFromFile) async {
    try {
      var url = APIUrls.saveChequeDepositoryUpload;

      var chequeResp;
      if (Utils.isWeb || isFromFile) {
        chequeResp = await apiCalling.dataPostRequestAllPlatform(
            url: url, headers: null, parameters: param, files: files);
      } else {
        chequeResp = await apiCalling.dataPostRequest(
            url: url, headers: null, parameters: param, files: files);
      }
      var response = json.decode(chequeResp);
      if (response["statusCode"] == "200") {
        getStepsStatus();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Penny drop bank account varification
  Future<PennyDropRes> pennyDropVarification(param) async {
    var result = PennyDropRes(
        "We are experiencing server issue. Please try after sometime. You can call our helpline too.",
        false);
    try {
      var url = APIUrls.pennyDropValidation;

      var bankDetailResp = await apiCalling.postRequest(
          url: url, headers: null, parameters: param, isAlert: false);

      var response = json.decode(bankDetailResp);
      if (response["statusCode"] == "200") {
        final data = response['data'] as Map<String, dynamic>?;
        final paymentTxn =
            data?['paymentTransactionResp'] as Map<String, dynamic>?;
        final statusResp = paymentTxn?['msgHdr']?['rslt'];
        final accountStatusCode = data?['accountStatusCode'];
        final isValid =
            statusResp == 'OK' || accountStatusCode == 'ACCOUNT_IS_VALID';

        if ((userDetails?.userStage ?? 1) > 3 && isValid) {
          getStepsStatus();
          getCustomerDetails();
          // notifyListeners();
        }
        result.isSuccess = isValid;

        if (isValid) {
          result.message = data?['message'] ??
              'Bank Account details verified successfully';
          return result;
        }

        final code = paymentTxn?['msgBdy']?['errorCode'] ?? "";
        if (code.toString().contains("PAY002") ||
            code.toString().contains("PAY003") ||
            code.toString().contains("PAY005")) {
          result.message =
              "We are unable to authenticate your account now. Please try after sometime. You can call our helpline too.";
        } else {
          result.message =
              "We are experiencing server issue. Please try after sometime. You can call our helpline too.";
        }

        return result;
      } else if (response["statusCode"] == "400") {
        final serverMessage = (response["message"] ?? "").toString().trim();
        result.message = serverMessage.isNotEmpty
            ? serverMessage
            : "You can not validate your account more than two times in a week, please try again after 7 days.\nYou can call our helpline too.";
      }
      return result;
    } catch (e) {
      print(e);
      return result;
    }
  }

  /// Aadhar Submit api
  Future<bool> aadharSubmit(param, files) async {
    try {
      var url = APIUrls.aadharUpload;

      var signatoryResp = await apiCalling.dataPostRequestAllPlatform(
          url: url, headers: null, parameters: param, files: files);

      var response = json.decode(signatoryResp);
      if (response["statusCode"] == "200") {
        // checkstatus writes StatusTable; getuserDetails reads enableDialogFiled from it
        await getStepsStatus();
        await getCustomerDetails();
        return true;
      }
      if (response['statusCode'] == "204" &&
          response["message"].toString().toLowerCase().contains("number")) {
        Utils.showAlert(
            context: context,
            msg: response["message"],
            onTap: () {
              GoRouter.of(context).pushNamed(RoutesName.ProfileDetail);
            },
            buttonTitle: "Edit Aadhaar Number");
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Get Mip Details
  Future<List<MipDetails>?> getMipDetails() async {
    try {
      var url = APIUrls.getMipDetails;

      var mipResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        if (response['data'] != null) {
          var mipDetail = <MipDetails>[];
          response['data'].forEach((v) {
            mipDetail.add(new MipDetails.fromJson(v));
          });
          return mipDetail;
        }
        return null;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Save Mip Details
  Future<bool> saveMipDetails(param) async {
    try {
      var url = APIUrls.saveMipDetails;

      var mipResp = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(mipResp);

      if (response["statusCode"] == "200") {
        //updating status data
        getStepsStatus();
      }

      return response["statusCode"] == "200";
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Save Fund-Transfer details
  Future<bool> saveFundTransferDetails(param) async {
    try {
      var url = APIUrls.saveFundTransferDetails;

      var fundTransferRes = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(fundTransferRes);
      if (response["statusCode"] == "200") {
        //for getting updated state
        getStepsStatus();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Get Customer Id list
  Future<List<CustomerIdDetail>?> getCustomerList(phoneNumber) async {
    try {
      var url = APIUrls.getCustomerList + phoneNumber;

      var cidListResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(cidListResp);

      if (response["statusCode"] == "200") {
        if (response['data'] != null) {
          var cidList = <CustomerIdDetail>[];
          response["data"].forEach((v) {
            cidList.add(new CustomerIdDetail.fromJson(v));
          });
          customerIdList = cidList;
          if (customerIdList?.length == 1 && customerIdList?.length != 0) {
            customerId = customerIdList?.first.customerId ?? '';
            if (customerId.isEmpty) {
              Utils.showAlert(
                  context: context,
                  msg: "Your Session Expired. Please Login Again",
                  onTap: () {
                    context.moveInitialPage();
                  });
            }
            // if (Utils.isWeb) {
            _isLoggedIn = true;
            await saveUserState();
            // }
          }
          return cidList;
        }
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get Customer Details
  Future<UserDetails?> getCustomerDetails() async {
    if (customerId.isEmpty) {
      userDetails = null;
      return null;
    }

    //for checking data

    var url = APIUrls.getUserDetails + customerId;

    var cidListResp = await apiCalling.getRequest(url: url, headers: null);

    var response = json.decode(cidListResp);
    if (response["statusCode"] == "200") {
      if (response['data'] != null) {
        final detail = UserDetails.fromJson(response['data']);

        //setting fly data
        FlySdk.loginUser(
            detail.profileDetails!.customerId, detail.profileDetails!.fullName);
        if (!Utils.isWeb) {
          try {
            await SFMCSDK.setContactKey(detail.panDetails?.pan ?? '')
                .timeout(const Duration(seconds: 3));
          } catch (e) {
            print(e);
          }
        }
        userDetails = detail;
        mobileNo = userDetails?.profileDetails?.phoneNumber ?? '';
        await pref!.setString(Constants.mobileNumber, mobileNo ?? "");

        return detail;
      }
    }
    return null;
  }

  /// Create SIP mandate via Cashfree.
  Future<SipCreateResult> createSip(param) async {
    try {
      var url = APIUrls.createSip;

      var cidListResp = await apiCalling.postRequest(
          url: url, parameters: param, headers: null);

      var response = json.decode(cidListResp);
      if (response["statusCode"] == "200" && response['data'] != null) {
        return SipCreateResult(sip: SipDetails.fromJson(response['data']));
      }
      final message = response["message"]?.toString();
      if (message != null && message.isNotEmpty) {
        return SipCreateResult(errorMessage: message);
      }
      return SipCreateResult();
    } catch (e) {
      print(e);
      return SipCreateResult();
    }
  }

  /// IDFC UPI: validate VPA for SIP mandate.
  Future<bool> validateSipUpiMandate(Map<String, dynamic> param) async {
    try {
      var resp = await apiCalling.postRequest(
          url: APIUrls.validateMandate, parameters: param, headers: null);
      var response = json.decode(resp);
      return response["statusCode"] == "200";
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// IDFC UPI: create e-mandate after VPA validation.
  Future<bool> createSipUpiMandate(Map<String, dynamic> param) async {
    try {
      var resp = await apiCalling.postRequest(
          url: APIUrls.createMandate, parameters: param, headers: null);
      var response = json.decode(resp);
      return response["statusCode"] == "200";
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Poll IDFC mandate status (fire-and-forget on backend).
  Future<void> checkSipUpiMandateStatus(Map<String, dynamic> param) async {
    try {
      await apiCalling.postRequest(
          url: APIUrls.checkMandateStatus, parameters: param, headers: null);
    } catch (e) {
      print(e);
    }
  }

  /// Get SIP Details
  Future<SipDetails?> getSipDetails(param) async {
    try {
      var url = APIUrls.getSipDetail;

      var cidListResp = await apiCalling.postRequest(
          url: url, parameters: param, headers: null);

      var response = json.decode(cidListResp);
      if (response["statusCode"] == "200") {
        var detail = SipDetails.fromJson(response['data']);
        if (detail.status == 'submitted') {
          //updating status data
          getStepsStatus();
        }
        return detail;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get Steps Status for menu
  Future<StepsData?> getStepsStatus() async {
    try {
      var url = APIUrls.stepsStatus + customerId;
      var statusRes = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(statusRes);

      if (response["statusCode"] == "200") {
        final decryptStr = decryptedData(response['data']);
        final data = StepsData.fromJson(json.decode(decryptStr));
        stepsData = data;
        //for notify changes to ui
        notifyListeners();
        return data;
      }
    } catch (e) {
      debugPrint("error in get status api");
      return null;
    }
    return null;
  }

  /// Get Fund Transfer instruction form
  Future<String?> getFundInstructionForm() async {
    try {
      var url = APIUrls.downloadFileUrl;

      var cidListResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(cidListResp);
      if (response["statusCode"] == "200") {
        return response['data'];
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get Fund Transfer instruction form
  Future<bool> saveFundInstructionForm(file) async {
    try {
      var url = APIUrls.uploadFileDetails;

      var param = Map<String, String>();
      param[ApiParams.customerId] = customerId;

      var files = Map<String, PlatformFile>();
      files[ApiParams.file] = file;

      var cidListResp = await apiCalling.dataPostRequestAllPlatform(
          url: url, parameters: param, files: files, headers: null);
      var response = json.decode(cidListResp);
      return response["statusCode"] == "200";
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map<String, dynamic>?> getNetWorthCertificate() async {
    try {
      var url = '${APIUrls.netWorthCertificate}?customerId=$customerId';
      var raw = await apiCalling.getRequest(url: url, headers: null);
      var response = json.decode(raw);
      if (response["statusCode"] == "200" && response["data"] is Map) {
        return Map<String, dynamic>.from(response["data"]);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> uploadNetWorthCertificate(PlatformFile file) async {
    try {
      var param = Map<String, String>();
      param[ApiParams.customerId] = customerId;
      var files = Map<String, PlatformFile>();
      files[ApiParams.file] = file;
      var raw = await apiCalling.dataPostRequestAllPlatform(
          url: APIUrls.netWorthCertificate,
          parameters: param,
          files: files,
          headers: null);
      var response = json.decode(raw);
      if (response["statusCode"] == "200") return null;
      return response["message"]?.toString() ?? 'Could not upload the certificate.';
    } catch (e) {
      print(e);
      return 'Could not upload the certificate.';
    }
  }

  /// Update Residence address
  Future<bool> updateResidenceAddress(param) async {
    try {
      var url = APIUrls.updateResidentAddress;

      var cidListResp = await apiCalling.postRequest(
          url: url, parameters: param, headers: null);
      var response = json.decode(cidListResp);
      if (response["statusCode"] == "200") {
        getCustomerDetails();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Update Office address
  Future<bool> updateOfficeAddress(param) async {
    try {
      var url = APIUrls.updateOfficeAddress;

      var cidListResp = await apiCalling.postRequest(
          url: url, parameters: param, headers: null);
      var response = json.decode(cidListResp);
      if (response["statusCode"] == "200") {
        getCustomerDetails();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Get Previous Mip Details
  Future<OldMipDetail?> getPreviousMip() async {
    try {
      var url = APIUrls.getOldMipDetail + customerId;

      var mipResp = await apiCalling.getRequest(url: url, headers: null);
      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        return OldMipDetail.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get Previous Sip Details
  Future<OldSipDetail?> getPreviousSip() async {
    try {
      var url = APIUrls.getOldSipDetails + customerId;

      var mipResp = await apiCalling.getRequest(url: url, headers: null);
      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        return OldSipDetail.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Update profile details
  Future<bool> updateProfile(param) async {
    try {
      var url = APIUrls.updateProfile;

      var mipResp = await apiCalling.postRequest(
          url: url, parameters: param, headers: null);
      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        final jwtToken = response["data"]["jwtResponse"]['token'] ?? null;
        if (jwtToken != null) {
          token = jwtToken;
        }
        getCustomerDetails();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// ///////////////////////////
  /// MARKETPLACE APIS////////////
  /// ///////////////////////////

  /// Get user Funds details api
  Future<bool> getUserFundDetails() async {
    try {
      var url = APIUrls.getAmountDetails + "$customerId"; //customerId;

      var mipResp = await apiCalling.getRequest(url: url, headers: null);
      var response = json.decode(mipResp);
      print('response amount details ${response}');
      if (response["statusCode"] == "200") {
        final decryptStr = decryptedData(response['data']);
        print(json.decode(decryptStr));
        userFundTransferDetails =
            UserFundTransferDetails.fromJson(json.decode(decryptStr));
        final withdrawable = userFundTransferDetails?.withdrawableBalance ??
            userFundTransferDetails?.totalAvailableBalance?.availableBalance ??
            0.0;
        Utils.availableAmount = withdrawable;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<CashFreeOrderResponse?> getCashFreeOrderStatus(String orderId) async {
    try {
      var url = APIUrls.getCashFreeOrderStatus + orderId;

      var mipResp = await apiCalling.getRequest(url: url, headers: null);
      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        final cashFreeResponse =
            CashFreeOrderResponse.fromJson(response['data']);

        //  notifyListeners();
        return cashFreeResponse;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> getMarketPlaceData(
      {bool isNextPage = false,
      bool isFilter = false,
      isLoading = true}) async {
    if (isLoading) {
      isMarketPlaceLoading.value = true;
    }

    if (isNextPage) {
      filterData.pageNo++;
    } else if (isFilter) {
      if (isPrimaryMarketSelected) {
        primaryMarketLoans = null;
      } else {
        secondaryMarketLoans = null;
      }
      notifyListeners();
      filterData.pageNo = 0;
    } else {
      filterData.pageNo = 0;
    }

    if (isPrimaryMarketSelected) {
      await _getPrimaryMarketLoanList();
    } else {
      await _getSecondaryMarketLoanList();
    }

    if (isLoading) {
      isMarketPlaceLoading.value = false;
    }
  }

  Future<void> _getPrimaryMarketLoanList() async {
    final grade = filterData.grade.join(",").replaceAll(" ", "+");
    final products = filterData.products.join(",").replaceAll(" ", "+");
    var url = APIUrls.getPrimaryMarketLoanList +
        '?customerId=${"$customerId"}&pageNo=${filterData.pageNo}&minAmount=${filterData.minAmount}&maxAmount=${filterData.maxAmount}&tenure=${filterData.tenure.round()}&loanGrade=$grade&products=$products';

    var mipResp = await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      //initializing product list for first time
      final decryptStr = decryptedData(response['data']);

      final data = PrimaryMarketLoanResponse.fromJson(json.decode(decryptStr));
      if (filterData.pageNo == 0) {
        filterProducts = data.productNames;

        primaryMarketLoans = data.loanList;
        primaryLoanOverView = data.loanAmountAndSize ?? LoanOverViewDetail();
        overViewDetail = primaryLoanOverView;
        //print(data.loanList);
      } else {
        //if second page then

        data.loanList.forEach((element) {
          if (!primaryMarketLoans!.contains(element)) {
            primaryMarketLoans!.add(element);
          }
        });
      }

      primaryMarketLoans = primaryMarketLoans!.map((e) {
        if (primaryCartList.contains(e)) {
          var cartItemIndex = primaryCartList
              .indexWhere((element) => element.contract == e.contract);
          if (cartItemIndex != -1) {
            e.isAddedToCart = true;
            // e.alreadyFundedAmount = primaryCartList[cartItemIndex].fundedAmount;
            e.fundedAmount = primaryCartList[cartItemIndex].fundedAmount;
          }
          // e.alreadyFunded = true;
        }
        return e;
      }).toList();
    } else {
      if (primaryMarketLoans == null || filterData.pageNo == 0)
        primaryMarketLoans = [];
    }

    notifyListeners();
  }

  Future<void> _getSecondaryMarketLoanList() async {
    final grade = filterData.grade.join(",").replaceAll(" ", "+");
    final products = filterData.products.join(",").replaceAll(" ", "+");

    var url = APIUrls.getSecondaryMarketLoanList +
        '?customerId=${customerId}&pageNo=${filterData.pageNo}&minAmount=${filterData.minAmount}&maxAmount=${filterData.maxAmount}&tenure=${filterData.tenure.round()}&loanGrade=$grade&products=$products';

    var mipResp = await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      //initializing product list for first time
      final decryptStr = decryptedData(response['data']);
      final data = Data.fromJson(json.decode(decryptStr));
      if (filterData.pageNo == 0) {
        secondaryMarketLoans = data.secondaryMarketData;
        secondaryLoanOverView = data.overViewDetail ?? LoanOverViewDetail();
        overViewDetail = secondaryLoanOverView;
        //print(data.loanList);
      } else {
        //if second page then

        data.secondaryMarketData.forEach((element) {
          if (!secondaryMarketLoans!.contains(element)) {
            secondaryMarketLoans!.add(element);
          }
        });
      }

      secondaryMarketLoans = secondaryMarketLoans!.map((e) {
        if (secondaryCartList.contains(e)) {
          e.isAddedToCart = true;
          // e.alreadyFunded = false;
        }
        return e;
      }).toList();
    } else {
      if (secondaryMarketLoans == null) secondaryMarketLoans = [];
    }

    notifyListeners();
  }

  Future<bool> checkoutPrimaryCartLoans() async {
    try {
      var ip = await Utils.getIpAddress();

      // try {
      //   ip = await Ipify.ipv4();
      // } catch (e) {
      //   print("failed to get ip ${e.toString()}");
      // }
      debugPrint("My final amount is ${getTotalCartAmount()}");
      var url = APIUrls.checoutPrimaryMarketLoans;
      var mipResp = await apiCalling.postRequest(
          url: url,
          headers: null,
          parameters: primaryCartList
              .map((e) => {
                    "ip": ip,
                    "customerId": "$customerId",
                    "contract": "${e.contract}",
                    "loanAmount": "${e.loanAmount}",
                    "monaxoRating": "${e.category}",
                    "interestRate": "${e.lenderXIRR}",
                    "tenor": "${e.tenor}",
                    "yourFunding": "${e.fundedAmount}"
                  })
              .toList());

      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        primaryCartList.clear();
        var value = Map<String, dynamic>();
        value["af_revenue"] = getTotalCartAmount();
        value["af_currency"] = "INR";
        filterData.pageNo = 0;
        await _getPrimaryMarketLoanList();
        notifyListeners();
        Future.delayed(Duration(seconds: 5), () {
          Utils.showRatingAlert(context: context);
        });

        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      return false;
    }
  }

  void updateMarketPlaceCardData() {
    if (primaryMarketLoans != null) {
      //updating user cart
      primaryCartList = primaryMarketLoans!
          .where((element) => element.isAddedToCart)
          .map((e) => CommonLoanCart.fromPrimaryMarketLoan(e))
          .toList();
    }

    notifyListeners();
  }

  Future<bool> checkoutItems() async {
    //simulating checking out feature

    var status = false;
    if (isPrimaryMarketSelected) {
      status = await checkoutPrimaryCartLoans();
    } else {
      status = await checkoutSecondaryCartLoans();
    }

    if (status) {
      getMarketPlaceData(isFilter: true);
      getUserFundDetails();
    }
    return status;
  }

  Future<bool> checkoutSecondaryCartLoans() async {
    try {
      var ip = await Utils.getIpAddress();

      // try {
      //   ip = await Ipify.ipv4();
      // } catch (e) {
      //   print("failed to get ip ${e.toString()}");
      // }
      var url = APIUrls.checoutSecondaryMarketLoans;
      var mipResp = await apiCalling.postRequest(
          url: url,
          headers: null,
          parameters: secondaryCartList
              .map((e) => {
                    "ip": ip,
                    "contract": "${e.contract}",
                    "customerId": "$customerId",
                    "OnSale": true,
                    "investorId": "${e.investorId}"
                  })
              .toList());
      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        //initializing product list for first time
        //refreshing the data
        var value = Map<String, dynamic>();
        value["af_revenue"] = getTotalCartAmount();
        value["af_currency"] = "INR";
        // AFSdk.logEvent(AFSdk.af_manualFunding, value);
        secondaryCartList.clear();
        // secondaryCartList.forEach((element) {
        //   element.isAddedToCart = false;
        //   element.alreadyFunded = true;
        //   secondaryMarketLoans!
        //       .where((element) => primaryCartList.contains(element))
        //       .forEach((element) {
        //     element.alreadyFunded = true;
        //   });
        // });

        //  getMarketPlaceData();

        // checkoutPrimaryCartLoans();
        //  primaryCartList.clear();
        //   await getPrimaryMarketLoanList();
        notifyListeners();
        Future.delayed(Duration(seconds: 5), () {
          Utils.showRatingAlert(context: context);
        });
        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      return false;
    }
    notifyListeners();
  }

  void addItemsToCard(int index) async {
    if (isPrimaryMarketSelected) {
      primaryMarketLoans![index].isAddedToCart = true;

      //   primaryMarketLoans![index].alreadyFundedAmount = 1000;
      // primaryMarketLoans![index].fundedAmount = 1000;
      var cardData = primaryMarketLoans![index];
      if (!primaryCartList.contains(cardData)) {
        //only add if not contains
        playCartSound();
        primaryCartList.add(CommonLoanCart.fromPrimaryMarketLoan(cardData));
        //playing cart sound

        notifyListeners();

        if (loanButtonState.currentState != null) {
          await Future.delayed(Duration(milliseconds: 100));
          loanButtonState.currentState!.animate();
        }
      } else {
        Utils.showToast(msg: LanguageHelper.textAlreadyInCart);
      }
    } else {
      secondaryMarketLoans![index].isAddedToCart = true;
      //  secondaryMarketLoans![index].fundedAmount = 1000;
      var cardData = secondaryMarketLoans![index];
      if (!secondaryCartList.contains(cardData)) {
        //only add if not contains

        playCartSound();
        secondaryCartList.add(CommonLoanCart.fromSecondaryMarketLoan(cardData));
        //playing cart sound

        notifyListeners();

        if (loanButtonState.currentState != null) {
          await Future.delayed(Duration(milliseconds: 100));
          loanButtonState.currentState!.animate();
        }
      } else {
        Utils.showToast(msg: LanguageHelper.textAlreadyInCart);
      }
    }
  }

  void removeItemFromCard(String id) {
    if (isPrimaryMarketSelected) {
      //updating the list;

      final index = primaryMarketLoans!.indexWhere((e) => e.contract == id);
      if (index > -1) {
        primaryMarketLoans![index].isAddedToCart = false;
        primaryMarketLoans![index].fundedAmount = 0;
        // primaryMarketLoans![index].alreadyFundedAmount = 0;
      }
      primaryCartList.removeWhere((element) => element.contract == id);
    } else {
      //updating the list;

      debugPrint('id is: ${id}');
      final index = secondaryMarketLoans!.indexWhere((e) => e.investorId == id);
      if (index > -1) {
        secondaryMarketLoans![index].isAddedToCart = false;
        secondaryMarketLoans![index].fundedAmount = 0;
      }
      secondaryCartList.removeWhere((element) => element.investorId == id);
    }

    notifyListeners();
  }

  int getTotalCartAmount() {
    if (isPrimaryMarketSelected) {
      if (primaryCartList.isEmpty) return 0;
      return primaryCartList
          .map((e) => e.fundedAmount)
          .reduce((value, element) => value += element)
          .round();
    } else {
      if (secondaryCartList.isEmpty) return 0;
      return secondaryCartList
          .map((e) => e.fundedAmount)
          .reduce((value, element) => value += element)
          .round();
    }
  }

  ///

  String get customerId => _customerId;

  set customerId(String value) {
    _customerId = value;
    // if (customerId.isEmpty) {
    //   _isLoggedIn = true;
    //   saveUserState();
    // }
  }

  BuildContext get context => _context;

  set context(BuildContext value) {
    _context = value;
    apiCalling.context = value;
    // print("new context set to api call");
  }

  getNextMarketPlaceData() async {
    int currentData = (isPrimaryMarketSelected)
        ? (primaryMarketLoans?.length ?? 0)
        : (secondaryMarketLoans?.length ?? 0);
    //fetching next page data
    await getMarketPlaceData(isNextPage: true);

    int updatedIndex = (isPrimaryMarketSelected)
        ? (primaryMarketLoans?.length ?? 0)
        : (secondaryMarketLoans?.length ?? 0);
    //if no record found
    if (currentData == updatedIndex) {
      if (filterData.pageNo > 0) {
        filterData.pageNo--;
      } else {
        filterData.pageNo = 0;
      }
      Utils.showToast(msg: LanguageHelper.textNoMoreLoans);
    }
  }

  Future<PrimaryLoanDetails?> getPrimaryLoanDetails(int index) async {
    var url = APIUrls.getPrimaryMarketLoanDetailsByContract +
        "?customerId=$customerId&contractId=${primaryMarketLoans![index].contract}";

    var mipResp = await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      final loanDetails =
          PrimaryLoanDetails.fromJson(response['data']['loanDetailsField']);

      //  notifyListeners();
      return loanDetails;
    }
    return null;
  }

  Future<SecondaryMarketLoanDetail?> getSecondaryMarketLoanDetail(
      int index) async {
    var url = APIUrls.getSecondaryMarketLoanDetailByInvestmentId +
        "?investmentOrderId=${secondaryMarketLoans![index].contract}";

    print(index);

    var mipResp = await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      print("data");
      return SecondaryMarketLoanDetail.fromJson(response['data']);
    } else {
      return null;
    }
  }

  int getLoanSum() {
    if (isPrimaryMarketSelected) {
      if (primaryCartList.isEmpty) return 0;

      return (primaryCartList
          .map((e) => e.loanAmount)
          .reduce((value, element) => value += element)).round();
    } else {
      if (secondaryCartList.isEmpty) return 0;

      return (secondaryCartList
          .map((e) => e.loanAmount)
          .reduce((value, element) => value += element)).round();
    }
  }

  playCartSound() async {
    // if(audioPlayer.playing){
    //
    //   print("stopping");
    //   await audioPlayer.stop();
    // }

    await audioPlayer.setAsset("sounds/cart_sound.mp3");
    print("playing sounds");
    audioPlayer.play();
  }

  FilterDetails get filterData =>
      (isPrimaryMarketSelected) ? _primaryMarketFilter : _secondaryMarketFilter;

  set filterData(FilterDetails value) {
    if (isPrimaryMarketSelected) {
      _primaryMarketFilter = value;
    } else {
      _secondaryMarketFilter = value;
    }
  }

  bool get isPrimaryMarketSelected => _isPrimaryMarketSelected;

  set isPrimaryMarketSelected(bool value) {
    _isPrimaryMarketSelected = value;
    overViewDetail = value ? primaryLoanOverView : secondaryLoanOverView;
    // primaryCartList.clear();
    // secondaryCartList.clear();
    // primaryMarketLoans = primaryMarketLoans!.map((e) {
    //   e.isAddedToCart = false;
    //   return e;
    // }).toList();
    // secondaryMarketLoans = secondaryMarketLoans!.map((e) {
    //   e.isAddedToCart = false;
    //   return e;
    // }).toList();
    notifyListeners();
  }

  List<CommonLoanCart> getCurrentCart() {
    return isPrimaryMarketSelected
        ? primaryCartList.where((element) => !element.alreadyFunded).toList()
        : secondaryCartList.where((element) => !element.alreadyFunded).toList();
  }

  Future<RedemptionData?> getRedemptionData() async {
    var url = APIUrls.getRedemptionData + "?customerId=$customerId";
    // var url = APIUrls.getRedemptionData + "?customerId=CID-000250583";

    var mipResp = await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      print("data");
      var redemptionData = RedemptionData.fromJson(response['data']);
      var loanList = redemptionData.loanList.map((e) {
        e.customerId = customerId;
        return e;
      }).toList();
      redemptionData.loanList = loanList;
      return redemptionData;
    } else {
      return null;
    }
  }

  Future<MyInvestmentsResponse?> getMyInvestments({
    String? book,
    int page = 1,
    int? pageSize,
  }) async {
    try {
      var url = '${APIUrls.getMyInvestments}?customerId=$customerId';
      if (book != null && book.isNotEmpty) url += '&book=$book';
      if (pageSize != null) url += '&page=$page&pageSize=$pageSize';
      final mipResp = await apiCalling.getRequest(url: url, headers: null);
      final response = json.decode(mipResp);
      if (response["statusCode"] == "200" && response["data"] != null) {
        return MyInvestmentsResponse.fromJson(response["data"]);
      }
      return MyInvestmentsResponse(loanList: [], count: 0);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<MyInvestmentDetail?> getMyInvestmentDetail(String contractId) async {
    try {
      final url =
          '${APIUrls.getMyInvestmentDetail}?customerId=$customerId&contractId=$contractId';
      final mipResp = await apiCalling.getRequest(url: url, headers: null);
      final response = json.decode(mipResp);
      if (response["statusCode"] == "200" && response["data"] != null) {
        return MyInvestmentDetail.fromJson(response["data"]);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> submitRedemption(List<LoanList> loans) async {
    var url = APIUrls.submitRedemptionData;

    var param = loans.map((e) => e.toJson()).toList();
    var mipResp = await apiCalling.postRequest(
        url: url, headers: null, parameters: param, isAlert: true);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      Utils.showAlert(context: context, msg: response["message"]);
      getMarketPlaceData(isFilter: true);
      getUserFundDetails();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateMipSwitch(param) async {
    var url = APIUrls.mipSwitch;

    var mipResp = await apiCalling.postRequest(
        url: url, headers: null, parameters: param, isAlert: true);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      Utils.showAlert(context: context, msg: response["message"]);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> saveandModifyAutoInvestments(param) async {
    var url = APIUrls.saveandModifyAutoInvestments;

    var saveandModifyAutoInvestmentsResp = await apiCalling.postRequest(
        url: url, headers: null, parameters: param, isAlert: true);
    var response = json.decode(saveandModifyAutoInvestmentsResp);
    if (response["statusCode"] == "200") {
      // Utils.showAlert(context: context, msg: response["message"]);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateAutoInvestSwitch(param) async {
    var url = APIUrls.autoInvestSwitch;

    var mipResp = await apiCalling.postRequest(
        url: url, headers: null, parameters: param, isAlert: true);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      Utils.showAlert(context: context, msg: response["message"]);
      return true;
    } else {
      return false;
    }
  }

  Future<List<StatementData>?> getStatement() async {
    var url = APIUrls.getStatement + "?customerId=$customerId";
    var mipResp = await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      var list = <StatementData>[];
      response['data'].forEach((v) {
        list.add(new StatementData.fromJson(v));
      });
      statementList = list;
      return list;
    } else {
      return null;
    }
  }

  Future<AccountTransactions?> getAccountTransactions() async {
    var url = APIUrls.getAccountTransactions + "?customerId=$customerId";
    try {
      var resp = await apiCalling.getRequest(url: url, headers: null);
      var response = json.decode(resp);
      if (response["statusCode"] == "200" && response["data"] is Map) {
        return AccountTransactions.fromJson(
            Map<String, dynamic>.from(response["data"]));
      }
    } catch (e) {
      debugPrint("getAccountTransactions error: $e");
    }
    return null;
  }

  /// Returns the server message; [success] is true only when the email was sent.
  Future<StatementEmailResult> emailStatement({int? year}) async {
    final param = <String, dynamic>{"customerId": customerId};
    if (year != null) param["year"] = year;
    try {
      var resp = await apiCalling.postRequest(
          url: APIUrls.emailStatement,
          headers: null,
          parameters: param,
          isAlert: false);
      var response = json.decode(resp);
      return StatementEmailResult(
        success: response["statusCode"] == "200",
        message: response["message"]?.toString() ?? '',
      );
    } catch (e) {
      debugPrint("emailStatement error: $e");
      return StatementEmailResult(success: false, message: '');
    }
  }

  Future<void> getAutoInvestCategoryDetails() async {
    var url = APIUrls.getAutoinvestDate;
    var AutoInvestCategoryDetailResp =
        await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(AutoInvestCategoryDetailResp);
    if (response["statusCode"] == "200") {
      var list = <AutoInvestCategoryModel>[];
      response['data'].forEach((v) {
        list.add(new AutoInvestCategoryModel.fromJson(v));
      });
      autoInvestCategoryDetailList = list;
      return;
    }
  }

  Future<void> checkForAppUpdate(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    appVersion = version;
    print("Local version $version");

    var url = APIUrls.getAppVersion;
    var versionResp =
        await apiCalling.getRequest(url: url, headers: null, addToken: false);
    var response = json.decode(versionResp);

    if (response["data"] == null) {
      return;
    }

    if (response["data"]["callSupport"] != null) {
      Constants.callSupportNumber =
          response["data"]["callSupport"] ?? Constants.defaultNumber;
    }

    if (Utils.isWeb) {
      return;
    }

    debugPrint(response.toString());

    var newVer = version;

    if (Utils.isIos && response["data"]["ios"] != null) {
      newVer = response["data"]["ios"];
    } else if (response["data"]["android"] != null) {
      newVer = response["data"]["android"];
    }

    if (newVer != version) {
      Utils.showDoubleBtnAlert(
          context: context,
          msg:
              "A new version of application is available. please update your application",
          onTap: () {
            if (Platform.isAndroid) {
              launch(Constants.playStoreUrl);
            } else if (Platform.isIOS) {
              launch(Constants.appStoreUrl);
            }
          },
          positiveButtonTitle: "Update");
    }
  }

  void setOnBoardStatus(bool value) async {
    if (pref == null) {
      await initPref();
    }

    pref?.setBool(Constants.isOnboarded, value);
  }

  Future<bool> getOnBoardStatus() async {
    if (pref == null) {
      await initPref();
    }

    return pref?.getBool(Constants.isOnboarded) ?? false;
  }

  void setIsRated(bool value) async {
    if (pref == null) {
      await initPref();
    }

    pref?.setBool(Constants.isRated, value);
  }

  Future<bool> getIsRated() async {
    if (pref == null) {
      await initPref();
    }

    return pref?.getBool(Constants.isRated) ?? false;
  }

  void setRatingDate(String value) async {
    if (pref == null) {
      await initPref();
    }

    pref?.setString(Constants.ratingDate, value);
  }

  Future<String> getRatingDate() async {
    if (pref == null) {
      await initPref();
    }

    return pref?.getString(Constants.ratingDate) ?? '';
  }

  Future<bool> withdrawAmount(param) async {
    try {
      var url = APIUrls.withdrawAmount;

      List<Map<String, String>> list = [];
      list.add(param);

      var cidListResp = await apiCalling.postRequest(
          url: url, parameters: list.toList(), headers: null);
      var response = json.decode(cidListResp);
      if (response["statusCode"] == "200") {
        getUserFundDetails();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      var url = APIUrls.logout;
      var param = Map<String, String>();
      param[ApiParams.customerId] = customerId;

      var cidListResp = await apiCalling.postRequest(
          url: url, parameters: param, headers: null);
      var response = json.decode(cidListResp);
      if (response["statusCode"] == "200") {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> authSendOTP(String phoneNo, [newMobileOtp]) async {
    try {
      var url = APIUrls.authSendOtp;

      var param = Map<String, dynamic>();
      param[ApiParams.phoneNo] = phoneNo;
      if (newMobileOtp != null) {
        param[ApiParams.newMobileOtp] = newMobileOtp;
      }

      var otpResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param, isAlert: true);

      var response = json.decode(otpResponse);
      if (response["statusCode"] == "200") {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> authVerifyOTP(String phoneNo, String otp, [newMobileOtp]) async {
    try {
      var url = APIUrls.authVerifyOtp;

      var param = Map<String, dynamic>();
      param[ApiParams.mobileNumber] = phoneNo;
      param[ApiParams.otp] = otp;
      if (newMobileOtp != null) {
        param[ApiParams.newMobileOtp] = newMobileOtp;
        param[ApiParams.customerId] = customerId;
      }

      var otpResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);

      var response = json.decode(otpResponse);
      if (response["statusCode"] == "200") {
        final data = response['data'];
        final responseToken = data is Map ? data['token'] : null;
        if (responseToken != null &&
            (token == null || token == '' || newMobileOtp == null)) {
          token = responseToken;
        }
        if (!isLoggedIn) {
          getCustomerDetails();
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> autoLoginByUser() async {
    try {
      var url = APIUrls.autoLoginByUser;
      var param = Map<String, dynamic>();
      final changedCID = customerId.replaceAll("CID-", "");
      final cidSignature = Constants.autoLoginSignature1 +
          Constants.autoLoginSignature2 +
          Constants.autoLoginSignature3 +
          changedCID +
          Constants.autoLoginSignature4;
      param[ApiParams.customerId] = base64.encode(utf8.encode(cidSignature));

      var otpResponse = await apiCalling.postRequest(
          url: url,
          headers: null,
          parameters: param,
          isAlert: true,
          addToken: false);

      var response = json.decode(otpResponse);
      if (response["statusCode"] == "200") {
        if (response['data']['token'] != null) {
          token = response['data']['token'];
          return true;
        }
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void getFlyyWebToken() async {
    if (!Utils.isWeb) {
      return;
    }

    var url = APIUrls.flyyUserToken;
    var param = Map<String, dynamic>();
    param[ApiParams.isNew] = isNewUser;
    param[ApiParams.username] = userDetails?.profileDetails?.fullName;
    param[ApiParams.extUserId] = customerId;

    var mipResp = await apiCalling.postRequest(
        url: url, parameters: param, headers: null);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      final userToken = response["data"]["token"];
      final deviceId = response["data"]["device_id"];
      final partnerId =
          Constants.isProd ? FlySdk.FlyyProdPartnerId : FlySdk.FlyyDevPartnerId;
      initFlyySdk(userToken, deviceId, partnerId, FlySdk.stage);
    }
  }

  String decryptedData(String encryptedString) {
    final count = 10;
    String finalStr = encryptedString.substring(count);
    if (finalStr.length >= count) {
      finalStr = finalStr.substring(0, finalStr.length - count);
    }
    debugPrint("Final string ${finalStr}");
    return utf8.decode((base64.decode(finalStr)));
  }

  void setOsType(String osType) async {
    var url = APIUrls.osType;
    var param = Map<String, dynamic>();

    param[ApiParams.customerId] = customerId;
    param[ApiParams.osType] = osType;

    var osTypeResp = await apiCalling.postRequest(
        url: url, parameters: param, headers: null);
    var response = json.decode(osTypeResp);
    if (response["statusCode"] == "200") {}
  }

  Future<void> addUserToSegment() async {
    var url = APIUrls.addUSerToSegment + '${customerId}';
    var addUserToSegmentResp =
        await apiCalling.getRequest(url: url, headers: null, addToken: false);
    var response = json.decode(addUserToSegmentResp);
    if (response["statusCode"] == "200") {}
  }

  void setappsFlyIdUpdate(String appsflyerId) async {
    var id = appsflyerId.trim();
    if (id.isEmpty) {
      id = (await AFSdk.ensureAppsFlyerId()).trim();
    }
    // Skip until AppsFlyer UID is ready — empty "" used to trip backend validation.
    if (id.isEmpty || customerId.isEmpty) {
      return;
    }

    var url = APIUrls.appsFlyIdUpdate;
    var param = Map<String, dynamic>();

    param[ApiParams.customer_user_id] = customerId;
    param[ApiParams.appsflyerId] = id;

    var appsFlyIdUpdateResp = await apiCalling.postRequest(
        url: url, parameters: param, headers: null, isAlert: false);
    var response = json.decode(appsFlyIdUpdateResp);
    if (response["statusCode"] == "200") {}
  }

  Future<NewOfferModel?> getOffer() async {
    try {
      var url = APIUrls.offer;
      var param = Map<String, dynamic>();
      param[ApiParams.customerId] = customerId;
      var getOfferResponse = await apiCalling.postRequest(
          url: url, headers: null, parameters: param);
      // partnerClientToken: tokenPartner);
      var response = json.decode(getOfferResponse);
      print('getOfferResponse $response');
      if (response["statusCode"] == "200") {
        return NewOfferModel.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> getVideosData() async {
    try {
      var url = APIUrls.videos;

      var mipResp =
          await apiCalling.getRequest(url: url, headers: null, addToken: false);

      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        if (response['data'] != null) {
          youtubeVideos = YoutubeVideosModel.fromJson(response);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<PortfolioAnalysisModel?> getPortfolioAnalysisData() async {
    // var url = APIUrls.portfolioAnalysis + 'CID-000021488'; //'${customerId}';
    var url = APIUrls.portfolioAnalysis + '${customerId}';
    print('url $url');

    var portfolioResp = await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(portfolioResp);
    if (response["statusCode"] == "200") {
      if (response['data'] != null) {
        portfolioAnalysis = PortfolioAnalysisModel.fromJson(response);
        final summary = response['data']['portfolioSummary'];
        portfolioSummary = summary != null
            ? PortfolioSummary.fromJson(Map<String, dynamic>.from(summary))
            : PortfolioSummary();
        final month = response['data']['monthRepayment'];
        portfolioSummary!.monthRepayment = month is Map
            ? MonthRepayment.fromJson(Map<String, dynamic>.from(month))
            : null;
        notifyListeners();
      }
      return portfolioAnalysis;
    } else {
      portfolioSummary = null;
      return null;
    }
  }

  Future<void> getWylthReferData() async {
    try {
      var url = APIUrls.wylthyReferalData + 'wylth';

      var mipResp =
          await apiCalling.getRequest(url: url, headers: null, addToken: false);

      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        if (response['data'] != null) {
          wylthReferalData = WylthReferDataModel.fromJson(response['data']);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> setWylthyReferWeb(String referId) async {
    try {
      var url = APIUrls.setWylthyRefer;
      var param = Map<String, dynamic>();
      param[ApiParams.type] = "action_event";
      param[ApiParams.name] = "successful_user_referral";
      param[ApiParams.ext_user_id] = customerId;
      param[ApiParams.referrer_ext_user_id] = referId;
      param[ApiParams.created_at] = "";

      var mipResp = await apiCalling.postRequest(
          url: url, headers: null, parameters: param, addToken: false);

      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        print('Wylth Refer Success!!!');
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<ViewDataModel?> getPortfolioRiskData() async {
    // var url = APIUrls.portfolioRiskData + 'CID-000021488'; //'${customerId}';
    var url = APIUrls.portfolioRiskData + '${customerId}';
    print('url $url');

    var portfolioResp = await apiCalling.getRequest(url: url, headers: null);
    var response = json.decode(portfolioResp);
    if (response["statusCode"] == "200") {
      if (response['data'] != null) {
        portfolioRiskAnalysis = ViewDataModel.fromJson(response);
      }
    } else {
      return null;
    }
  }

  Future<PortfolioTabStatusModel?> getPortfolioTabStatus() async {
    try {
      var url = APIUrls.portfolioTabStatus;

      var mipResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        if (response['data'] != null) {
          portfolioTabStatusData = PortfolioTabStatusModel.fromJson(response);
          // print('done ${portfolioTabStatusData}');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<PortfolioTabStatusModel?> getDelinquencyStatus() async {
    try {
      var url = APIUrls.delinquencyTabStatus + '${customerId}';
      // var url = APIUrls.delinquencyTabStatus + 'CID-000375687';

      var mipResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        if (response['data'] != null) {
          delinquencyTabStatusData = DelinquencyStatusModel.fromJson(response);
          print('done ===  ${delinquencyTabStatusData}');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<PortfolioTabStatusModel?> sipOptionVisibility() async {
    try {
      var url = APIUrls.sipOption + '${customerId}';
      // var url = APIUrls.delinquencyTabStatus + 'CID-000375687';

      var mipResp = await apiCalling.getRequest(url: url, headers: null);

      var response = json.decode(mipResp);
      if (response["statusCode"] == "200") {
        if (response['data'] != null) {
          bankDetailData = BankDetailSipModel.fromJson(response);
          // print('done ===  ${bankDetailData}');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> updateSipSwitch(param) async {
    var url = APIUrls.sipSwitch;

    var mipResp = await apiCalling.postRequest(
        url: url, headers: null, parameters: param, isAlert: true);
    var response = json.decode(mipResp);
    if (response["statusCode"] == "200") {
      if (response['data']['statusCode'] == "200") {
        // doneDialog
        //
        param[ApiParams.sipFlag] == true
            ? Utils.showAlert(
                context: context,
                msg: response["data"]["statusMessage"].replaceAll('Â', ''))
            : showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => doneSIPDialog());

        return true;
      }
      return false;
    } else {
      return false;
    }
  }
}
