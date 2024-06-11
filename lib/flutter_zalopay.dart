import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_zalopay/models/create_order_response.dart';
import 'package:flutter_zalopay/utils/endpoints.dart';
import 'package:flutter_zalopay/utils/util.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';

class FlutterZalopay {
  static const MethodChannel _channel =
      MethodChannel('flutter.native/channelPayOrder');

  int _appId = 0;
  String _key1 = '';
  String _key2 = '';
  String _appUser = "zalopaydemo";
  int _transIdDefault = 1;

  Future<ZaloPayStatus> payOrder({
    required String zpToken,
  }) async {
    final int result = await _channel.invokeMethod('payOrder', {
      "zptoken": zpToken,
    });
    switch (result) {
      case 2:
        return ZaloPayStatus.cancelled;
      case 1:
        return ZaloPayStatus.success;
      case -1:
        return ZaloPayStatus.failed;
      default:
        return ZaloPayStatus.failed;
    }
  }

  Future<void> init({
    required int appId,
    required String key1,
    required String uriScheme,
    required ZaloPayEnvironment environment,
  }) async {
    _appId = appId;
    _key1 = key1;

    await _channel.invokeMethod('init', {
      "appId": appId,
      "uriScheme": uriScheme,
      "environment": environment.value,
    });
  }

  Future<CreateOrderResponse?> createOrder(int price) async {
    var header = <String, String>{};
    header["Content-Type"] = "application/x-www-form-urlencoded";

    var body = <String, String>{};
    final appTransId = getAppTransId();
    body["app_id"] = _appId.toString();
    body["app_user"] = _appUser;
    body["app_time"] = DateTime.now().millisecondsSinceEpoch.toString();
    body["amount"] = price.toStringAsFixed(0);
    body["app_trans_id"] = appTransId;
    body["embed_data"] = "{}";
    body["item"] = "[]";
    body["bank_code"] = getBankCode();
    body["description"] = getDescription(appTransId);

    var dataGetMac = sprintf("%s|%s|%s|%s|%s|%s|%s", [
      body["app_id"],
      body["app_trans_id"],
      body["app_user"],
      body["amount"],
      body["app_time"],
      body["embed_data"],
      body["item"]
    ]);
    body["mac"] = getMacCreateOrder(dataGetMac, _key1);
    print("mac: ${body["mac"]}");

    http.Response response = await http.post(
      Uri.parse(Uri.encodeFull(Endpoints.createOrderUrl)),
      headers: header,
      body: body,
    );

    print("body_request: $body");
    if (response.statusCode != 200) {
      return null;
    }

    var data = jsonDecode(response.body);
    print("data_response: $data}");

    return CreateOrderResponse.fromJson(data);
  }
}

enum ZaloPayStatus {
  cancelled,
  success,
  failed,
}

enum ZaloPayEnvironment {
  sandbox("SANDBOX"),
  production("PRODUCTION");

  const ZaloPayEnvironment(this.value);
  final String value;
}
