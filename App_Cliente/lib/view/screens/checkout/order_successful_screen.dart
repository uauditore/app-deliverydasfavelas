import 'dart:async';
import 'package:app_cliente/controller/order_controller.dart';
import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/controller/theme_controller.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/helper/route_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/images.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/custom_button.dart';
import 'package:app_cliente/view/base/web_menu_bar.dart';
import 'package:app_cliente/view/screens/checkout/widget/payment_failed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final int status;
  final double? totalAmount;
  const OrderSuccessfulScreen({Key? key, required this.orderID, required this.status, required this.totalAmount}) : super(key: key);

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<OrderController>().trackOrder(widget.orderID.toString(), null, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: GetBuilder<OrderController>(builder: (orderController) {
        double total = 0;
        bool success = true;
        if(orderController.trackModel != null) {
          total = ((orderController.trackModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
          success = orderController.trackModel!.paymentStatus == 'paid' || orderController.trackModel!.paymentMethod == 'cash_on_delivery';

          if (!success && !Get.isDialogOpen! && orderController.trackModel!.orderStatus != 'canceled') {
            Future.delayed(const Duration(seconds: 1), () {
              Get.dialog(PaymentFailedDialog(orderID: widget.orderID, orderAmount: total, maxCodOrderAmount: total), barrierDismissible: false);
            });
          }
        }

        return orderController.trackModel != null ? Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Image.asset(success ? Images.checked : Images.warning, width: 100, height: 100),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            success ? 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Text(
              success ? 'your_order_is_placed_successfully'.tr : 'your_order_is_failed_to_place_because'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              textAlign: TextAlign.center,
            ),
          ),

          (success && Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 && total.floor() > 0 )  ? Column(children: [

            Image.asset(Get.find<ThemeController>().darkTheme ? Images.giftBox1 : Images.giftBox, width: 150, height: 150),

            Text('congratulations'.tr , style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Text(
                '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).disabledColor),
                textAlign: TextAlign.center,
              ),
            ),

          ]) : const SizedBox.shrink() ,
          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: CustomButton(buttonText: 'back_to_home'.tr, onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute())),
          ),

        ]))) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
