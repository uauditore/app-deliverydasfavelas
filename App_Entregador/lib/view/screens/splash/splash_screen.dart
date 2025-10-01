import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:app_entregador/controller/auth_controller.dart';
import 'package:app_entregador/controller/splash_controller.dart';
import 'package:app_entregador/helper/route_helper.dart';
import 'package:app_entregador/util/dimensions.dart';
import 'package:app_entregador/util/images.dart';
import 'package:app_entregador/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../flavors.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool _firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (!_firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        isNotConnected ? SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection' : 'connected',
            textAlign: TextAlign.center,
          ),
        ));
        if (!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if (isSuccess) {
        Timer(Duration(seconds: 1), () async {
          if (Get.find<SplashController>().configModel.maintenanceMode) {
            Get.offNamed(RouteHelper.getUpdateRoute(false));
          } else {
            if (Get.find<AuthController>().isLoggedIn()) {
              Get.find<AuthController>().updateToken();
              await Get.find<AuthController>().getProfile();
              Get.offNamed(RouteHelper.getInitialRoute());
            } else {
              Get.offNamed(RouteHelper.getSignInRoute());
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                //padding: EdgeInsets.all(media.width * 0.01),
                width: media.width, // * 0.429,
                height: media.height, // * 0.429,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/logos/${F.splashImage}'),
                        fit: BoxFit.cover
                    )
                ),
              ),
              // Image.asset('assets/logos/${F.logoImage}', width: 150),
              // const SizedBox(height: Dimensions.paddingSizeLarge),
              //Image.asset(Images.logoName, width: 0),

              /*SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
            Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: 25)),*/
            ],
          ),
        );
      }),
    );
  }
}
