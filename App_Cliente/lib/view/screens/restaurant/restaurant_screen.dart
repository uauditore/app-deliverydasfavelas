import 'package:app_cliente/controller/cart_controller.dart';
import 'package:app_cliente/controller/category_controller.dart';
import 'package:app_cliente/controller/localization_controller.dart';
import 'package:app_cliente/controller/restaurant_controller.dart';
import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/data/model/response/category_model.dart';
import 'package:app_cliente/data/model/response/product_model.dart';
import 'package:app_cliente/data/model/response/restaurant_model.dart';
import 'package:app_cliente/helper/date_converter.dart';
import 'package:app_cliente/helper/price_converter.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/helper/route_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/images.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/bottom_cart_widget.dart';
import 'package:app_cliente/view/base/custom_image.dart';
import 'package:app_cliente/view/base/product_view.dart';
import 'package:app_cliente/view/base/product_widget.dart';
import 'package:app_cliente/view/base/web_menu_bar.dart';
import 'package:app_cliente/view/screens/restaurant/widget/restaurant_description_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant? restaurant;
  const RestaurantScreen({Key? key, required this.restaurant}) : super(key: key);

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;

  @override
  void initState() {
    super.initState();

    Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: widget.restaurant!.id));
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<RestaurantController>().getRestaurantRecommendedItemList(widget.restaurant!.id, false);
    Get.find<RestaurantController>().getRestaurantProductList(widget.restaurant!.id, 1, 'all', false);
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<RestaurantController>().restaurantProducts != null
          && !Get.find<RestaurantController>().foodPaginate) {
        int pageSize = (Get.find<RestaurantController>().foodPageSize! / 10).ceil();
        if (Get.find<RestaurantController>().foodOffset < pageSize) {
          Get.find<RestaurantController>().setFoodOffset(Get.find<RestaurantController>().foodOffset+1);
          debugPrint('end of the page');
          Get.find<RestaurantController>().showFoodBottomLoader();
          Get.find<RestaurantController>().getRestaurantProductList(
            widget.restaurant!.id, Get.find<RestaurantController>().foodOffset, Get.find<RestaurantController>().type, false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return GetBuilder<CategoryController>(builder: (categoryController) {
          Restaurant? restaurant;
          if(restController.restaurant != null && restController.restaurant!.name != null && categoryController.categoryList != null) {
            restaurant = restController.restaurant;
          }
          restController.setCategoryList();

          // if(restController.restaurant == null){
          //  return Center(child: Text('restaurant_is_not_available'.tr));
          // }

          return (restController.restaurant != null && restController.restaurant!.name != null && categoryController.categoryList != null)
          ? CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [

              ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF171A29),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  alignment: Alignment.center,
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Row(children: [

                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            fit: BoxFit.cover, placeholder: Images.restaurantCover, height: 220,
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantCoverPhotoUrl}/${restaurant!.coverPhoto}',
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: RestaurantDescriptionView(restaurant: restaurant)),

                    ]),
                  ))),
                ),
              ) : SliverAppBar(
                expandedHeight: 230, toolbarHeight: 50,
                pinned: true, floating: false,
                backgroundColor: Theme.of(context).primaryColor,
                leading: IconButton(
                  icon: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                    alignment: Alignment.center,
                    child: Icon(Icons.chevron_left, color: Theme.of(context).cardColor),
                  ),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: CustomImage(
                    fit: BoxFit.cover, placeholder: Images.restaurantCover,
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantCoverPhotoUrl}/${restaurant!.coverPhoto}',
                  ),
                ),
                actions: [

                  // IconButton(
                  //   onPressed: () {
                  //     print('${AppConstants.YOUR_SCHEME}://${AppConstants.YOUR_HOST}${Get.currentRoute}');
                  //     String shareUrl = '${AppConstants.YOUR_SCHEME}://${AppConstants.YOUR_HOST}${Get.currentRoute}';
                  //     Share.share(shareUrl);
                  //   },
                  //   icon: Container(
                  //     height: 50, width: 50,
                  //     decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                  //     alignment: Alignment.center,
                  //     child: Icon(Icons.share, size: 20, color: Theme.of(context).cardColor),
                  //   ),
                  // ),

                  IconButton(
                    onPressed: () => Get.toNamed(RouteHelper.getSearchRestaurantProductRoute(restaurant!.id)),
                    icon: Container(
                      height: 50, width: 50,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                      alignment: Alignment.center,
                      child: Icon(Icons.search, size: 20, color: Theme.of(context).cardColor),
                    ),
                  ),
                ],

              ),

              SliverToBoxAdapter(child: Center(child: Container(
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                color: Theme.of(context).cardColor,
                child: Column(children: [
                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : RestaurantDescriptionView(restaurant: restaurant),
                  restaurant.discount != null ? Container(
                    width: context.width,
                    margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        restaurant.discount!.discountType == 'percent' ? '${restaurant.discount!.discount}% OFF'
                            : '${PriceConverter.convertPrice(restaurant.discount!.discount)} OFF',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
                      ),
                      Text(
                        restaurant.discount!.discountType == 'percent'
                            ? '${'enjoy'.tr} ${restaurant.discount!.discount}% ${'off_on_all_categories'.tr}'
                            : '${'enjoy'.tr} ${PriceConverter.convertPrice(restaurant.discount!.discount)}'
                            ' ${'off_on_all_categories'.tr}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                      ),
                      SizedBox(height: (restaurant.discount!.minPurchase != 0 || restaurant.discount!.maxDiscount != 0) ? 5 : 0),
                      restaurant.discount!.minPurchase != 0 ? Text(
                        '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.minPurchase)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                      ) : const SizedBox(),
                      restaurant.discount!.maxDiscount != 0 ? Text(
                        '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.maxDiscount)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                      ) : const SizedBox(),
                      Text(
                        '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(restaurant.discount!.startTime!)} '
                            '- ${DateConverter.convertTimeToTime(restaurant.discount!.endTime!)} ]',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                      ),
                    ]),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  restController.recommendedProductModel != null && restController.recommendedProductModel!.products!.isNotEmpty ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('recommended_items'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 150 : 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: restController.recommendedProductModel!.products!.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                              child: Container(
                                width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                                decoration: ResponsiveHelper.isDesktop(context) ? null : BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Theme.of(context).cardColor,
                                  border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                                  boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5)]
                                ),
                                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                child: ProductWidget(
                                  isRestaurant: false, product: restController.recommendedProductModel!.products![index],
                                  restaurant: null, index: index, length: null, isCampaign: false,
                                  inRestaurant: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ) : const SizedBox(),
                ]),
              ))),

              (restController.categoryList!.isNotEmpty) ? SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(child: Center(child: Container(
                  height: 50, width: Dimensions.webMaxWidth, color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: restController.categoryList!.length,
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => restController.setCategoryIndex(index),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: index == 0 ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
                            right: index == restController.categoryList!.length-1 ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall,
                            top: Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(
                                _ltr ? index == 0 ? Dimensions.radiusExtraLarge : 0 : index == restController.categoryList!.length-1
                                    ? Dimensions.radiusExtraLarge : 0,
                              ),
                              right: Radius.circular(
                                _ltr ? index == restController.categoryList!.length-1 ? Dimensions.radiusExtraLarge : 0 : index == 0
                                    ? Dimensions.radiusExtraLarge : 0,
                              ),
                            ),
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              restController.categoryList![index].name!,
                              style: index == restController.categoryIndex
                                  ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                  : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ),
                            index == restController.categoryIndex ? Container(
                              height: 5, width: 5,
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                            ) : const SizedBox(height: 5, width: 5),
                          ]),
                        ),
                      );
                    },
                  ),
                ))),
              ) : const SliverToBoxAdapter(child: SizedBox()),

              SliverToBoxAdapter(child: Center(child: Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: Column(children: [
                  ProductView(
                    isRestaurant: false, restaurants: null,
                    products: restController.categoryList!.isNotEmpty ? restController.restaurantProducts : null,
                    inRestaurantPage: true, type: restController.type, onVegFilterTap: (String type) {
                      restController.getRestaurantProductList(restController.restaurant!.id, 1, type, true);
                    },
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                    ),
                  ),
                  restController.foodPaginate ? const Center(child: Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CircularProgressIndicator(),
                  )) : const SizedBox(),

                ]),
              ))),
            ],
          ) : const Center(child: CircularProgressIndicator());
        });
      }),

      bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
        })
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Product> products;
  CategoryProduct(this.category, this.products);
}
