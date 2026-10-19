import 'dart:convert';
// import 'dart:html';

import 'package:peerbridge/modules/authentication/screens/landing_screen.dart';
import 'package:peerbridge/modules/authentication/screens/login_screen.dart';
import 'package:peerbridge/modules/authentication/screens/onboarding_screen.dart';
import 'package:peerbridge/modules/authentication/screens/otp_varification.dart';
import 'package:peerbridge/modules/authentication/screens/pan_varification.dart';
import 'package:peerbridge/modules/authentication/screens/personal_detail.dart';
import 'package:peerbridge/modules/authentication/screens/splash_screen.dart';
import 'package:peerbridge/modules/authentication/screens/term_condtion_screen.dart';
import 'package:peerbridge/modules/authentication/screens/welcome_back_screen.dart';
import 'package:peerbridge/modules/bankDetails/screens/bank_details.dart';
import 'package:peerbridge/modules/bankDetails/screens/penny_drop_screen.dart';
import 'package:peerbridge/modules/bankDetails/screens/selfie_capture_screen.dart';
import 'package:peerbridge/modules/bankDetails/screens/welcome_screen.dart';
import 'package:peerbridge/modules/shell/main_shell.dart';
import 'package:peerbridge/modules/home/screens/player_video_page.dart';
import 'package:peerbridge/modules/home/screens/view_detail_screen.dart';
import 'package:peerbridge/modules/marketplace/screens/market_place_screen.dart';
import 'package:peerbridge/modules/marketplace/screens/redemption_screen.dart';
import 'package:peerbridge/modules/marketplace/screens/my_investments_screen.dart';
import 'package:peerbridge/modules/marketplace/screens/my_investment_detail_screen.dart';
import 'package:peerbridge/modules/marketplace/screens/withdraw_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/aadhaar_verification.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/authorized_signatory_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/auto_investment.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/cheque_Deposite_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/first_deposit_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/fund_transfer_process_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/fund_transfer_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/mip_set_up.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/nominee_detail_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/sip_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/sip_success_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/sip_upi_screen1.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/sip_upi_screen2.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/sip_upi_screen3.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/sip_web_view.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/whats_next_screen.dart';
import 'package:peerbridge/modules/profile/screens/profile_detail_screen.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../modules/authentication/screens/welcome_wylth_screen.dart';
import '../modules/home/screens/portfolio_analysis_screen.dart';
import '../modules/home/screens/account_statement_screen.dart';
import '../modules/home/screens/profile_screen.dart';
import '../modules/marketplace/screens/new_market_place_screen.dart';
import '../modules/onboardingSteps/screens/fund_transfer_success_screen.dart';
import '../modules/onboardingSteps/screens/new_fund_transfer_screen.dart';
import '../modules/onboardingSteps/screens/sip_mip_intro_screen.dart';
import '../widgets/profile_end_nav_bar.dart';

class AppRouter {
  String getInitialRoute() {
    return Utils.isWeb ? RoutesName.Splash : RoutesName.Splash; //"/otp"
  }

  // AppStateProvider appStateProvider;
  late GoRouter router;

  AppRouter() {
    router = GoRouter(
        redirect: (state) {
          //after login and redirect to login handling will be takes place here

          // if(appStateProvider.isLoggingIn && state.location!=RoutesName.Splash)
          //   {
          //     return RoutesName.Splash;
          //   }

          // var logginIn = appStateProvider.isLoggingIn;
          // if (logginIn) {
          //   return '/';
          // }
          // if (!appStateProvider.isLoggedIn && !logginIn) {
          //   return RoutesName.PanVerification;
          // }

          return null;
        },

        // navigatorBuilder: (context, state, child) =>
        //     ChangeNotifierProvider.value(
        //       value: AppStateProvider(context),
        //     //  child: child,
        //       builder: (_, __) => child,
        //     ),

        debugLogDiagnostics: true,
        initialLocation: getInitialRoute(),
        // refreshListenable: appStateProvider,
        errorPageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            name: "error",
            child: Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Something went wrong ${state.error}"),
                  SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    titleStr: "Refresh Now",
                    onPress: () {
                      context.push(RoutesName.Splash);
                    },
                  )
                ],
              ),
            )),
        routes: routes);
  }

  //routing supporting by app
  List<GoRoute> routes = [
    GoRoute(
        path: RoutesName.Splash,
        name: "splash",
        routes: [
          GoRoute(
              path: RoutesName.WhatsNext,
              name: RoutesName.WhatsNext,
              pageBuilder: (context, state) {
                context.read<AppStateProvider>().customerId =
                    Utils.getCidFromUrl(state.queryParams["data"] ?? "");
                final token = context.read<AppStateProvider>().token ?? '';
                if (token == '') {
                  context.read<AppStateProvider>().token =
                      Utils.getTokenFromUrl(state.queryParams["data"] ?? "");
                }
                return MaterialPage(
                    key: state.pageKey, child: WhatsNextScreen());
              }),
          GoRoute(
            path: RoutesName.MarketPlace,
            name: RoutesName.MarketPlace,
            pageBuilder: (context, state) {
              context.read<AppStateProvider>().customerId =
                  Utils.getCidFromUrl(state.queryParams["data"] ?? "");
              final token = context.read<AppStateProvider>().token ?? '';
              if (token == '') {
                context.read<AppStateProvider>().token =
                    Utils.getTokenFromUrl(state.queryParams["data"] ?? "");
              }
              return MaterialPage(key: state.pageKey, child: MarketPlace());
            },
          ),
          GoRoute(
            path: RoutesName.NewMarketPlace,
            name: RoutesName.NewMarketPlace,
            pageBuilder: (context, state) {
              context.read<AppStateProvider>().customerId =
                  Utils.getCidFromUrl(state.queryParams["data"] ?? "");
              final token = context.read<AppStateProvider>().token ?? '';
              if (token == '') {
                context.read<AppStateProvider>().token =
                    Utils.getTokenFromUrl(state.queryParams["data"] ?? "");
              }
              return MaterialPage(
                  key: state.pageKey,
                  child: NewMarketPlace(
                    showSocialImpactLoans: Utils.showSocialImpactLoans,
                  ));
            },
          ),
          GoRoute(
              path: RoutesName.Dialog,
              name: RoutesName.Dialog,
              pageBuilder: (context, state) {
                var message = state.queryParams["message"] ?? "";

                return MaterialPage(
                    fullscreenDialog: true,
                    key: state.pageKey,
                    child: Material(
                      color: Colors.transparent,
                      child: AlertDialog(
                        title: Text("i am diloag"),
                      ),
                    ));
              }),
          GoRoute(
              path: RoutesName.OnboardingScreen,
              name: RoutesName.OnboardingScreen,
              pageBuilder: (context, state) {
                return MaterialPage(
                    key: state.pageKey, child: OnboardingScreen());
              }),
          GoRoute(
              path: RoutesName.LandingScreen,
              name: RoutesName.LandingScreen,
              pageBuilder: (context, state) {
                return MaterialPage(key: state.pageKey, child: LandingScreen());
              }),
          GoRoute(
              path: RoutesName.PanVerification,
              name: RoutesName.PanVerification,
              pageBuilder: (context, state) {
                return MaterialPage(
                    key: state.pageKey, child: PanVerification());
              }),
          GoRoute(
              path: RoutesName.WelcomeWylthScreen,
              name: RoutesName.WelcomeWylthScreen,
              pageBuilder: (context, state) {
                return MaterialPage(
                    key: state.pageKey, child: WelcomeWylthScreen());
              }),
          GoRoute(
              path: RoutesName.Login,
              name: RoutesName.Login,
              pageBuilder: (context, state) {
                return MaterialPage(key: state.pageKey, child: LoginScreen());
              }),
          GoRoute(
              path: RoutesName.PersonalDetail,
              name: RoutesName.PersonalDetail,
              pageBuilder: (context, state) {
                return MaterialPage(
                    key: state.pageKey, child: PersonalDetailScreen());
              }),
          GoRoute(
              path: RoutesName.OTPVerification +
                  "/:" +
                  Constants.fromLogin +
                  "/:" +
                  Constants.mobileNumber,
              name: RoutesName.OTPVerification,
              pageBuilder: (context, state) {
                final fromLogin = state.params["fromLogin"] ?? "false";
                final mobileNumber = state.params["mobileNumber"] ?? "";

                return MaterialPage(
                    key: state.pageKey,
                    child: OTPVarificationScreen(
                      mobileNumber: mobileNumber,
                      fromLogin: fromLogin == "true",
                    ));
              }),
          GoRoute(
              path: RoutesName.WelcomeBack,
              name: RoutesName.WelcomeBack,
              pageBuilder: (context, state) {
                return MaterialPage(
                    key: state.pageKey, child: WelcomeBackScreen());
              }),
          GoRoute(
              path: RoutesName.Welcome,
              name: RoutesName.Welcome,
              pageBuilder: (context, state) {
                return MaterialPage(key: state.pageKey, child: WelcomeScreen());
              }),
          GoRoute(
              path: RoutesName.TermsWebView,
              name: RoutesName.TermsWebView,
              pageBuilder: (context, state) {
                return MaterialPage(key: state.pageKey, child: TermWebScreen());
              }),
          ...commonRoutes,
        ],
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: SplashScreen());
        }),
  ];

  //these are used within the app
  static final commonRoutes = [
    GoRoute(
        path: RoutesName.SelfieCapture,
        name: RoutesName.SelfieCapture,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey, child: SelfieCaptureScreen());
        }),
    GoRoute(
        path: RoutesName.BankDetail,
        name: RoutesName.BankDetail,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: BankDetailScreen());
        }),
    GoRoute(
        path: RoutesName.PennyDrop,
        name: RoutesName.PennyDrop,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: PennyDropScreen());
        }),
    GoRoute(
        path: RoutesName.FundTransfer,
        name: RoutesName.FundTransfer,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: FundTransferScreen());
        }),
    GoRoute(
        path: RoutesName.NewFundTransferScreen,
        name: RoutesName.NewFundTransferScreen,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey, child: NewFundTransferScreen());
        }),
    GoRoute(
        path: RoutesName.ChequeDepositScreen,
        name: RoutesName.ChequeDepositScreen,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: ChequeDepositScreen());
        }),
    GoRoute(
        path: RoutesName.FundTransferProcess,
        name: RoutesName.FundTransferProcess,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey, child: FundTransferProcessScreen());
        }),
    GoRoute(
        path: RoutesName.AuthorizedSignatory,
        name: RoutesName.AuthorizedSignatory,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey, child: AuthorizedSignatoryScreen());
        }),
    GoRoute(
        path: RoutesName.AadharVerification,
        name: RoutesName.AadharVerification,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey, child: AadhaarVerificationScreen());
        }),
    GoRoute(
        path: RoutesName.HomeScreen,
        name: RoutesName.HomeScreen,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey,
              child: MainShell(
                initialTab: ShellTab.fromQuery(state.queryParams['tab']),
              ));
        }),
    GoRoute(
        path: RoutesName.PortfolioAnalysis,
        name: RoutesName.PortfolioAnalysis,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: PortfolioAnalysis());
        }),
    GoRoute(
        path:
            RoutesName.ViewDetailPortfolioAnalysis + "/:" + Constants.viewTitle,
        name: RoutesName.ViewDetailPortfolioAnalysis,
        pageBuilder: (context, state) {
          final viewTitle = state.params["viewTitle"] ?? "";
          return MaterialPage(
              key: state.pageKey,
              child: ViewDetailPortfolioAnalysis(
                viewTitle: viewTitle,
              ));
        }),
    GoRoute(
        path: RoutesName.FirstDepositScreen + "/:" + Constants.fromOtp,
        name: RoutesName.FirstDepositScreen,
        pageBuilder: (context, state) {
          final fromOtp = state.params["fromOtp"] ?? "false";
          return MaterialPage(
              key: state.pageKey,
              child: FirstDepositScreen(
                fromOtp: fromOtp == "true",
              ));
        }),
    GoRoute(
        path: RoutesName.VideoPlayerPage +
            "/:" +
            Constants.videoUrl +
            "/:" +
            Constants.validateWatchTime,
        name: RoutesName.VideoPlayerPage,
        pageBuilder: (context, state) {
          final videoUrl = state.params["videoUrl"] ?? "www.google.com";
          final validateWatchTime =
              state.params["validateWatchTime"] ?? 'false';
          return MaterialPage(
              key: state.pageKey,
              child: PlayerVideoPage(
                videoURL: videoUrl,
                validateWatchTime: validateWatchTime == 'false' ? false : true,
              ));
        }),
    GoRoute(
        path: RoutesName.SettingsScreen,
        name: RoutesName.SettingsScreen,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: NavBarWidget());
        }),
    GoRoute(
        path: RoutesName.ProfileScreen,
        name: RoutesName.ProfileScreen,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: ProfileScreen());
        }),
    GoRoute(
        path: RoutesName.AutoInvestment,
        name: RoutesName.AutoInvestment,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey, child: AutoInvestmentScreen());
        }),
    GoRoute(
        path: RoutesName.MIPSetUp,
        name: RoutesName.MIPSetUp,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: MIPSetup());
        }),
    GoRoute(
        path: RoutesName.SIP,
        name: RoutesName.SIP,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: SIPScreen());
        },
        routes: [
          GoRoute(
              path: RoutesName.SipWebView,
              name: RoutesName.SipWebView,
              pageBuilder: (context, state) {
                final extra = state.extra;
                final args = extra is Map
                    ? Map<String, dynamic>.from(extra as Map)
                    : <String, dynamic>{};
                final rawReturnUrl =
                    args[Constants.returnUrl]?.toString().trim() ?? '';
                final returnUrl = rawReturnUrl.isNotEmpty
                    ? rawReturnUrl
                    : "https://www.monexo.co/in/";
                return MaterialPage(
                    key: state.pageKey,
                    child: SipWebView(
                      url: args[Constants.url]?.toString() ?? "",
                      returnUrl: returnUrl,
                      amount: args[Constants.amount]?.toString() ?? "",
                    ));
              })
        ]),
    GoRoute(
        path: RoutesName.Redemption,
        name: RoutesName.Redemption,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: RedemptionScreen());
        }),
    GoRoute(
        path: RoutesName.AccountStatement,
        name: RoutesName.AccountStatement,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey, child: const AccountStatementScreen());
        }),
    GoRoute(
        path: RoutesName.MyInvestments,
        name: RoutesName.MyInvestments,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: MyInvestmentsScreen());
        }),
    GoRoute(
        path: '${RoutesName.MyInvestmentDetail}/:${Constants.contractId}',
        name: RoutesName.MyInvestmentDetail,
        pageBuilder: (context, state) {
          final contractId = state.params[Constants.contractId] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: MyInvestmentDetailScreen(contractId: contractId),
          );
        }),
    GoRoute(
        path: RoutesName.Withdraw,
        name: RoutesName.Withdraw,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: WithdrawScreen());
        }),
    GoRoute(
        path: RoutesName.ProfileDetail,
        name: RoutesName.ProfileDetail,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: ProfileDetailScreen());
        }),
    GoRoute(
        path: RoutesName.NomineeDetail,
        name: RoutesName.NomineeDetail,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: NomineeDetailScreen());
        }),
    GoRoute(
        path: RoutesName.FundTransferSuccessScreen +
            "/:" +
            Constants.amount +
            "/:" +
            Constants.cashFreeText,
        name: RoutesName.FundTransferSuccessScreen,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey,
              child: FundTransferSuccessScreen(
                  amount: state.params[Constants.amount] ?? "",
                  cashFreeText: state.params[Constants.cashFreeText] ?? ""));
        }),
    GoRoute(
        path: RoutesName.IntroScreen + "/:" + Constants.forSIP,
        name: RoutesName.IntroScreen,
        pageBuilder: (context, state) {
          final forSIP = state.params["forSIP"] ?? "false";
          return MaterialPage(
              key: state.pageKey,
              child: SIPMIPIntroScreen(
                forSIP: forSIP == "true",
              ));
        }),
    GoRoute(
        path: RoutesName.UPIScreen1,
        name: RoutesName.UPIScreen1,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: UPIScreenFirst());
        }),
    GoRoute(
        path: RoutesName.UPIScreen2,
        name: RoutesName.UPIScreen2,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: UPIScreenSecond());
        }),
    GoRoute(
        path: RoutesName.UPIScreen3,
        name: RoutesName.UPIScreen3,
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: UPIScreenThird());
        }),
    GoRoute(
        path: RoutesName.UPISuccessScreen + "/:" + Constants.paymentMethod,
        name: RoutesName.UPISuccessScreen,
        pageBuilder: (context, state) {
          return MaterialPage(
              key: state.pageKey,
              child: UPISuccessScreen(
                paymentMethod: state.params[Constants.paymentMethod] ?? "",
              ));
        }),
  ];
}

extension RouteContext on BuildContext {
  /// Navigate to Initial Page according to User current state
  void moveInitialPage() async {
    //  this.read<AppStateProvider>().context = this;

    final initialPage = () async {
      if (Utils.isWeb) {
        // if (window.location.href.contains(RoutesName.WelcomeWylthScreen)) {
        //   this.goNamed(RoutesName.WelcomeWylthScreen);
        // } else {
        this.goNamed(RoutesName.LandingScreen);
        // }

      } else {
        bool isOnBoarded =
            await this.read<AppStateProvider>().getOnBoardStatus();

        if (isOnBoarded) {
          this.goNamed(RoutesName.LandingScreen);
        } else {
          this.goNamed(RoutesName.OnboardingScreen);
        }
      }
    };

    if (this.read<AppStateProvider>().userDetails == null) {
      await initialPage();
    }

    print("not null user stage");
    var userState = this.read<AppStateProvider>().userDetails?.userStage ?? 1;

    print("steps count is ${userState.toString()}");
    // //TODO if bank details working fine
    //  userState =3;
    switch (userState) {
      case 1:
        await initialPage();
        break;

      case 2:
        this.goNamed(RoutesName.FirstDepositScreen, params: {
          Constants.fromOtp: "true",
        });
        break;

      case 3:
        this.goNamed(RoutesName.FirstDepositScreen, params: {
          Constants.fromOtp: "false",
        });
        break;

      case 4:
        this
          ..pushNamed(RoutesName.HomeScreen, queryParams: {
            "data": Utils.buildTokenJson(
                this.read<AppStateProvider>().token ?? "",
                this.read<AppStateProvider>().customerId)
          });
        break;

      default:
        await initialPage();
        break;
    }
  }
}

extension on String {
  String base64StringEncodeOriginal() {
    if (this.trim().isEmpty == true) return '';
    String lowerCasedString = (this);
    var bytes = utf8.encode(lowerCasedString);
    return base64.encode(bytes);
  }

  String base64StringDecodeOriginal() {
    if (this.trim().isEmpty == true) return '';
    String lowerCasedString = (this);
    // var bytes = utf8.decode(lowerCasedString);
    // return base64.encode(bytes);
    return utf8.decode(base64.decode(lowerCasedString));
  }
}
