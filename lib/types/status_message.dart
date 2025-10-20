class StatusMessage {
  int statusCode;
  String message;
  bool success;
  String error;
  List<String> errors;
  String authToken;
  int httpStatusCode;
  Map<dynamic, dynamic>? data;
  List<dynamic>? listData;

  StatusMessage({
    required this.success,
    required this.statusCode,
    this.message = "",
    this.error = "",
    this.authToken = "",
    this.httpStatusCode = 0,
    this.data,
    this.listData,
    this.errors = const [],
  });

  factory StatusMessage.fromJson(Map<String, dynamic> json) {
    return StatusMessage(
      success: json["success"] ?? false,
      statusCode: json["status"] ?? 0,
      message: json["message"] ?? '',
      error: json["err"] ?? '',
      authToken: json["auth_token"] ?? '',
      data: (json["data"] is Map<dynamic, dynamic>)
          ? json["data"] as Map<dynamic, dynamic>
          : <dynamic, dynamic>{},
      listData: (json["data"] is List<dynamic>)
          ? (json["data"] as List<dynamic>)
          : [],
      errors: json["errors"] != null
          ? json["errors"].map<String>((el) {
              return (el as String);
            }).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "code": statusCode,
      "success": success,
      "data": data,
    };
  }
}
