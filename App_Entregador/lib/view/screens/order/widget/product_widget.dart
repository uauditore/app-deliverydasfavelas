import 'package:app_entregador/controller/splash_controller.dart';
import 'package:app_entregador/data/model/response/order_details_model.dart';
import 'package:app_entregador/helper/price_converter.dart';
import 'package:app_entregador/util/dimensions.dart';
import 'package:app_entregador/util/images.dart';
import 'package:app_entregador/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWidget extends StatelessWidget {
  final OrderDetailsModel orderDetailsModel;
  ProductWidget({@required this.orderDetailsModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),
      child: Row(children: [

        ClipRRect(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), child: FadeInImage.assetNetwork(
          placeholder: Images.placeholder, height: 50, width: 50, fit: BoxFit.cover,
          image: '${Get.find<SplashController>().configModel.baseUrls.productImageUrl}/${orderDetailsModel.foodDetails.image}',
          imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 50, width: 50, fit: BoxFit.cover),
        )),
        SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),

        Text('✕ ${orderDetailsModel.quantity}'),
        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

        Expanded(child: Text(
          orderDetailsModel.foodDetails.name, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
        )),
        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

        Text(
          PriceConverter.convertPrice(orderDetailsModel.price-orderDetailsModel.discountOnFood),
          style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
        ),

      ]),
    );
  }
}
