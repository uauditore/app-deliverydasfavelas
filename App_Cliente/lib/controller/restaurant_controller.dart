import 'package:app_cliente/controller/category_controller.dart';
import 'package:app_cliente/controller/coupon_controller.dart';
import 'package:app_cliente/controller/location_controller.dart';
import 'package:app_cliente/controller/order_controller.dart';
import 'package:app_cliente/data/api/api_checker.dart';
import 'package:app_cliente/data/model/response/category_model.dart';
import 'package:app_cliente/data/model/response/product_model.dart';
import 'package:app_cliente/data/model/response/recommended_product_model.dart';
import 'package:app_cliente/data/model/response/restaurant_model.dart';
import 'package:app_cliente/data/model/response/review_model.dart';
import 'package:app_cliente/data/repository/restaurant_repo.dart';
import 'package:app_cliente/helper/date_converter.dart';
import 'package:app_cliente/view/base/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantController extends GetxController implements GetxService {
  final RestaurantRepo restaurantRepo;
  RestaurantController({required this.restaurantRepo});

  RestaurantModel? _restaurantModel;
  List<Restaurant>? _restaurantList;
  List<Restaurant>? _popularRestaurantList;
  List<Restaurant>? _latestRestaurantList;
  List<Restaurant>? _recentlyViewedRestaurantList;
  Restaurant? _restaurant;
  List<Product>? _restaurantProducts;
  ProductModel? _restaurantProductModel;
  ProductModel? _restaurantSearchProductModel;
  int _categoryIndex = 0;
  List<CategoryModel>? _categoryList;
  bool _isLoading = false;
  String _restaurantType = 'all';
  List<ReviewModel>? _restaurantReviewList;
  bool _foodPaginate = false;
  int? _foodPageSize;
  List<int> _foodOffsetList = [];
  int _foodOffset = 1;
  String _type = 'all';
  String _searchType = 'all';
  String _searchText = '';
  RecommendedProductModel? _recommendedProductModel;

  RestaurantModel? get restaurantModel => _restaurantModel;
  List<Restaurant>? get restaurantList => _restaurantList;
  List<Restaurant>? get popularRestaurantList => _popularRestaurantList;
  List<Restaurant>? get latestRestaurantList => _latestRestaurantList;
  List<Restaurant>? get recentlyViewedRestaurantList => _recentlyViewedRestaurantList;
  Restaurant? get restaurant => _restaurant;
  ProductModel? get restaurantProductModel => _restaurantProductModel;
  ProductModel? get restaurantSearchProductModel => _restaurantSearchProductModel;
  List<Product>? get restaurantProducts => _restaurantProducts;
  int get categoryIndex => _categoryIndex;
  List<CategoryModel>? get categoryList => _categoryList;
  bool get isLoading => _isLoading;
  String get restaurantType => _restaurantType;
  List<ReviewModel>? get restaurantReviewList => _restaurantReviewList;
  bool get foodPaginate => _foodPaginate;
  int? get foodPageSize => _foodPageSize;
  int get foodOffset => _foodOffset;
  String get type => _type;
  String get searchType => _searchType;
  String get searchText => _searchText;
  RecommendedProductModel? get recommendedProductModel => _recommendedProductModel;

  Future<void> getRecentlyViewedRestaurantList(bool reload, String type, bool notify) async {
    _type = type;
    if(reload){
      _recentlyViewedRestaurantList = null;
    }
    if(notify) {
      update();
    }
    if(_recentlyViewedRestaurantList == null || reload) {
      Response response = await restaurantRepo.getRecentlyViewedRestaurantList(type);
      if (response.statusCode == 200) {
        _recentlyViewedRestaurantList = [];
        response.body.forEach((restaurant) => _recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant)));

      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getRestaurantRecommendedItemList(int? restaurantId, bool reload) async {
    if(reload) {
      _restaurantModel = null;
      update();
    }
    Response response = await restaurantRepo.getRestaurantRecommendedItemList(restaurantId);
    if (response.statusCode == 200) {
      _recommendedProductModel = RecommendedProductModel.fromJson(response.body);

    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getRestaurantList(int offset, bool reload) async {
    if(reload) {
      _restaurantModel = null;
      update();
    }
    Response response = await restaurantRepo.getRestaurantList(offset, _restaurantType);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _restaurantModel = RestaurantModel.fromJson(response.body);
      }else {
        _restaurantModel!.totalSize = RestaurantModel.fromJson(response.body).totalSize;
        _restaurantModel!.offset = RestaurantModel.fromJson(response.body).offset;
        _restaurantModel!.restaurants!.addAll(RestaurantModel.fromJson(response.body).restaurants!);
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void setRestaurantType(String type) {
    _restaurantType = type;
    getRestaurantList(1, true);
  }

  Future<void> getPopularRestaurantList(bool reload, String type, bool notify) async {
    _type = type;
    if(reload){
      _popularRestaurantList = null;
    }
    if(notify) {
      update();
    }
    if(_popularRestaurantList == null || reload) {
      Response response = await restaurantRepo.getPopularRestaurantList(type);
      if (response.statusCode == 200) {
        _popularRestaurantList = [];
        response.body.forEach((restaurant) => _popularRestaurantList!.add(Restaurant.fromJson(restaurant)));
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getLatestRestaurantList(bool reload, String type, bool notify) async {
    _type = type;
    if(reload){
      _latestRestaurantList = null;
    }
    if(notify) {
      update();
    }
    if(_latestRestaurantList == null || reload) {
      Response response = await restaurantRepo.getLatestRestaurantList(type);
      if (response.statusCode == 200) {
        _latestRestaurantList = [];
        response.body.forEach((restaurant) => _latestRestaurantList!.add(Restaurant.fromJson(restaurant)));
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void setCategoryList() {
    if(Get.find<CategoryController>().categoryList != null && _restaurant != null) {
      _categoryList = [];
      _categoryList!.add(CategoryModel(id: 0, name: 'all'.tr));
      for (var category in Get.find<CategoryController>().categoryList!) {
        if(_restaurant!.categoryIds!.contains(category.id)) {
          _categoryList!.add(category);
        }
      }
    }
  }

  void initCheckoutData(int? restaurantID) {
    if(_restaurant == null || _restaurant!.id != restaurantID || Get.find<OrderController>().distance == null) {
      Get.find<CouponController>().removeCouponData(false);
      Get.find<OrderController>().clearPrevData();
      Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantID));
    }else {
      Get.find<OrderController>().initializeTimeSlot(_restaurant!);
    }
  }

  Future<Restaurant?> getRestaurantDetails(Restaurant restaurant) async {
    _categoryIndex = 0;
    if(restaurant.name != null) {
      _restaurant = restaurant;
    }else {
      _isLoading = true;
      _restaurant = null;
      Response response = await restaurantRepo.getRestaurantDetails(restaurant.id.toString());
      if (response.statusCode == 200) {
        _restaurant = Restaurant.fromJson(response.body);
        if(_restaurant != null && _restaurant!.latitude != null){
          Get.find<OrderController>().initializeTimeSlot(_restaurant!);
          Get.find<OrderController>().getDistanceInMeter(
            LatLng(
              double.parse(Get.find<LocationController>().getUserAddress()!.latitude!),
              double.parse(Get.find<LocationController>().getUserAddress()!.longitude!),
            ),
            LatLng(double.parse(_restaurant!.latitude!), double.parse(_restaurant!.longitude!)),
          );
        }
      } else {
        ApiChecker.checkApi(response);
      }
      Get.find<OrderController>().setOrderType(
        (_restaurant != null && _restaurant!.delivery != null) ? _restaurant!.delivery! ? 'delivery' : 'take_away' : 'delivery', notify: false,
      );

      _isLoading = false;
      update();
    }
    return _restaurant;
  }

  Future<void> getRestaurantProductList(int? restaurantID, int offset, String type, bool notify) async {
    _foodOffset = offset;
    if(offset == 1 || _restaurantProducts == null) {
      _type = type;
      _foodOffsetList = [];
      _restaurantProducts = null;
      _foodOffset = 1;
      if(notify) {
        update();
      }
    }
    if (!_foodOffsetList.contains(offset)) {
      _foodOffsetList.add(offset);
      Response response = await restaurantRepo.getRestaurantProductList(
        restaurantID, offset,
        (_restaurant != null && _restaurant!.categoryIds!.isNotEmpty && _categoryIndex != 0)
            ? _categoryList![_categoryIndex].id : 0, type,
      );
      if (response.statusCode == 200) {
        if (offset == 1) {
          _restaurantProducts = [];
        }
        _restaurantProducts!.addAll(ProductModel.fromJson(response.body).products!);
        _foodPageSize = ProductModel.fromJson(response.body).totalSize;
        _foodPaginate = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_foodPaginate) {
        _foodPaginate = false;
        update();
      }
    }
  }

  void showFoodBottomLoader() {
    _foodPaginate = true;
    update();
  }

  void setFoodOffset(int offset) {
    _foodOffset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<void> getStoreSearchItemList(String searchText, String? storeID, int offset, String type) async {
    if(searchText.isEmpty) {
      showCustomSnackBar('write_item_name'.tr);
    }else {
      _searchText = searchText;
      if(offset == 1 || _restaurantSearchProductModel == null) {
        _searchType = type;
        _restaurantSearchProductModel = null;
        update();
      }
      Response response = await restaurantRepo.getRestaurantSearchProductList(searchText, storeID, offset, type);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _restaurantSearchProductModel = ProductModel.fromJson(response.body);
        }else {
          _restaurantSearchProductModel!.products!.addAll(ProductModel.fromJson(response.body).products!);
          _restaurantSearchProductModel!.totalSize = ProductModel.fromJson(response.body).totalSize;
          _restaurantSearchProductModel!.offset = ProductModel.fromJson(response.body).offset;
        }
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  void initSearchData() {
    _restaurantSearchProductModel = ProductModel(products: []);
    _searchText = '';
  }

  void setCategoryIndex(int index) {
    _categoryIndex = index;
    _restaurantProducts = null;
    getRestaurantProductList(_restaurant!.id, 1, Get.find<RestaurantController>().type, false);
    update();
  }

  Future<void> getRestaurantReviewList(String? restaurantID) async {
    _restaurantReviewList = null;
    Response response = await restaurantRepo.getRestaurantReviewList(restaurantID);
    if (response.statusCode == 200) {
      _restaurantReviewList = [];
      response.body.forEach((review) => _restaurantReviewList!.add(ReviewModel.fromJson(review)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  bool isRestaurantClosed(bool today, bool active, List<Schedules>? schedules) {
    if(!active) {
      return true;
    }
    DateTime date = DateTime.now();
    if(!today) {
      date = date.add(const Duration(days: 1));
    }
    int weekday = date.weekday;
    if(weekday == 7) {
      weekday = 0;
    }
    for(int index=0; index<schedules!.length; index++) {
      if(weekday == schedules[index].day) {
        return false;
      }
    }
    return true;
  }

  bool isRestaurantOpenNow(bool active, List<Schedules>? schedules) {
    if(isRestaurantClosed(true, active, schedules)) {
      return false;
    }
    int weekday = DateTime.now().weekday;
    if(weekday == 7) {
      weekday = 0;
    }
    for(int index=0; index<schedules!.length; index++) {
      if(weekday == schedules[index].day
          && DateConverter.isAvailable(schedules[index].openingTime, schedules[index].closingTime)) {
        return true;
      }
    }
    return false;
  }

  bool isOpenNow(Restaurant restaurant) => restaurant.open == 1 && restaurant.active!;

  double? getDiscount(Restaurant restaurant) => restaurant.discount != null ? restaurant.discount!.discount : 0;

  String? getDiscountType(Restaurant restaurant) => restaurant.discount != null ? restaurant.discount!.discountType : 'percent';

}