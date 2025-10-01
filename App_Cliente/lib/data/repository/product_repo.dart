import 'package:app_cliente/data/api/api_client.dart';
import 'package:app_cliente/data/model/body/review_body.dart';
import 'package:app_cliente/util/app_constants.dart';
import 'package:get/get.dart';

class ProductRepo extends GetxService {
  final ApiClient apiClient;
  ProductRepo({required this.apiClient});

  Future<Response> getPopularProductList(String type) async {
    return await apiClient.getData('${AppConstants.popularProductUri}?type=$type');
  }

  Future<Response> getReviewedProductList(String type) async {
    return await apiClient.getData('${AppConstants.reviewedProductUri}?type=$type');
  }

  Future<Response> submitReview(ReviewBody reviewBody) async {
    return await apiClient.postData(AppConstants.reviewUri, reviewBody.toJson());
  }

  Future<Response> submitDeliveryManReview(ReviewBody reviewBody) async {
    return await apiClient.postData(AppConstants.deliveryManReviewUri, reviewBody.toJson());
  }
}
