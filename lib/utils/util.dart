import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

/// Function Format DateTime to String with layout string
String formatNumber(double value) =>
    NumberFormat("#,###", "vi_VN").format(value);

/// Function Format DateTime to String with layout string
String formatDateTime(DateTime dateTime, String layout) {
  return DateFormat(layout).format(dateTime).toString();
}

int transIdDefault = 1;
String getAppTransId() {
  if (transIdDefault >= 100000) {
    transIdDefault = 1;
  }

  transIdDefault += 1;
  var timeString = formatDateTime(DateTime.now(), "yyMMdd_hhmmss");
  return sprintf("%s%06d", [timeString, transIdDefault]);
}

String getBankCode() => "zalopayapp";
String getDescription(String appTransId) =>
    "Merchant Demo thanh toán cho đơn hàng  #$appTransId";

String getMacCreateOrder(String data, String key) {
  var hmac = Hmac(sha256, utf8.encode(key));
  return hmac.convert(utf8.encode(data)).toString();
}
