class WebSocketMessage {
  String code; // 状态码
  String message; // 提示信息
  dynamic data;

   WebSocketMessage({
    required this.code,
    required this.message,
    this.data,
  });

    factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
     return WebSocketMessage(
       code: json['code'],
       message: json['message'],
       data: json['data'],
     );
   }

   Map<String, dynamic> toJson() {
     return {
       "code": code,
       "message": message,
       "data": data,
     };
   }

  @override
  String toString() {
    return 'WebSocketMessage{code: $code, message: $message, data: $data}';
  }


}
