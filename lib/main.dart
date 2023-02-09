import 'dart:io';

import 'package:ecats/models/enums/app_bar_enum.dart';
import 'package:ecats/models/enums/page_enum.dart';
import 'package:ecats/widgets/auth/login_body_widget.dart';
import 'package:ecats/widgets/auth/register_body_widget.dart';
import 'package:ecats/widgets/profile/closed_orders_body_widget.dart';
import 'package:ecats/widgets/profile/events_body_widget.dart';
import 'package:ecats/widgets/profile/income_transactions_body_widget.dart';
import 'package:ecats/widgets/profile/income_wallets_body_widget.dart';
import 'package:ecats/widgets/profile/open_orders_body_widget.dart';
import 'package:ecats/widgets/profile/profile_body_widget.dart';
import 'package:ecats/widgets/profile/send_body_widget.dart';
import 'package:ecats/widgets/profile/send_coins_body_widget.dart';
import 'package:ecats/widgets/profile/user_refferals_body_widget.dart';
import 'package:ecats/widgets/profile/wallets_body_widget.dart';
import 'package:ecats/widgets/profile/withdraw_coins_body_widget.dart';
import 'package:ecats/widgets/shared/app_bars/authorized_app_bar_widget.dart';
import 'package:ecats/widgets/shared/app_bars/non_authorized_app_bar_widget.dart';
import 'package:ecats/widgets/shared/error_body_widget.dart';
import 'package:ecats/widgets/shared/loading_body_widget.dart';
import 'package:ecats/widgets/shared/success_body_widget.dart';
import 'package:ecats/widgets/trade/crypto_trade_body_widget.dart';
import 'package:ecats/widgets/trade/pairs_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _storage = const FlutterSecureStorage();

  late Widget currentBodyWidget;
  late PreferredSizeWidget currentAppBarWidget;

  bool _isLoading = true;
  bool _isAuthorized = false;

  late Map<PageEnum, Widget> bodies;
  late Map<AppBarEnum, PreferredSizeWidget> appBars;

  @override
  void initState() {
    dataLoadFunction();
    super.initState();
    //Only while develop
    HttpOverrides.global = MyHttpOverrides();
  }

  dataLoadFunction() async {
    //Initialization AppBars and Bodies
    bodies = <PageEnum, Widget>{
      PageEnum.Loading: LoadingBodyWidget(),
      PageEnum.Login: LoginBodyWidget(screenCallback: changeScreen),
      PageEnum.Register: RegisterBodyWidget(screenCallback: changeScreen),
      PageEnum.Profile: ProfileBodyWidget(screenCallback: changeScreen),
      PageEnum.OpenOrders: const OpenOrdersBodyWidget(),
      PageEnum.ClosedOrders: const ClosedOrdersBodyWidget(),
      PageEnum.IncomeTransactions: const IncomeTransactionsBodyWidget(),
      PageEnum.Events: const EventsBodyWidget(),
      PageEnum.Refferals: const UserRefferalsBodyWidget(),
      PageEnum.Send: SendBodyWidget(screenCallback: changeScreen),
      PageEnum.SendCoins: SendCoinsBodyWidget(screenCallback: changeScreen),
      PageEnum.Success: SuccessBodyWidget(screenCallback: changeScreen),
      PageEnum.Error: ErrorBodyWidget(screenCallback: changeScreen),
      PageEnum.Wallets: WalletsBodyWidget(screenCallback: changeScreen),
      PageEnum.IncomeWallets:
          IncomeWalletsBodyWidget(screenCallback: changeScreen),
      PageEnum.Withdraw: WithdrawCoinsBodyWidget(screenCallback: changeScreen),
      PageEnum.Pairs: PairsBodyWidget(screenCallback: changeScreen),
      PageEnum.CryptoTrade: CryptoTradeBodyWidget(screenCallback: changeScreen)
    };

    appBars = <AppBarEnum, PreferredSizeWidget>{
      AppBarEnum.Authorized:
          AuthorizedAppBarWidget(screenCallback: changeScreen),
      AppBarEnum.NonAuthorized:
          NonAuthorizedAppBarWidget(screenCallback: changeScreen)
    };

    //Fetch some data
    //await _storage.deleteAll();
    var token = await _storage.read(key: 'token');

    setState(() => _isAuthorized = token == null ? false : true);

    await Future.delayed(const Duration(seconds: 3));

    setState(() => _isLoading = false);

    //Set current AppBar
    currentAppBarWidget = (_isAuthorized
        ? appBars[AppBarEnum.Authorized]
        : appBars[AppBarEnum.NonAuthorized])!;

    //Set current Body
    currentBodyWidget =
        (_isAuthorized ? bodies[PageEnum.Profile] : bodies[PageEnum.Login])!;
  }

  changeScreen(PageEnum pageEnum, AppBarEnum appBarEnum, dynamic? args) =>
      setState(() {
        switch (pageEnum) {
          case PageEnum.SendCoins:
            (bodies[pageEnum] as SendCoinsBodyWidget).currency = args as String;
            break;
          case PageEnum.Error:
            (bodies[pageEnum] as ErrorBodyWidget).errorMessage = args as String;
            break;
          case PageEnum.Withdraw:
            (bodies[pageEnum] as WithdrawCoinsBodyWidget).currency =
                args as String;
            break;
          case PageEnum.CryptoTrade:
            (bodies[pageEnum] as CryptoTradeBodyWidget).acronim =
                args as String;
            break;
        }
        currentBodyWidget = bodies[pageEnum]!;
        currentAppBarWidget = appBars[appBarEnum]!;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: _isLoading
            ? Scaffold(body: bodies[PageEnum.Loading])
            : Scaffold(appBar: currentAppBarWidget, body: currentBodyWidget));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
