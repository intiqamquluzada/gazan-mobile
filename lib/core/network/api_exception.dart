/// Wraps backend `ApiError` responses + transport-level failures so the UI
/// only ever has to deal with one exception type.
class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    required this.status,
    this.fields = const <String, String>{},
  });

  final String code;
  final String message;
  final int status;
  final Map<String, String> fields;

  bool get isUnauthorized => status == 401;
  bool get isForbidden => status == 403;
  bool get isNotFound => status == 404;
  bool get isConflict => status == 409;
  bool get isValidation => status == 400 || status == 422;

  @override
  String toString() => message;
}
