class ResponseModel<T> {
  final int code;
  final String message;
  final T? data;

  ResponseModel({
    required this.code,
    required this.message,
    this.data,
  });

  // ===================================================
  // FACTORY DESDE JSON
  // ===================================================
  factory ResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ResponseModel<T>(
      code: json['code'] ?? 1,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  // ===================================================
  // HELPERS
  // ===================================================
  bool get isSuccess => code == 0;
}
