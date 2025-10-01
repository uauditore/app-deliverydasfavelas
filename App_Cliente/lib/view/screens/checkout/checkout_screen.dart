
import 'package:app_cliente/controller/auth_controller.dart';
import 'package:app_cliente/controller/cart_controller.dart';
import 'package:app_cliente/controller/coupon_controller.dart';
import 'package:app_cliente/controller/localization_controller.dart';
import 'package:app_cliente/controller/location_controller.dart';
import 'package:app_cliente/controller/order_controller.dart';
import 'package:app_cliente/controller/restaurant_controller.dart';
import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/controller/user_controller.dart';
import 'package:app_cliente/data/model/body/place_order_body.dart';
import 'package:app_cliente/data/model/response/address_model.dart';
import 'package:app_cliente/data/model/response/cart_model.dart';
import 'package:app_cliente/data/model/response/product_model.dart';
import 'package:app_cliente/data/model/response/zone_response_model.dart';
import 'package:app_cliente/helper/date_converter.dart';
import 'package:app_cliente/helper/price_converter.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/helper/route_helper.dart';
import 'package:app_cliente/util/app_constants.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/images.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/custom_app_bar.dart';
import 'package:app_cliente/view/base/custom_button.dart';
import 'package:app_cliente/view/base/custom_snackbar.dart';
import 'package:app_cliente/view/base/custom_text_field.dart';
import 'package:app_cliente/view/base/my_text_field.dart';
import 'package:app_cliente/view/base/not_logged_in_screen.dart';
import 'package:app_cliente/view/screens/address/widget/address_widget.dart';
import 'package:app_cliente/view/screens/cart/widget/delivery_option_button.dart';
import 'package:app_cliente/view/screens/checkout/widget/address_dialogue.dart';
import 'package:app_cliente/view/screens/checkout/widget/order_type_widget.dart';
import 'package:app_cliente/view/screens/checkout/widget/payment_button.dart';
import 'package:app_cliente/view/screens/checkout/widget/subscription_view.dart';
import 'package:app_cliente/view/screens/checkout/widget/tips_widget.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel>? cartList;
  final bool fromCart;
  const CheckoutScreen({Key? key, required this.fromCart, required this.cartList}) : super(key: key);

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive;
  bool? _isDigitalPaymentActive;
  late bool _isWalletActive;
  late bool _isLoggedIn;
  late List<CartModel> _cartList;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn) {
      Get.find<LocationController>().getZone(
        Get.find<LocationController>().getUserAddress()!.latitude,
        Get.find<LocationController>().getUserAddress()!.longitude, false, updateInAddress: true
      );
      Get.find<CouponController>().setCoupon('');

      Get.find<OrderController>().stopLoader(isUpdate: false);
      Get.find<OrderController>().updateTimeSlot(0, notify: false);
      Get.find<OrderController>().updateTips(-1, notify: false);
      Get.find<OrderController>().addTips(0, notify: false);

      if(Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo();
      }
      if(Get.find<LocationController>().addressList == null) {
        Get.find<LocationController>().getAddressList();
      }
      _isCashOnDeliveryActive = Get.find<SplashController>().configModel!.cashOnDelivery;
      _isDigitalPaymentActive = Get.find<SplashController>().configModel!.digitalPayment;
      _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus == 1;
      Get.find<OrderController>().setPaymentMethod(_isCashOnDeliveryActive! ? 0 : _isDigitalPaymentActive! ? 1 : 2, isUpdate: false);
      _cartList = [];
      widget.fromCart ? _cartList.addAll(Get.find<CartController>().cartList) : _cartList.addAll(widget.cartList!);
      Get.find<RestaurantController>().initCheckoutData(_cartList[0].product!.restaurantId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streetNumberController.dispose();
    _houseController.dispose();
    _floorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      body: _isLoggedIn ? GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<RestaurantController>(builder: (restController) {
          bool todayClosed = false;
          bool tomorrowClosed = false;
          List<AddressModel?> addressList = [];
          addressList.add(Get.find<LocationController>().getUserAddress());
          if(restController.restaurant != null) {
            if(locationController.addressList != null) {
              for(int index=0; index<locationController.addressList!.length; index++) {
                if(locationController.addressList![index].zoneIds!.contains(restController.restaurant!.zoneId)){
                  addressList.add(locationController.addressList![index]);
                }
              }
            }
            todayClosed = restController.isRestaurantClosed(true, restController.restaurant!.active!, restController.restaurant!.schedules);
            tomorrowClosed = restController.isRestaurantClosed(false, restController.restaurant!.active!, restController.restaurant!.schedules);
            _taxPercent = restController.restaurant!.tax;
          }
          return GetBuilder<CouponController>(builder: (couponController) {
            return GetBuilder<OrderController>(builder: (orderController) {
              double deliveryCharge = -1;
              double charge = -1;
              double? maxCodOrderAmount;
              if(restController.restaurant != null && orderController.distance != null && orderController.distance != -1 ) {
                ZoneData zoneData = Get.find<LocationController>().getUserAddress()!.zoneData!.firstWhere((data) => data.id == restController.restaurant!.zoneId);
                double perKmCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.perKmShippingCharge!
                    : zoneData.perKmShippingCharge ?? 0;

                double minimumCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.minimumShippingCharge!
                    :  zoneData.minimumShippingCharge ?? 0;

                double? maximumCharge = restController.restaurant!.selfDeliverySystem == 1 ? restController.restaurant!.maximumShippingCharge
                : zoneData.maximumShippingCharge;

                deliveryCharge = orderController.distance! * perKmCharge;
                charge = orderController.distance! * perKmCharge;

                if(deliveryCharge < minimumCharge) {
                  deliveryCharge = minimumCharge;
                  charge = minimumCharge;
                }

                if(restController.restaurant!.selfDeliverySystem == 0 && orderController.extraCharge != null){
                  deliveryCharge = deliveryCharge + orderController.extraCharge!;
                  charge = charge + orderController.extraCharge!;
                }

                if(maximumCharge != null && deliveryCharge > maximumCharge){
                  deliveryCharge = maximumCharge;
                  charge = maximumCharge;
                }

                if(restController.restaurant!.selfDeliverySystem == 0 && zoneData.increasedDeliveryFeeStatus == 1){
                  deliveryCharge = deliveryCharge + (deliveryCharge * (zoneData.increasedDeliveryFee!/100));
                  charge = charge + charge * (zoneData.increasedDeliveryFee!/100);
                }


                maxCodOrderAmount = zoneData.maxCodOrderAmount;
              }

              double price = 0;
              double? discount = 0;
              double? couponDiscount = couponController.discount;
              double tax = 0;
              bool taxIncluded = Get.find<SplashController>().configModel!.taxIncluded == 1;
              double addOns = 0;
              double subTotal = 0;
              double orderAmount = 0;
              bool restaurantSubscriptionActive = false;
              int subscriptionQty = orderController.subscriptionOrder ? 0 : 1;
              if(restController.restaurant != null) {

                restaurantSubscriptionActive =  restController.restaurant!.orderSubscriptionActive! && widget.fromCart;

                if(restaurantSubscriptionActive){
                  if(orderController.subscriptionOrder && orderController.subscriptionRange != null) {
                    if(orderController.subscriptionType == 'weekly') {
                      List<int> weekDays = [];
                      for(int index=0; index<orderController.selectedDays.length; index++) {
                        if(orderController.selectedDays[index] != null) {
                          weekDays.add(index + 1);
                        }
                      }
                      subscriptionQty = DateConverter.getWeekDaysCount(orderController.subscriptionRange!, weekDays);
                    }else if(orderController.subscriptionType == 'monthly') {
                      List<int> days = [];
                      for(int index=0; index<orderController.selectedDays.length; index++) {
                        if(orderController.selectedDays[index] != null) {
                          days.add(index + 1);
                        }
                      }
                      subscriptionQty = DateConverter.getMonthDaysCount(orderController.subscriptionRange!, days);
                    }else {
                      subscriptionQty = orderController.subscriptionRange!.duration.inDays;
                    }
                  }
                }

                for (var cartModel in _cartList) {
                  List<AddOns> addOnList = [];
                  for (var addOnId in cartModel.addOnIds!) {
                    for (AddOns addOns in cartModel.product!.addOns!) {
                      if (addOns.id == addOnId.id) {
                        addOnList.add(addOns);
                        break;
                      }
                    }
                  }

                  for (int index = 0; index < addOnList.length; index++) {
                    addOns = addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
                  }
                  price = price + (cartModel.price! * cartModel.quantity!);
                  double? dis = (restController.restaurant!.discount != null
                      && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
                      ? restController.restaurant!.discount!.discount : cartModel.product!.discount;
                  String? disType = (restController.restaurant!.discount != null
                      && DateConverter.isAvailable(restController.restaurant!.discount!.startTime, restController.restaurant!.discount!.endTime))
                      ? 'percent' : cartModel.product!.discountType;
                  discount = discount! + ((cartModel.price! - PriceConverter.convertWithDiscount(cartModel.price, dis, disType)!) * cartModel.quantity!);
                }
                if (restController.restaurant != null && restController.restaurant!.discount != null) {
                  if (restController.restaurant!.discount!.maxDiscount != 0 && restController.restaurant!.discount!.maxDiscount! < discount!) {
                    discount = restController.restaurant!.discount!.maxDiscount;
                  }
                  if (restController.restaurant!.discount!.minPurchase != 0 && restController.restaurant!.discount!.minPurchase! > (price + addOns)) {
                    discount = 0;
                  }
                }
                price = PriceConverter.toFixed(price);
                addOns = PriceConverter.toFixed(addOns);
                discount = PriceConverter.toFixed(discount!);
                couponDiscount = PriceConverter.toFixed(couponDiscount!);
                subTotal = price + addOns;
                orderAmount = (price - discount) + addOns - couponDiscount;

                if (orderController.orderType == 'take_away' || restController.restaurant!.freeDelivery!
                    || (Get.find<SplashController>().configModel!.freeDeliveryOver != null && orderAmount
                        >= Get.find<SplashController>().configModel!.freeDeliveryOver!) || couponController.freeDelivery) {
                  deliveryCharge = 0;
                }
              }

              if(taxIncluded){
                tax = orderAmount * _taxPercent! /(100 + _taxPercent!);
              }else {
                tax = PriceConverter.calculation(orderAmount, _taxPercent, 'percent', 1);
              }
              tax = PriceConverter.toFixed(tax);
              deliveryCharge = PriceConverter.toFixed(deliveryCharge);
              double total = subTotal + deliveryCharge - discount- couponDiscount! + (taxIncluded ? 0 : tax) + orderController.tips;
              total = PriceConverter.toFixed(total);

              return (orderController.distance != null && locationController.addressList != null) ? Column(
                children: [

                  Expanded(child: Scrollbar(child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    // padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    child: Center(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        _isCashOnDeliveryActive! && restaurantSubscriptionActive ? Container(
                          width: context.width,
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('order_type'.tr, style: robotoMedium),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Row(children: [
                              Expanded(child: OrderTypeWidget(
                                title: 'regular_order'.tr,
                                subtitle: 'place_an_order_and_enjoy'.tr,
                                icon: Images.regularOrder,
                                isSelected: !orderController.subscriptionOrder,
                                onTap: () => orderController.setSubscription(false),
                              )),
                              SizedBox(width: _isCashOnDeliveryActive! ? Dimensions.paddingSizeSmall : 0),

                              Expanded(child: OrderTypeWidget(
                                title: 'subscription_order'.tr,
                                subtitle: 'place_order_and_enjoy_it_everytime'.tr,
                                icon: Images.subscriptionOrder,
                                isSelected: orderController.subscriptionOrder,
                                onTap: () => orderController.setSubscription(true),
                              )),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            orderController.subscriptionOrder ? SubscriptionView(
                              orderController: orderController,
                            ) : const SizedBox(),
                            SizedBox(height: orderController.subscriptionOrder ? Dimensions.paddingSizeLarge : 0),
                          ]),
                        ) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Container(
                          width: context.width,
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('delivery_type'.tr, style: robotoMedium),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [

                              restController.restaurant!.delivery! ? DeliveryOptionButton(
                                value: 'delivery', title: 'home_delivery'.tr, charge: charge, isFree: restController.restaurant!.freeDelivery,
                                image: Images.homeDelivery, index: 0,
                              ) : const SizedBox(),
                              const SizedBox(width: Dimensions.paddingSizeDefault),

                              restController.restaurant!.takeAway! ? DeliveryOptionButton(
                                value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true,
                                image: Images.takeaway, index: 1,
                              ) : const SizedBox(),

                            ])),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            Center(child: Text('${'delivery_charge'.tr}: ${(orderController.orderType == 'take_away'
                                || (orderController.deliverySelectIndex == 0 ? restController.restaurant!.freeDelivery! : true)) ? 'free'.tr
                                : charge != -1 ? PriceConverter.convertPrice(orderController.deliverySelectIndex == 0 ? charge : deliveryCharge)
                                : 'calculating'.tr}', textDirection: TextDirection.ltr),)
                          ]),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        orderController.orderType != 'take_away' ? Container(
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('deliver_to'.tr, style: robotoMedium),

                              InkWell(
                                onTap: () async{
                                  var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, restController.restaurant!.zoneId));
                                  if(address != null){
                                    _streetNumberController.text = address.road ?? '';
                                    _houseController.text = address.house ?? '';
                                    _floorController.text = address.floor ?? '';

                                    orderController.getDistanceInMeter(
                                      LatLng(double.parse(address.latitude), double.parse(address.longitude )),
                                      LatLng(double.parse(restController.restaurant!.latitude!), double.parse(restController.restaurant!.longitude!)),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(children: [
                                    Text('add_new'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                                  ]),
                                ),
                              ),
                            ]),


                            InkWell(
                              onTap: (){
                                Get.dialog(
                                  AddressDialogue(addressList: addressList, streetNumberController: _streetNumberController,
                                      houseController: _houseController, floorController: _floorController),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(child: AddressWidget(address: addressList[orderController.addressIndex], fromAddress: false, fromCheckout: true)),
                                  const Icon(Icons.arrow_drop_down_sharp)
                                ],
                              ),
                            ),

                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            Text(
                              'street_number'.tr,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            MyTextField(
                              hintText: 'ex_24th_street'.tr,
                              inputType: TextInputType.streetAddress,
                              focusNode: _streetNode,
                              nextFocus: _houseNode,
                              controller: _streetNumberController,
                              showBorder: true,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            Text(
                              '${'house'.tr} / ${'floor'.tr} ${'number'.tr}',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextField(
                                    hintText: 'ex_34'.tr,
                                    inputType: TextInputType.text,
                                    focusNode: _houseNode,
                                    nextFocus: _floorNode,
                                    controller: _houseController,
                                    showBorder: true,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Expanded(
                                  child: MyTextField(
                                    hintText: 'ex_3a'.tr,
                                    inputType: TextInputType.text,
                                    focusNode: _floorNode,
                                    inputAction: TextInputAction.done,
                                    controller: _floorController,
                                    showBorder: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                          ]),
                        ) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        // Time Slot
                        (widget.fromCart && !orderController.subscriptionOrder && restController.restaurant!.scheduleOrder!) ? Container(
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('delivery_time'.tr, style: robotoMedium),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Row(children: [
                              Expanded(child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  border: Border.all(color: Theme.of(context).disabledColor)),
                                child: DropdownButton<String>(
                                  value: AppConstants.preferenceDays[orderController.selectedDateSlot],
                                  items: AppConstants.preferenceDays.map((String? items) {
                                    return DropdownMenuItem(value: items, child: Text(items!.tr));
                                  }).toList(),
                                  onChanged: (value){
                                    orderController.updateDateSlot(AppConstants.preferenceDays.indexOf(value));
                                  },
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                ),
                              )),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(child: ((orderController.selectedDateSlot == 0 && todayClosed)
                              || (orderController.selectedDateSlot == 1 && tomorrowClosed))
                               ? Center(child: Text('restaurant_is_closed'.tr)) : orderController.timeSlots != null
                               ? orderController.timeSlots!.isNotEmpty ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  border: Border.all(color: Theme.of(context).disabledColor)),
                                child: DropdownButton<int>(
                                  value: orderController.selectedTimeSlot,
                                  items: orderController.slotIndexList!.map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text((value == 0 && orderController.selectedDateSlot == 0
                                          && restController.isRestaurantOpenNow(restController.restaurant!.active!, restController.restaurant!.schedules))
                                          ? 'now'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots![value].startTime!)} '
                                          '- ${DateConverter.dateToTimeOnly(orderController.timeSlots![value].endTime!)}'),
                                    );
                                  }).toList(),
                                  onChanged: (int? value) {
                                    orderController.updateTimeSlot(value);
                                  },
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                ),
                              ) : Center(child: Text('no_slot_available'.tr)) : const Center(child: CircularProgressIndicator())),
                            ]),

                            const SizedBox(height: Dimensions.paddingSizeLarge),
                          ]),
                        ) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                        // Coupon
                        GetBuilder<CouponController>(builder: (couponController) {
                            return Container(
                              color: Theme.of(context).cardColor,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Column(children: [

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('promo_code'.tr, style: robotoMedium),
                                  InkWell(
                                    onTap: (){
                                      Get.toNamed(RouteHelper.getCouponRoute(fromCheckout: true))!.then((value) => _couponController.text = couponController.checkoutCouponCode!);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(children: [
                                        Text('add_voucher'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                                      ]),
                                    ),
                                  )
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      border: Border.all(color: Theme.of(context).primaryColor),
                                  ),
                                  child: Row(children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: TextField(
                                          controller: _couponController,
                                          style: robotoRegular.copyWith(height: ResponsiveHelper.isMobile(context) ? null : 2),
                                          decoration: InputDecoration(
                                            hintText: 'enter_promo_code'.tr,
                                            hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                                            isDense: true,
                                            filled: true,
                                            enabled: couponController.discount == 0,
                                            fillColor: Theme.of(context).cardColor,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.horizontal(
                                                left: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                                                right: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                                              ),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        String couponCode = _couponController.text.trim();
                                        if(couponController.discount! < 1 && !couponController.freeDelivery) {
                                          if(couponCode.isNotEmpty && !couponController.isLoading) {
                                            couponController.applyCoupon(couponCode, (price-discount!)+addOns, deliveryCharge,
                                                restController.restaurant!.id).then((discount) {
                                              if (discount! > 0) {
                                                showCustomSnackBar(
                                                  '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                                  isError: false,
                                                );
                                              }
                                            });
                                          } else if(couponCode.isEmpty) {
                                            showCustomSnackBar('enter_a_coupon_code'.tr);
                                          }
                                        } else {
                                          couponController.removeCouponData(true);
                                        }
                                      },
                                      child: Container(
                                        height: 50, width: 100,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                                          borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                                            right: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                                          ),
                                        ),
                                        child: (couponController.discount! <= 0 && !couponController.freeDelivery) ? !couponController.isLoading ? Text(
                                          'apply'.tr,
                                          style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
                                        ) : const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                            : const Icon(Icons.clear, color: Colors.white),
                                      ),
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                              ]),
                            );
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        (orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1
                            && !orderController.subscriptionOrder) ?
                        Container(
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeSmall),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('delivery_man_tips'.tr, style: robotoMedium),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).primaryColor),
                              ),
                              child: TextField(
                                controller: _tipController,
                                onChanged: (String value) {
                                  if(value.isNotEmpty) {
                                    orderController.addTips(double.parse(value));
                                  }else {
                                    orderController.addTips(0.0);
                                  }
                                },
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                decoration: InputDecoration(
                                  hintText: 'enter_amount'.tr,
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            SizedBox(
                                height: 55,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: AppConstants.tips.length,
                                  itemBuilder: (context, index) {
                                    return TipsWidget(
                                      title: AppConstants.tips[index].toString(),
                                      isSelected: orderController.selectedTips == index,
                                      onTap: () {
                                        orderController.updateTips(index);
                                        orderController.addTips(AppConstants.tips[index].toDouble());
                                        _tipController.text = orderController.tips.toString();
                                      },
                                    );
                                  },
                                ),
                            ),
                          ]),
                        ) : const SizedBox.shrink(),
                        SizedBox(height: (orderController.orderType != 'take_away'
                            && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Dimensions.paddingSizeExtraSmall : 0),

                        Container(
                          width: double.infinity,
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('choose_payment_method'.tr, style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              SingleChildScrollView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), child: Row(children: [

                                _isCashOnDeliveryActive! ? PaymentButton(
                                  icon: Images.cashOnDelivery,
                                  title: 'cash_on_delivery'.tr,
                                  subtitle: 'pay_your_payment_after_getting_food'.tr,
                                  index: 0,
                                ) : const SizedBox(),
                                !orderController.subscriptionOrder && _isDigitalPaymentActive! ? PaymentButton(
                                  icon: Images.digitalPayment,
                                  title: 'digital_payment'.tr,
                                  subtitle: 'faster_and_safe_way'.tr,
                                  index: 1,
                                ) : const SizedBox(),
                                !orderController.subscriptionOrder && _isWalletActive ? PaymentButton(
                                  icon: Images.wallet,
                                  title: 'wallet_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 2,
                                ) : const SizedBox(),

                              ])),

                          ],
                        )),

                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Container(
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                          child: Column(children: [

                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('additional_note'.tr, style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), border: Border.all(color: Theme.of(context).primaryColor)),
                                child: CustomTextField(
                                  controller: _noteController,
                                  hintText: 'ex_please_provide_extra_napkin'.tr,
                                  maxLines: 3,
                                  inputType: TextInputType.multiline,
                                  inputAction: TextInputAction.newline,
                                  capitalization: TextCapitalization.sentences,
                                ),
                              ),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(!orderController.subscriptionOrder ?'subtotal'.tr : 'item_price'.tr, style: robotoMedium),
                              Text(PriceConverter.convertPrice(subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('discount'.tr, style: robotoRegular),
                              Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            (couponController.discount! > 0 || couponController.freeDelivery) ? Column(children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('coupon_discount'.tr, style: robotoRegular),
                                (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? Text(
                                  'free_delivery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                                ) : Text(
                                  '(-) ${PriceConverter.convertPrice(couponController.discount)}',
                                  style: robotoRegular, textDirection: TextDirection.ltr,
                                ),
                              ]),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                            ]) : const SizedBox(),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('vat_tax'.tr + (taxIncluded ? 'tax_included'.tr : ''), style: robotoRegular),
                              Text((taxIncluded ? '' : '(+) ') + PriceConverter.convertPrice(tax), style: robotoRegular, textDirection: TextDirection.ltr),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            (orderController.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && !orderController.subscriptionOrder) ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('delivery_man_tips'.tr, style: robotoRegular),
                                Text('(+) ${PriceConverter.convertPrice(orderController.tips)}', style: robotoRegular, textDirection: TextDirection.ltr),
                              ],
                            ) : const SizedBox.shrink(),
                            SizedBox(height: orderController.orderType != 'take_away' && !orderController.subscriptionOrder ? Dimensions.paddingSizeSmall : 0.0),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('delivery_fee'.tr, style: robotoRegular),
                              deliveryCharge == -1 ? Text(
                                'calculating'.tr, style: robotoRegular.copyWith(color: Colors.red),
                              ) : (deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery')) ? Text(
                                'free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                              ) : Text(
                                '(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular, textDirection: TextDirection.ltr,
                              ),
                            ]),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(
                                orderController.subscriptionOrder ? 'subtotal'.tr : 'total_amount'.tr,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                              ),
                              Text(
                                PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                              ),
                            ]),

                            orderController.subscriptionOrder ? Column(children: [
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('subscription_order_count'.tr, style: robotoMedium),
                                Text(subscriptionQty > 0 ? subscriptionQty.toString() : 'calculating'.tr, style: robotoMedium),
                              ]),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(
                                  'total_amount'.tr,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                                ),
                                Text(
                                  subscriptionQty > 0 ? PriceConverter.convertPrice(total * subscriptionQty) : 'calculating'.tr, textDirection: TextDirection.ltr,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                                ),
                              ]),
                            ]) : const SizedBox(),
                          ]),
                        ),


                      ]),
                    )),
                  ))),

                  Container(
                    width: Dimensions.webMaxWidth,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: !orderController.isLoading ? CustomButton(buttonText: 'confirm_order'.tr, onPressed: () {
                      bool isAvailable = true;
                      DateTime scheduleStartDate = DateTime.now();
                      DateTime scheduleEndDate = DateTime.now();
                      if(orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
                        isAvailable = false;
                      }else {
                        DateTime date = orderController.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
                        DateTime startTime = orderController.timeSlots![orderController.selectedTimeSlot!].startTime!;
                        DateTime endTime = orderController.timeSlots![orderController.selectedTimeSlot!].endTime!;
                        scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
                        scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
                        for (CartModel cart in _cartList) {
                          if (!DateConverter.isAvailable(
                            cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
                            time: restController.restaurant!.scheduleOrder! ? scheduleStartDate : null,
                          ) && !DateConverter.isAvailable(
                            cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
                            time: restController.restaurant!.scheduleOrder! ? scheduleEndDate : null,
                          )) {
                            isAvailable = false;
                            break;
                          }
                        }
                      }

                      bool datePicked = false;
                      for(DateTime? time in orderController.selectedDays) {
                        if(time != null) {
                          datePicked = true;
                          break;
                        }
                      }

                      if(!_isCashOnDeliveryActive! && !_isDigitalPaymentActive! && !_isWalletActive) {
                        showCustomSnackBar('no_payment_method_is_enabled'.tr);
                      }else if(orderAmount < restController.restaurant!.minimumOrder!) {
                        showCustomSnackBar('${'minimum_order_amount_is'.tr} ${restController.restaurant!.minimumOrder}');
                      }else if(orderController.subscriptionOrder && orderController.subscriptionRange == null) {
                        showCustomSnackBar('select_a_date_range_for_subscription'.tr);
                      }else if(orderController.subscriptionOrder && !datePicked && orderController.subscriptionType == 'daily') {
                        showCustomSnackBar('choose_time'.tr);
                      }else if(orderController.subscriptionOrder && !datePicked) {
                        showCustomSnackBar('select_at_least_one_day_for_subscription'.tr);
                      }else if((orderController.selectedDateSlot == 0 && todayClosed) || (orderController.selectedDateSlot == 1 && tomorrowClosed)) {
                        showCustomSnackBar('restaurant_is_closed'.tr);
                      }else if(orderController.paymentMethodIndex == 0 && Get.find<SplashController>().configModel!.cashOnDelivery! && maxCodOrderAmount != null && (total > maxCodOrderAmount)){
                        showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                      } else if (orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
                        if(restController.restaurant!.scheduleOrder!) {
                          showCustomSnackBar('select_a_time'.tr);
                        }else {
                          showCustomSnackBar('restaurant_is_closed'.tr);
                        }
                      }else if (!isAvailable && !orderController.subscriptionOrder) {
                        showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
                      }else if (orderController.orderType != 'take_away' && orderController.distance == -1 && deliveryCharge == -1) {
                        showCustomSnackBar('delivery_fee_not_set_yet'.tr);
                      } else if(orderController.paymentMethodIndex == 2 && Get.find<UserController>().userInfoModel
                          != null && Get.find<UserController>().userInfoModel!.walletBalance! < total) {
                        showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
                      }else {
                        List<Cart> carts = [];
                        for (int index = 0; index < _cartList.length; index++) {
                          CartModel cart = _cartList[index];
                          List<int?> addOnIdList = [];
                          List<int?> addOnQtyList = [];
                          List<OrderVariation> variations = [];
                          for (var addOn in cart.addOnIds!) {
                            addOnIdList.add(addOn.id);
                            addOnQtyList.add(addOn.quantity);
                          }
                          if(cart.product!.variations != null){
                            for(int i=0; i<cart.product!.variations!.length; i++) {
                              if(cart.variations![i].contains(true)) {
                                variations.add(OrderVariation(name: cart.product!.variations![i].name, values: OrderVariationValue(label: [])));
                                for(int j=0; j<cart.product!.variations![i].variationValues!.length; j++) {
                                  if(cart.variations![i][j]!) {
                                    variations[variations.length-1].values!.label!.add(cart.product!.variations![i].variationValues![j].level);
                                  }
                                }
                              }
                            }
                          }
                          carts.add(Cart(
                            cart.isCampaign! ? null : cart.product!.id, cart.isCampaign! ? cart.product!.id : null,
                            cart.discountedPrice.toString(), '', variations,
                            cart.quantity, addOnIdList, cart.addOns, addOnQtyList,
                          ));
                        }

                        List<SubscriptionDays> days = [];
                        for(int index=0; index<orderController.selectedDays.length; index++) {
                          if(orderController.selectedDays[index] != null) {
                            days.add(SubscriptionDays(
                              day: orderController.subscriptionType == 'weekly' ? (index == 6 ? 0 : (index + 1)).toString()
                                  : orderController.subscriptionType == 'monthly' ? (index + 1).toString() : index.toString(),
                              time: DateConverter.dateToTime(orderController.selectedDays[index]!),
                            ));
                          }
                        }
                        AddressModel address =  addressList[orderController.addressIndex]!;
                        orderController.placeOrder(PlaceOrderBody(
                          cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
                          couponDiscountTitle: Get.find<CouponController>().discount! > 0 ? Get.find<CouponController>().coupon!.title : null,
                          scheduleAt: !restController.restaurant!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
                              && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleStartDate),
                          orderAmount: total, orderNote: _noteController.text, orderType: orderController.orderType,
                          paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                              : orderController.paymentMethodIndex == 1 ? 'digital_payment' : orderController.paymentMethodIndex == 2
                              ? 'wallet' : 'digital_payment',
                          couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                              && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                          restaurantId: _cartList[0].product!.restaurantId,
                          address: address.address, latitude: address.latitude, longitude: address.longitude, addressType: address.addressType,
                          contactPersonName: address.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
                              '${Get.find<UserController>().userInfoModel!.lName}',
                          contactPersonNumber: address.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
                          discountAmount: discount, taxAmount: tax, road: _streetNumberController.text.trim(),
                          house: _houseController.text.trim(), floor: _floorController.text.trim(), dmTips: _tipController.text.trim(),
                          subscriptionOrder: orderController.subscriptionOrder ? '1' : '0',
                          subscriptionType: orderController.subscriptionType, subscriptionQuantity: subscriptionQty.toString(),
                          subscriptionDays: days,
                          subscriptionStartAt: orderController.subscriptionOrder ? DateConverter.dateToDateAndTime(orderController.subscriptionRange!.start) : '',
                          subscriptionEndAt: orderController.subscriptionOrder ? DateConverter.dateToDateAndTime(orderController.subscriptionRange!.end) : '',
                        ), _callback, total, maxCodOrderAmount);
                      }
                    }) : const Center(child: CircularProgressIndicator()),
                  ),

                ],
              ) : const Center(child: CircularProgressIndicator());
            });
          });
        });
      }) : const NotLoggedInScreen(),
    );
  }

  void _callback(bool isSuccess, String message, String orderID, double amount, double maximumCodOrderAmount) async {
    if(isSuccess) {
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      if(widget.fromCart) {
        Get.find<CartController>().clearCartList();
      }
      Get.find<OrderController>().stopLoader();
      if(Get.find<OrderController>().paymentMethodIndex == 0 || Get.find<OrderController>().paymentMethodIndex == 2) {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'success', amount));
      }else {
       if(GetPlatform.isWeb) {
         Get.back();
         String? hostname = html.window.location.hostname;
         String protocol = html.window.location.protocol;
         String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&customer_id=${Get.find<UserController>()
             .userInfoModel!.id}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&amount=$amount&status=';
         html.window.open(selectedUrl,"_self");
       } else{
         Get.offNamed(RouteHelper.getPaymentRoute(orderID, Get.find<UserController>().userInfoModel!.id, amount, maximumCodOrderAmount));
       }
      }
      Get.find<OrderController>().clearPrevData();
      Get.find<OrderController>().updateTips(-1);
      Get.find<CouponController>().removeCouponData(false);
    }else {
      showCustomSnackBar(message);
    }
  }
}
