import 'package:app_cliente/controller/auth_controller.dart';
import 'package:app_cliente/helper/route_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConditionCheckBox extends StatelessWidget {
  final AuthController authController;
  const ConditionCheckBox({Key? key, required this.authController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Checkbox(
        activeColor: Theme.of(context).primaryColor,
        value: authController.acceptTerms,
        onChanged: (bool? isChecked) => authController.toggleTerms(),
      ),
      Text('i_agree_with'.tr, style: robotoRegular),
      InkWell(
        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: Text('terms_conditions'.tr, style: robotoMedium.copyWith(color: Colors.blue)),
        ),
      ),
    ]);
  }
}
