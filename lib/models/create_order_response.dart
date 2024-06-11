class CreateOrderResponse {
  final String zpTransToken;
  final String orderUrl;
  final int returnCode;
  final String returnMessage;
  final int subReturnCode;
  final String subReturnMessage;
  final String orderToken;

  CreateOrderResponse({
    required this.zpTransToken,
    required this.orderUrl,
    required this.returnCode,
    required this.returnMessage,
    required this.subReturnCode,
    required this.subReturnMessage,
    required this.orderToken,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      zpTransToken: json['zp_trans_token'] as String,
      orderUrl: json['order_url'] as String,
      returnCode: json['return_code'] as int,
      returnMessage: json['return_message'] as String,
      subReturnCode: json['sub_return_code'] as int,
      subReturnMessage: json['sub_return_message'] as String,
      orderToken: json["order_token"] as String,
    );
  }
}
