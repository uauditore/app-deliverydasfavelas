import 'package:app_cliente/controller/splash_controller.dart';
import 'package:app_cliente/helper/responsive_helper.dart';
import 'package:app_cliente/util/dimensions.dart';
import 'package:app_cliente/util/html_type.dart';
import 'package:app_cliente/util/styles.dart';
import 'package:app_cliente/view/base/custom_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlViewerScreen extends StatelessWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({Key? key, required this.htmlType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? data = htmlType == HtmlType.TERMS_AND_CONDITION ? Get.find<SplashController>().configModel!.termsAndConditions
        : htmlType == HtmlType.ABOUT_US ? Get.find<SplashController>().configModel!.aboutUs
        : htmlType == HtmlType.PRIVACY_POLICY ? Get.find<SplashController>().configModel!.privacyPolicy
        : htmlType == HtmlType.REFUND_POLICY ? Get.find<SplashController>().configModel!.refundPolicyData
        : htmlType == HtmlType.CANCELLATION_POLICY ? Get.find<SplashController>().configModel!.cancellationPolicyData
        : htmlType == HtmlType.SHIPPING_POLICY ? Get.find<SplashController>().configModel!.shippingPolicyData
        : null;

    if(data != null && data.isNotEmpty) {
      data = data.replaceAll('href=', 'target="_blank" href=');
    }

    return Scaffold(
      appBar: CustomAppBar(title: htmlType == HtmlType.TERMS_AND_CONDITION ? 'terms_conditions'.tr
          : htmlType == HtmlType.ABOUT_US ? 'about_us'.tr : htmlType == HtmlType.PRIVACY_POLICY
          ? 'privacy_policy'.tr :  htmlType == HtmlType.SHIPPING_POLICY ? 'shipping_policy'.tr
          : htmlType == HtmlType.REFUND_POLICY ? 'refund_policy'.tr :  htmlType == HtmlType.CANCELLATION_POLICY
          ? 'cancellation_policy'.tr  : 'no_data_found'.tr),
      body: Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          height: MediaQuery.of(context).size.height,
          color: GetPlatform.isWeb ? Colors.white : Theme.of(context).cardColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

              ResponsiveHelper.isDesktop(context) ? Container(
                height: 50, alignment: Alignment.center, color: Theme.of(context).cardColor, width: Dimensions.webMaxWidth,
                child: SelectableText(htmlType == HtmlType.TERMS_AND_CONDITION ? 'terms_conditions'.tr
                    : htmlType == HtmlType.ABOUT_US ? 'about_us'.tr : htmlType == HtmlType.PRIVACY_POLICY
                    ? 'privacy_policy'.tr : htmlType == HtmlType.SHIPPING_POLICY ? 'shipping_policy'.tr
                    : htmlType == HtmlType.REFUND_POLICY ? 'refund_policy'.tr :  htmlType == HtmlType.CANCELLATION_POLICY
                    ? 'cancellation_policy'.tr : 'no_data_found'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                ),
              ) : const SizedBox(),

              (data!.contains('<ol>') || data.contains('<ul>')) ? HtmlWidget(
                data,
                key: Key(htmlType.toString()),
                isSelectable: true,
                onTapUrl: (String url) {
                  return launchUrlString(url, mode: LaunchMode.externalApplication);
                },
              ) : const SizedBox()
              // SelectableHtml(
              //   data: data, shrinkWrap: true,
              //   onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, element) {
              //     if(url!.startsWith('www.')) {
              //       url = 'https://$url';
              //     }
              //     if (kDebugMode) {
              //       print('Redirect to url: $url');
              //     }
              //     html.window.open(url, "_blank");
              //   },
              // ),

            ]),
          ),
        ),
      ),
    );
  }
}