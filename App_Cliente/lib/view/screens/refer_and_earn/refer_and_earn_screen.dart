import 'package:app_cliente/controller/auth_controller.dart';
import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/controller/user_controller.dart';
import 'package:app_cliente/helper/link_converter.dart';
import 'package:app_cliente/helper/price_converter.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/images.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/custom_app_bar.dart';
import 'package:app_cliente/view/base/custom_button.dart';
import 'package:app_cliente/view/base/custom_snackbar.dart';
import 'package:app_cliente/view/base/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({Key? key}) : super(key: key);

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    if(_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    String initialLink = 'MobilerDelivery://delivery.mobilerteste.com.br/category-product?id=5&name=QnVyZ2Vy';
    LinkConverter.convertDeepLink(initialLink);
    return Scaffold(
      appBar: CustomAppBar(title: 'refer'.tr),
      body: Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: _isLoggedIn ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Column( children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('earn_money_on_every_referral'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                  '${'one_referral'.tr}= ${PriceConverter.convertPrice(Get.find<SplashController>().configModel != null ? Get.find<SplashController>().configModel!.refEarningExchangeRate!.toDouble() : 0.0)}',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: 40),

              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Column(children: [

                    Image.asset(Images.referImage, width: ResponsiveHelper.isDesktop(context) ? 200 : 100,
                        height: ResponsiveHelper.isDesktop(context) ? 250 : 150, fit: BoxFit.contain),
                    SizedBox(width: 120,
                        child: Text('refer_your_code_to_your_friend'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                    ),
                  ]),
                  SizedBox(width: ResponsiveHelper.isDesktop(context) ? 150 : 50),

                  Column(children: [
                    Image.asset(Images.earnMoney, width: ResponsiveHelper.isDesktop(context) ? 200 : 100,
                        height: ResponsiveHelper.isDesktop(context) ? 250 : 150, fit: BoxFit.contain),
                    SizedBox(width: 120, child: Text(
                        '${'get'.tr} ${PriceConverter.convertPrice(Get.find<SplashController>().configModel != null ? Get.find<SplashController>().configModel!.refEarningExchangeRate!.toDouble() : 0.0)} ${'on_joining'.tr}' , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeOverLarge),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text('your_referral_code'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                DottedBorder(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1,
                  strokeCap: StrokeCap.butt,
                  dashPattern: const [8, 5],
                  padding: const EdgeInsets.all(0),
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(Dimensions.radiusSmall),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    height: 50, decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    child: (Get.find<UserController>().userInfoModel != null) ? Row(children: [
                      Expanded(
                          child: Text('${Get.find<UserController>().userInfoModel != null ? Get.find<UserController>().userInfoModel!.refCode : ''}',
                              style: robotoBlack.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraLarge),
                          ),
                      ),
                      InkWell(
                        onTap: () {
                          if(Get.find<UserController>().userInfoModel!.refCode != null && Get.find<UserController>().userInfoModel!.refCode!.isNotEmpty){
                            Clipboard.setData(ClipboardData(text: '${Get.find<UserController>().userInfoModel != null ? Get.find<UserController>().userInfoModel!.refCode : ''}'));
                            showCustomSnackBar('referral_code_copied'.tr, isError: false);
                          }
                        },
                          child: Text('tap_to_copy'.tr, style: robotoMedium)),
                    ]) : const CircularProgressIndicator(),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomButton(buttonText: 'share'.tr,icon: Icons.share, onPressed: () => Share.share(Get.find<UserController>().userInfoModel!.refCode!)),

            ]),
          ) : const NotLoggedInScreen(),
        ),
      ),
    );
  }
}
