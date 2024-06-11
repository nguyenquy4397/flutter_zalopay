import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zalopay/flutter_zalopay.dart';
import 'package:flutter_zalopay_example/config.dart';
import 'package:flutter_zalopay_example/theme_data.dart';

class Home extends StatefulWidget {
  const Home({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _zaloPayPlugin = FlutterZalopay();

  final textStyle = const TextStyle(color: Colors.black54);
  final valueStyle = const TextStyle(
    color: AppColor.accentColor,
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
  );
  String zpTransToken = "";
  String payResult = "";
  String payAmount = "10000";
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    _zaloPayPlugin.init(
      appId: ZaloPayConfig.appId,
      key1: ZaloPayConfig.key1,
      uriScheme: ZaloPayConfig.uriScheme,
      environment: ZaloPayEnvironment.sandbox,
    );
  }

  // Button Create Order
  Widget _btnCreateOrder(String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: GestureDetector(
          onTap: () async {
            int amount = int.parse(value);
            if (amount < 1000 || amount > 1000000) {
              setState(() {
                zpTransToken = "Invalid Amount";
              });
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  });
              final result = await _zaloPayPlugin.createOrder(amount);
              Navigator.pop(context);
              if (result != null) {
                zpTransToken = result.zpTransToken;
                setState(() {
                  zpTransToken = result.zpTransToken;
                  showResult = true;
                });
              }
            }
          },
          child: Container(
              height: 50.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("Create Order",
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
        ),
      );

  /// Build Button Pay
  Widget _btnPay(String zpToken) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Visibility(
        visible: showResult,
        child: GestureDetector(
          onTap: () async {
            String response = "";
            try {
              final result = await _zaloPayPlugin.payOrder(zpToken: zpToken);
              print("payOrder Result: '$result'.");
            } on PlatformException catch (e) {
              print("Failed to Invoke: '${e.message}'.");
              response = "Thanh toán thất bại";
            }
            print(response);
            setState(() {
              payResult = response;
            });
          },
          child: Container(
            height: 50.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Text(
              "Pay",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _quickConfig,
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Amount',
            icon: Icon(Icons.attach_money),
          ),
          initialValue: payAmount,
          onChanged: (value) {
            setState(() {
              payAmount = value;
            });
          },
          keyboardType: TextInputType.number,
        ),
        _btnCreateOrder(payAmount),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Visibility(
            visible: showResult,
            child: Text(
              "zptranstoken:",
              style: textStyle,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            zpTransToken,
            style: valueStyle,
          ),
        ),
        _btnPay(zpTransToken),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Visibility(
            visible: showResult,
            child: Text(
              "Transaction status:",
              style: textStyle,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            payResult,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

/// Build Info App
Widget _quickConfig = Container(
  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: const Text("AppID: 2554"),
          ),
        ],
      ),
      // _btnQuickEdit,
    ],
  ),
);
