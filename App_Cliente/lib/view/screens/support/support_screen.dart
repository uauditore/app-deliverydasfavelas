import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/images.dart';
import 'package:app_cliente/view/base/custom_app_bar.dart';
import 'package:app_cliente/view/base/custom_snackbar.dart';
import 'package:app_cliente/view/screens/support/widget/support_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../flavors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'help_support'.tr),
      body: Scrollbar(child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Image.asset(Images.supportImage, height: 120),
          const SizedBox(height: 30),

          Image.asset('assets/logos/${F.logoImage}', width: 100),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          //Image.asset(Images.logoName, width: 100),
          /*Text(AppConstants.APP_NAME, style: robotoBold.copyWith(
            fontSize: 20, color: Theme.of(context).primaryColor,
          )),*/
          const SizedBox(height: 30),

          SupportButton(
            icon: Icons.location_on, title: 'address'.tr, color: Colors.blue,
            info: Get.find<SplashController>().configModel!.address,
            onTap: () {},
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SupportButton(
            icon: Icons.call, title: 'call'.tr, color: Colors.red,
            info: Get.find<SplashController>().configModel!.phone,
            onTap: () async {
              if(await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication);
              }else {
                showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
              }
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SupportButton(
            icon: Icons.mail_outline, title: 'email_us'.tr, color: Colors.green,
            info: Get.find<SplashController>().configModel!.email,
            onTap: () {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: Get.find<SplashController>().configModel!.email,
              );
              launchUrlString(emailLaunchUri.toString(), mode: LaunchMode.externalApplication);
            },
          ),

        ]))),
      )),
    );
  }
}
