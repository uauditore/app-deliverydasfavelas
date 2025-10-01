import 'package:app_cliente/controller/cart_controller.dart';
import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/data/model/response/cart_model.dart';
import 'package:app_cliente/data/model/response/product_model.dart';
import 'package:app_cliente/helper/price_converter.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/custom_image.dart';
import 'package:app_cliente/view/base/product_bottom_sheet.dart';
import 'package:app_cliente/view/base/quantity_button.dart';
import 'package:app_cliente/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartProductWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  const CartProductWidget({Key? key, required this.cart, required this.cartIndex, required this.isAvailable, required this.addOns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String addOnText = '';
    int index0 = 0;
    List<int?> ids = [];
    List<int?> qtys = [];
    for (var addOn in cart.addOnIds!) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    for (var addOn in cart.product!.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText = '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        index0 = index0 + 1;
      }
    }

    String variationText = '';

    if(cart.variations!.isNotEmpty) {
      for(int index=0; index<cart.variations!.length; index++) {
        if(cart.variations![index].isNotEmpty && cart.variations![index].contains(true)) {
          variationText += '${variationText.isNotEmpty ? ', ' : ''}${cart.product!.variations![index].name} (';

          for(int i=0; i<cart.variations![index].length; i++) {
            if(cart.variations![index][i]!) {
              variationText += '${variationText.endsWith('(') ? '' : ', '}${cart.product!.variations![index].variationValues![i].level}';
            }
          }
          variationText += ')';
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () {
          ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (con) => ProductBottomSheet(product: cart.product, cartIndex: cartIndex, cart: cart),
          ) : showDialog(context: context, builder: (con) => Dialog(
            child: ProductBottomSheet(product: cart.product, cartIndex: cartIndex, cart: cart),
          ));
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
          child: Stack(children: [
            const Positioned(
              top: 0, bottom: 0, right: 0, left: 0,
              child: Icon(Icons.delete, color: Colors.white, size: 50),
            ),
            Dismissible(
              key: UniqueKey(),
              onDismissed: (DismissDirection direction) => Get.find<CartController>().removeFromCart(cartIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: [BoxShadow(
                    color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                    blurRadius: 5, spreadRadius: 1,
                  )],
                ),
                child: Column(
                  children: [

                    Row(children: [
                      (cart.product!.image != null && cart.product!.image!.isNotEmpty) ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.productImageUrl}/${cart.product!.image}',
                              height: 65, width: 70, fit: BoxFit.cover,
                            ),
                          ),
                          isAvailable ? const SizedBox() : Positioned(
                            top: 0, left: 0, bottom: 0, right: 0,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.black.withOpacity(0.6)),
                              child: Text('not_available_now_break'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                                color: Colors.white, fontSize: 8,
                              )),
                            ),
                          ),
                        ],
                      ) : const SizedBox.shrink(),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            cart.product!.name!,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          RatingBar(rating: cart.product!.avgRating, size: 12, ratingCount: cart.product!.ratingCount),
                          const SizedBox(height: 5),
                          Row(children: [
                            Text(
                              PriceConverter.convertPrice(cart.discountedPrice), textDirection: TextDirection.ltr,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            cart.discountedPrice!+cart.discountAmount! > cart.discountedPrice! ? Text(
                              PriceConverter.convertPrice(cart.discountedPrice!+cart.discountAmount!), textDirection: TextDirection.ltr,
                              style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
                            ) : const SizedBox(),
                          ]),
                        ]),
                      ),

                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            cart.product!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white),
                          ),
                        ) : const SizedBox(),
                        SizedBox(height: Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Dimensions.paddingSizeExtraSmall : 0),
                        Row(children: [
                          QuantityButton(
                            onTap: () {
                              if (cart.quantity! > 1) {
                                Get.find<CartController>().setQuantity(false, cart);
                              }else {
                                Get.find<CartController>().removeFromCart(cartIndex);
                              }
                            },
                            isIncrement: false,
                          ),
                          Text(cart.quantity.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                          QuantityButton(
                            onTap: () => Get.find<CartController>().setQuantity(true, cart),
                            isIncrement: true,
                          ),
                        ]),
                      ]),

                      !ResponsiveHelper.isMobile(context) ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: IconButton(
                          onPressed: () {
                            Get.find<CartController>().removeFromCart(cartIndex);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ) : const SizedBox(),

                    ]),

                    addOnText.isNotEmpty ? Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        const SizedBox(width: 80),
                        Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        Flexible(child: Text(
                          addOnText, textDirection: TextDirection.ltr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        )),
                      ]),
                    ) : const SizedBox(),

                    (variationText != '' && cart.product!.variations != null && cart.product!.variations!.isNotEmpty) ? Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(width: 80),
                        Text('${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr),
                        Flexible(child: Text(variationText, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                        ),
                      ]),
                    ) : const SizedBox(),

                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
