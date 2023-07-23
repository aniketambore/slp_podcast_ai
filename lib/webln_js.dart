// Define the library and import the JS interop library
@JS()
library webln;

import 'package:js/js.dart';

@JS()
external Future<bool> isWeblnEnabled(
  void Function() weblnEnabledCallback,
  void Function() weblnDisabledCallback,
);

@JS()
external Future<void> sendPayment(
  invoice,
  void Function(String) authCallback,
);
