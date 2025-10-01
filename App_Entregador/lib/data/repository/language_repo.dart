import 'package:app_entregador/data/model/response/language_model.dart';
import 'package:app_entregador/util/app_constants.dart';
import 'package:flutter/material.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages({BuildContext context}) {
    return AppConstants.languages;
  }
}
