import 'package:app_cliente/controller/order_controller.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryOptionButton extends StatelessWidget {
  final String value;
  final String title;
  final String image;
  final double charge;
  final bool? isFree;
  final int index;
  const DeliveryOptionButton({Key? key, required this.value, required this.title, required this.charge, required this.isFree, required this.image, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      bool select = orderController.deliverySelectIndex == index;
        return InkWell(
          onTap: () {
            orderController.setOrderType(value);
            orderController.selectDelivery(index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: select ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge)
            ),
            child: Row(
              children: [
                // Radio(
                //   value: value,
                //   groupValue: orderController.orderType,
                //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //   onChanged: (String value) => orderController.setOrderType(value),
                //   activeColor: Theme.of(context).primaryColor,
                // ),
                SizedBox(height: 16, width: 16, child: Image.asset(image, color: select ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(title, style: robotoRegular.copyWith(color: select ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)),
                const SizedBox(width: 5),

                // Text(
                //   '(${(value == 'take_away' || isFree) ? 'free'.tr : charge != -1 ? PriceConverter.convertPrice(charge) : 'calculating'.tr})',
                //   style: robotoMedium,
                // ),

              ],
            ),
          ),
        );
      },
    );
  }
}
