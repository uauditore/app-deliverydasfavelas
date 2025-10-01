import 'package:app_cliente/controller/theme_controller.dart';
import 'package:app_cliente/helper/route_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/images.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NearByButtonView extends StatelessWidget {
  const NearByButtonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      height: 90,
      margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(
          color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]!,
          blurRadius: 5, spreadRadius: 1,
        )],
      ),
      child: Row(children: [

        Image.asset(Images.nearRestaurant, height: 40, width: 40, fit: BoxFit.cover),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Text(
            'find_nearby_restaurant_near_you'.tr, textAlign: TextAlign.start,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ),

        CustomButton(buttonText: 'see_location'.tr, width: 120, height: 40, onPressed: ()=> Get.toNamed(RouteHelper.getMapViewRoute())),

      ]),
    );
  }
}
