import 'package:app_cliente/controller/search_controller.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/view/base/product_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemView extends StatelessWidget {
  final bool isRestaurant;
  const ItemView({Key? key, required this.isRestaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SearchControll>(builder: (searchController) {
        return SingleChildScrollView(
          child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: ProductView(
            isRestaurant: isRestaurant, products: searchController.searchProductList, restaurants: searchController.searchRestList,
          ))),
        );
      }),
    );
  }
}
