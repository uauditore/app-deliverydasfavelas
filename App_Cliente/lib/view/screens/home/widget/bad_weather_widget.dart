import 'package:app_cliente/controller/location_controller.dart';
import 'package:app_cliente/data/model/response/zone_response_model.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/images.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class BadWeatherWidget extends StatefulWidget {
  const BadWeatherWidget({Key? key}) : super(key: key);

  @override
  State<BadWeatherWidget> createState() => _BadWeatherWidgetState();
}

class _BadWeatherWidgetState extends State<BadWeatherWidget> {
  bool _showAlert = true;
  String? _message;
  @override
  void initState() {
    super.initState();

    ZoneData? zoneData;
    for (var zoneData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
      for (var zoneId in Get.find<LocationController>().getUserAddress()!.zoneIds!) {
        if(zoneData.id == zoneId){
          if(zoneData.increasedDeliveryFeeStatus == 1 && zoneData.increaseDeliveryFeeMessage != null){
            zoneData = zoneData;
          }
        }
      }
    }
    if(zoneData != null){
      _showAlert = zoneData.increasedDeliveryFeeStatus == 1;
      _message = zoneData.increaseDeliveryFeeMessage;
    }else{
      _showAlert = false;
    }

  }

  @override
  Widget build(BuildContext context) {

    return _showAlert && _message != null && _message!.isNotEmpty ? Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          Image.asset(Images.weather, height: 50, width: 50),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Text(
              _message!,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).cardColor),
          )),
        ],
      ),
    ) : const SizedBox();
  }
}
