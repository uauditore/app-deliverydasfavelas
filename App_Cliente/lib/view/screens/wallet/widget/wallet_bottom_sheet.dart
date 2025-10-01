
import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/controller/wallet_controller.dart';
import 'package:app_cliente/helper/price_converter.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/custom_button.dart';
import 'package:app_cliente/view/base/custom_snackbar.dart';
import 'package:app_cliente/view/base/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletBottomSheet extends StatefulWidget {
  final bool fromWallet;
  const WalletBottomSheet({Key? key, required this.fromWallet}) : super(key: key);

  @override
  State<WalletBottomSheet> createState() => _WalletBottomSheetState();
}

class _WalletBottomSheetState extends State<WalletBottomSheet> {

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    int? exchangePointRate = Get.find<SplashController>().configModel!.loyaltyPointExchangeRate;
    int? minimumExchangePoint = Get.find<SplashController>().configModel!.minimumPointToTransfer;

    return Container(
      width: 550,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Text('your_loyalty_point_will_convert_to_currency_and_transfer_to_your_wallet'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text('$exchangePointRate ${'points'.tr}= ${PriceConverter.convertPrice(1)}',textDirection: TextDirection.ltr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), border: Border.all(color: Theme.of(context).primaryColor,width: 0.3)),
            child: CustomTextField(
              hintText: '0',
              controller: _amountController,
              inputType: TextInputType.phone,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          GetBuilder<WalletController>(
            builder: (walletController) {
              return !walletController.isLoading ? CustomButton(
                  buttonText: 'convert'.tr,
                  onPressed: () {
                    if(_amountController.text.isEmpty) {
                      if(Get.isBottomSheetOpen!){
                        Get.back();
                      }
                      showCustomSnackBar('input_field_is_empty'.tr);
                    }else{
                      int amount = int.parse(_amountController.text.trim());

                      if(amount <minimumExchangePoint!){
                        if(Get.isBottomSheetOpen!){
                          Get.back();
                        }
                        showCustomSnackBar('${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
                      } else {
                          walletController.pointToWallet(amount, widget.fromWallet);
                        }
                    }
                },
              ) : const Center(child: CircularProgressIndicator());
            }
          ),
        ]),
      ),
    );
  }
}
