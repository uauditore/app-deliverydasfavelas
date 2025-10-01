import 'package:app_cliente/controller/auth_controller.dart';
import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/controller/wishlist_controller.dart';
import 'package:app_cliente/data/model/response/config_model.dart';
import 'package:app_cliente/data/model/response/product_model.dart';
import 'package:app_cliente/data/model/response/restaurant_model.dart';
import 'package:app_cliente/helper/date_converter.dart';
import 'package:app_cliente/helper/price_converter.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/helper/route_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/custom_image.dart';
import 'package:app_cliente/view/base/custom_snackbar.dart';
import 'package:app_cliente/view/base/discount_tag.dart';
import 'package:app_cliente/view/base/discount_tag_without_image.dart';
import 'package:app_cliente/view/base/not_available_widget.dart';
import 'package:app_cliente/view/base/product_bottom_sheet.dart';
import 'package:app_cliente/view/base/rating_bar.dart';
import 'package:app_cliente/view/screens/restaurant/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWidget extends StatelessWidget {
  final Product? product;
  final Restaurant? restaurant;
  final bool isRestaurant;
  final int index;
  final int? length;
  final bool inRestaurant;
  final bool isCampaign;
  const ProductWidget({Key? key, required this.product, required this.isRestaurant, required this.restaurant, required this.index,
   required this.length, this.inRestaurant = false, this.isCampaign = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseUrls? baseUrls = Get.find<SplashController>().configModel!.baseUrls;
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    bool isAvailable;
    String? image ;
    if(isRestaurant) {
      image = restaurant!.logo;
      discount = restaurant!.discount != null ? restaurant!.discount!.discount : 0;
      discountType = restaurant!.discount != null ? restaurant!.discount!.discountType : 'percent';
      // bool _isClosedToday = Get.find<RestaurantController>().isRestaurantClosed(true, restaurant.active, restaurant.offDay);
      // _isAvailable = DateConverter.isAvailable(restaurant.openingTime, restaurant.closeingTime) && restaurant.active && !_isClosedToday;
      isAvailable = restaurant!.open == 1 && restaurant!.active! ;
    }else {
      image = product!.image;
      discount = (product!.restaurantDiscount == 0 || isCampaign) ? product!.discount : product!.restaurantDiscount;
      discountType = (product!.restaurantDiscount == 0 || isCampaign) ? product!.discountType : 'percent';
      isAvailable = DateConverter.isAvailable(product!.availableTimeStarts, product!.availableTimeEnds);
    }



    return InkWell(
      onTap: () {
        if(isRestaurant) {
          if(restaurant != null && restaurant!.restaurantStatus == 1){
            Get.toNamed(RouteHelper.getRestaurantRoute(restaurant!.id), arguments: RestaurantScreen(restaurant: restaurant));
          }else if(restaurant!.restaurantStatus == 0){
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        }else {
          if(product!.restaurantStatus == 1){
            ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
              ProductBottomSheet(product: product, inRestaurantPage: inRestaurant, isCampaign: isCampaign),
              backgroundColor: Colors.transparent, isScrollControlled: true,
            ) : Get.dialog(
              Dialog(child: ProductBottomSheet(product: product, inRestaurantPage: inRestaurant)),
            );
          }else{
            showCustomSnackBar('item_is_not_available'.tr);
          }
        }
      },
      child: Container(
        padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).cardColor : null,
          boxShadow: ResponsiveHelper.isDesktop(context) ? [BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5,
          )] : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Expanded(child: Padding(
            padding: EdgeInsets.symmetric(vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
            child: Row(children: [

              ((image != null && image.isNotEmpty) || isRestaurant) ? Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    image: '${isCampaign ? baseUrls!.campaignImageUrl : isRestaurant ? baseUrls!.restaurantImageUrl
                        : baseUrls!.productImageUrl}'
                        '/${isRestaurant ? restaurant!.logo : product!.image}',
                    height: desktop ? 120 : length == null ? 100 : 65, width: desktop ? 120 : 80, fit: BoxFit.cover,
                  ),
                ),
                DiscountTag(
                  discount: discount, discountType: discountType,
                  freeDelivery: isRestaurant ? restaurant!.freeDelivery : false,
                ),
                isAvailable ? const SizedBox() : NotAvailableWidget(isRestaurant: isRestaurant),
              ]) : const SizedBox.shrink(),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                  Text(
                    isRestaurant ? restaurant!.name! : product!.name!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: desktop ? 2 : 1, overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isRestaurant ? Dimensions.paddingSizeExtraSmall : 0),

                  Text(
                    isRestaurant ? restaurant!.address ?? 'no_address_found'.tr : product!.restaurantName ?? '',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: (desktop || isRestaurant) ? 5 : 0),

                  !isRestaurant ? RatingBar(
                    rating: isRestaurant ? restaurant!.avgRating : product!.avgRating, size: desktop ? 15 : 12,
                    ratingCount: isRestaurant ? restaurant!.ratingCount : product!.ratingCount,
                  ) : const SizedBox(),
                  SizedBox(height: (!isRestaurant && desktop) ? Dimensions.paddingSizeExtraSmall : 0),

                  isRestaurant ? RatingBar(
                    rating: isRestaurant ? restaurant!.avgRating : product!.avgRating, size: desktop ? 15 : 12,
                    ratingCount: isRestaurant ? restaurant!.ratingCount : product!.ratingCount,
                  ) : Row(children: [

                    Text(
                      PriceConverter.convertPrice(product!.price, discount: discount, discountType: discountType),
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                    ),
                    SizedBox(width: discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                    discount > 0 ? Text(
                      PriceConverter.convertPrice(product!.price), textDirection: TextDirection.ltr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ) : const SizedBox(),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    (image != null && image.isNotEmpty) ? const SizedBox.shrink() : DiscountTagWithoutImage(discount: discount, discountType: discountType,
                        freeDelivery: isRestaurant ? restaurant!.freeDelivery : false),

                  ]),

                ]),
              ),

              Column(mainAxisAlignment: isRestaurant ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween, children: [

                !isRestaurant ? Padding(
                  padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSizeSmall : 0),
                  child: Icon(Icons.add, size: desktop ? 30 : 25),
                ) : const SizedBox(),

                GetBuilder<WishListController>(builder: (wishController) {
                  bool isWished = isRestaurant ? wishController.wishRestIdList.contains(restaurant!.id)
                      : wishController.wishProductIdList.contains(product!.id);
                  return InkWell(
                    onTap: () {
                      if(Get.find<AuthController>().isLoggedIn()) {
                        isWished ? wishController.removeFromWishList(isRestaurant ? restaurant!.id : product!.id, isRestaurant)
                            : wishController.addToWishList(product, restaurant, isRestaurant);
                      }else {
                        showCustomSnackBar('you_are_not_logged_in'.tr);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSizeSmall : 0),
                      child: Icon(
                        isWished ? Icons.favorite : Icons.favorite_border,  size: desktop ? 30 : 25,
                        color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                      ),
                    ),
                  );
                }),

              ]),

            ]),
          )),

          desktop || length == null ? const SizedBox() : Padding(
            padding: EdgeInsets.only(left: desktop ? 130 : 90),
            child: Divider(color: index == length!-1 ? Colors.transparent : Theme.of(context).disabledColor),
          ),

        ]),
      ),
    );
  }
}
