import 'package:app_cliente/controller/auth_controller.dart';
import 'package:app_cliente/controller/location_controller.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/helper/route_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/images.dart';
import 'package:app_cliente/view/base/confirmation_dialog.dart';
import 'package:app_cliente/view/base/custom_app_bar.dart';
import 'package:app_cliente/view/base/custom_loader.dart';
import 'package:app_cliente/view/base/custom_snackbar.dart';
import 'package:app_cliente/view/base/no_data_screen.dart';
import 'package:app_cliente/view/base/not_logged_in_screen.dart';
import 'package:app_cliente/view/screens/address/widget/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn) {
      Get.find<LocationController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'my_address'.tr),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
        child: Icon(Icons.add, color: Theme.of(context).cardColor),
      ),
      floatingActionButtonLocation: ResponsiveHelper.isDesktop(context) ? FloatingActionButtonLocation.centerFloat : null,
      body: _isLoggedIn ? GetBuilder<LocationController>(builder: (locationController) {
        return locationController.addressList != null ? locationController.addressList!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await locationController.getAddressList();
          },
          child: Scrollbar(child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: ListView.builder(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                itemCount: locationController.addressList!.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (dir) {
                      showDialog(context: context, builder: (context) => const CustomLoader(), barrierDismissible: false);
                      locationController.deleteUserAddressByID(locationController.addressList![index].id, index).then((response) {
                        Navigator.pop(context);
                        showCustomSnackBar(response.message, isError: !response.isSuccess);
                      });
                    },
                    child: AddressWidget(
                      address: locationController.addressList![index], fromAddress: true,
                      onTap: () {
                        Get.toNamed(RouteHelper.getMapRoute(
                          locationController.addressList![index], 'address',
                        ));
                      },
                      onEditPressed: () {
                        Get.toNamed(RouteHelper.getEditAddressRoute(locationController.addressList![index]));
                      },
                      onRemovePressed: () {
                        if(Get.isSnackbarOpen) {
                          Get.back();
                        }
                        Get.dialog(ConfirmationDialog(icon: Images.warning, description: 'are_you_sure_want_to_delete_address'.tr, onYesPressed: () {
                          Get.back();
                          Get.dialog(const CustomLoader(), barrierDismissible: false);
                          locationController.deleteUserAddressByID(locationController.addressList![index].id, index).then((response) {
                            Get.back();
                            showCustomSnackBar(response.message, isError: !response.isSuccess);
                          });
                        }));
                      },
                    ),
                  );
                },
              ),
            )),
          )),
        ) : NoDataScreen(text: 'no_saved_address_found'.tr) : const Center(child: CircularProgressIndicator());
      }) : const NotLoggedInScreen(),
    );
  }
}
