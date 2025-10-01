import 'dart:async';

import 'package:app_cliente/controller/localization_controller.dart';
import 'package:connectivity/connectivity.dart';
import 'package:app_cliente/controller/auth_controller.dart';
import 'package:app_cliente/controller/cart_controller.dart';
import 'package:app_cliente/controller/location_controller.dart';
import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/controller/wishlist_controller.dart';
import 'package:app_cliente/data/model/body/deep_link_body.dart';
import 'package:app_cliente/data/model/body/notification_body.dart';
import 'package:app_cliente/helper/route_helper.dart';
import 'package:app_cliente/util/app_constants.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/view/base/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../flavors.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? notificationBody;
  final DeepLinkBody? linkBody;
  const SplashScreen({Key? key, required this.notificationBody, required this.linkBody}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(!firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        isNotConnected ? const SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if(Get.find<LocationController>().getUserAddress() != null && (Get.find<LocationController>().getUserAddress()!.zoneIds == null
        || Get.find<LocationController>().getUserAddress()!.zoneData == null)) {
      Get.find<AuthController>().clearSharedAddress();
    }
    Get.find<CartController>().getCartData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if(isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = 0;
          if(GetPlatform.isAndroid) {
            minimumVersion = Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
          }else if(GetPlatform.isIOS) {
            minimumVersion = Get.find<SplashController>().configModel!.appMinimumVersionIos;
          }
          if(AppConstants.appVersion < minimumVersion! || Get.find<SplashController>().configModel!.maintenanceMode!) {
            Get.offNamed(RouteHelper.getUpdateRoute(AppConstants.appVersion < minimumVersion));
          }else {
            if(widget.notificationBody != null && widget.linkBody == null) {
              if (widget.notificationBody!.notificationType == NotificationType.order) {
                Get.offNamed(RouteHelper.getOrderDetailsRoute(widget.notificationBody!.orderId));
              }else if(widget.notificationBody!.notificationType == NotificationType.general){
                Get.offNamed(RouteHelper.getNotificationRoute(fromNotification: true));
              }else {
                Get.offNamed(RouteHelper.getChatRoute(notificationBody: widget.notificationBody, conversationID: widget.notificationBody!.conversationId));
              }
            }/*else if(widget.linkBody != null && widget.notificationBody == null){
              if(widget.linkBody.deepLinkType == DeepLinkType.restaurant){
                Get.toNamed(RouteHelper.getRestaurantRoute(widget.linkBody.id));
              }else if(widget.linkBody.deepLinkType == DeepLinkType.category){
                Get.toNamed(RouteHelper.getCategoryProductRoute(widget.linkBody.id, widget.linkBody.name));
              }else if(widget.linkBody.deepLinkType == DeepLinkType.cuisine){
                Get.toNamed(RouteHelper.getCuisineRestaurantRoute(widget.linkBody.id));
              }
            }*/ else {
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.find<AuthController>().updateToken();
                await Get.find<WishListController>().getWishList();
                if (Get.find<LocationController>().getUserAddress() != null) {
                  Get.offNamed(RouteHelper.getInitialRoute());
                } else {
                  Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
                }
              } else {
                if (Get.find<SplashController>().showIntro()!) {
                  if(F.skipLanguage == true){
                    Get.find<LocalizationController>().setLanguage(const Locale('pt', 'BR'));
                    Get.offNamed(RouteHelper.getOnBoardingRoute());
                  }else{
                    if(AppConstants.languages.length > 1) {
                      Get.offNamed(RouteHelper.getLanguageRoute('splash'));
                    }else {
                      Get.offNamed(RouteHelper.getOnBoardingRoute());
                    }
                  }
                } else {
                  Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                }
              }
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
          child: splashController.hasConnection ? Column(
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
          ) : NoInternetScreen(child: SplashScreen(notificationBody: widget.notificationBody, linkBody: widget.linkBody)),
        );
      }),
    );
  }
}
