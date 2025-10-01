import 'package:firebase_core/firebase_core.dart';

enum Flavor { appDeliveryDasFavelas }

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static bool get skipLanguage {
    switch (appFlavor) {
      case Flavor.appDeliveryDasFavelas:
        return true;
      default:
        return false;
    }
  }

  static String get appTitle {
    switch (appFlavor) {
      case Flavor.appDeliveryDasFavelas:
        return 'Delivery das Favelas';
      default:
        return 'AppCliente';
    }
  }

  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.appDeliveryDasFavelas:
        return 'https://deliverydasfavelas.app.br';
      default:
        return 'http://localhost';
    }
  }

  static String get logoImage {
    String flavr = "";
    switch (appFlavor) {
      case Flavor.appDeliveryDasFavelas:
        flavr = "vegfood";
        break;
      default:
        flavr = "";
    }

    return "${flavr}_logo.png";
  }

  static String get splashImage {
    String flavr = "";
    switch (appFlavor) {
      case Flavor.appDeliveryDasFavelas:
        flavr = "deliverydasfavelas";
        break;
      default:
        flavr = "";
    }

    return "${flavr}_splash.png";
  }

  static String get mapKey {
    switch (appFlavor) {
      case Flavor.appDeliveryDasFavelas:
        return 'AIzaSyDHvHnJ2YmY6_Rg3D4D1Bwr9aJ5ZBojZUA';
      default:
        return '';
    }
  }

  static String get facebookAppID {
    switch (appFlavor) {
      case Flavor.appDeliveryDasFavelas:
        return '000';
      default:
        return '000';
    }
  }

  static FirebaseOptions get firebaseOpt {
    switch (appFlavor) {
      case Flavor.appDeliveryDasFavelas:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDaH01xVUiw0vCfMurVMM8q-oSGLVwYQak',
          appId: '1:519142677304:web:3303403d9f06c859853fcd',
          messagingSenderId: '519142677304',
          projectId: 'deliveryfavela-app',
        );
      default:
        return const FirebaseOptions(
          apiKey: '',
          appId: '',
          messagingSenderId: '',
          projectId: '',
        );
    }
  }
}
