import 'enums.dart';

class Constants {
  static const String authToken = 'authToken';
  static const String currentUser = 'currentUser';
  static const String isLoggedIn = 'isLoggedIn';
  static const String isRegistered = 'isRegistered';
  static const String token = 'token';
  static const String rememberUserName = 'rememberUserName';
  static const String userStage = 'userStage';
  static const String isOnboarded = 'isOnboarded';
  static const String ratingDate = 'ratingDate';
  static const String isRated = 'isRated';

  static const String appStoreId = '1614462026';

  static const String playStoreUrl =
      "http://play.google.com/store/apps/details?id=com.monexo.lender";
  static const String appStoreUrl =
      "https://apps.apple.com/us/app/monexo-investor/id${appStoreId}";

  /// //////////////////////////////////////////////////
  /// ////////Change environment from here  ////////////
  /// ///Check the CashFree api key before go live /////
  static const environment = Environments.Dev;
  static const isProd = false;

  /// //////////////////////////////////////////////////

  /// CashFree ApiKey For Development
  static const String cashFreeApiKey = "111657f9bcc07e9362d643a838756111";

  //AdGyde app key
  static const iosAdGydeAppKey = 'L427583334441843';
  static const androidAdGydeAppKey = 'L429164016980320';

  ///Hyperverge appId and appKey
  static const String hyperVergeAppId = "244af5";
  static const String hyperVergeAppKey = "3c4bc3d5cba35cbb9176";

  /// Pincode resource api-key
  static const pincodeApiKey =
      '579b464db66ec23bdd000001be9925f848ef448249d6231c74b87637';

  //for generating web token of hyperverse web
  static const HYPERVISE_WEB_LOGIN_URL = "https://auth.hyperverge.co/login";
  static const HYPERVISE_DEMO_TOKEN =
      "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6IjI0NGFmNSIsImhhc2giOiJmYzkwMjJiMGM5MWRiOGJmYzViMmI5MGZiMjEzYTU4OTUxMDA2OTA3YWY0YmM4ODUzMDk2ODA3OWRlMjRjYTBkIiwiaWF0IjoxNjQxODg0NTU5LCJleHAiOjE2NDE5MDI1NTksImp0aSI6IjIzNjBkM2QzLWVjYTYtNDhlOC05NDRkLTgzOWU4NTdkZTgyYyJ9.g3dSbDNdUexIiLrXknEOKbU72q1NuYyh6WLWRyzKhLs1D2QZO4JTm8skaJAOR1_DZgxDZNeeAgF02TF8bnmA82RLRMgG-h6w3c9P703rctAQD6yGe_zYNKuts5-6N3lPRRr1-MO-sOOVT8gpVlq_Fv6cItS65sP2bE3eUMoexFs";

  static const caCertificateUrl =
      "https://monexo-s3-bucket.s3.ap-south-1.amazonaws.com/testingPdf/TestPDFfile.pdf";

  static final fromLogin = "fromLogin";
  static final fromOtp = "fromOtp";
  static final videoUrl = 'videoUrl';
  static final fromProfile = "fromProfile";
  static final mobileNumber = "mobileNumber";
  static final url = 'url';
  static final returnUrl = 'returnUrl';
  static final validateWatchTime = 'validateWatchTime';
  static final amount = 'amount';
  static final viewTitle = 'viewTitle';
  static final contractId = 'contractId';
  static final forSIP = 'forSIP';
  static final cashFreeText = 'cashFreeText';

  static final String customerId = "customerId";

  static final defaultAnimDuration = Duration(milliseconds: 600);

  static final defaultNumber = "04469006363";
  static var callSupportNumber = defaultNumber;

  //// profile url
  static final profileUrl =
      'https://s3.ap-south-1.amazonaws.com/monexo-new-staging/profileImage/';

  static final autoLoginSignature1 = "eyJhbGciOiJIU4523zUxMiJ9";
  static final autoLoginSignature2 = "ACID";
  static final autoLoginSignature3 = "TeyJzdWIiOiI4OD456A1MzUw02659C";
  static final autoLoginSignature4 = "SkyUPuCDJQg";
  static final segmentID = "invester_users";

  /// Video Typ
  static final homeScreenKey = "HomeScreen";
  static final socialImpactKey = "SocialImpact";
  static final fundTransferKey = "FundTransfer";

  ///registration
  static var registration = false;
  static var showOnbaording = true;

  /// Local path of registration selfie (camera capture before bank details).
  static const registrationSelfiePath = 'registration_selfie_path';

  static var paymentMethod = 'paymentMethod';


  static var sipAmount ;
  static var sipTenure;
  static var sipDate;
  static var sipPaymnentMethod ;
  static var sipUpiId;
}
