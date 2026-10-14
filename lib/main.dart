import 'dart:io';

import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/routes_management/app_router.dart';
import 'package:Monexo/supporting_file/appsFlyerSdk.dart';

import 'package:Monexo/supporting_file/fly_sdk.dart';
import 'package:Monexo/supporting_file/notificationService.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/constants.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  NotificationService.initNotification();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppStateProvider appStateProvider;
  late AppRouter appRouter;

  late FlyyFlutterPlugin flyy;
  final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  void initState() {
    super.initState();

    appStateProvider = AppStateProvider(context);
    appRouter = AppRouter();
    //initalizing only in the case of non web
    if (!Utils.isWeb) {
      FlySdk.startFlySdkProcess();
      AFSdk.initSdk();
    }

    // FlySdk.startReferralTracking();
  }

  @override
  void dispose() {
    super.dispose();
    FlySdk.stopProcess();
  }

  var scrollController = ScrollController();

  var data = [0, 1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ChangeNotifierProvider.value(
      value: appStateProvider,
      builder: (context, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: MaterialApp.router(
            builder: (context, child) {
              if (appRouter.router.routerDelegate.navigatorKey.currentContext !=
                  null) {
                appStateProvider.context = appRouter
                    .router.routerDelegate.navigatorKey.currentContext!;
              }
              if (child == null) return SizedBox();

              return child;
            },
            // debugShowCheckedModeBanner: false,
            // localizationsDelegates: [
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            // ],
            routerDelegate: appRouter.router.routerDelegate,
            routeInformationParser: appRouter.router.routeInformationParser,

            theme: ThemeData(
                primaryColor: ColorsUtil.blueColor,
                accentColor: ColorsUtil.arrowColor,
                visualDensity: VisualDensity.compact),
            debugShowCheckedModeBanner: false,
            // home: PaymentWebScreen(cashFreeResponse: CashFreeResponse(data: Data(
            //   url: "https://sandbox.cashfree.com/pg/view/gateway/nkUFT2yf1tgFalP4Q3ZTe96eb11e89663ffef0e957c1f4a3981f"
            // )),),
            // home: Utils.isWeb ? PanVarification() : SplashScreen(),
          ),
        );
      },
    );
  }

  // @override
  // void onLifecycleEvent(LifecycleEvent event) {
  //   print(event.name);
  // }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
