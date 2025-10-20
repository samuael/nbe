import 'dart:convert';
import 'package:nbe/libs.dart';
import "package:http/http.dart";

class DataProvider {
  final String fullURL;
  DataProvider._new({required this.fullURL});

  static DataProvider? instance;

  factory DataProvider({required String fullURL}) {
    if (instance != null) {
      return instance!;
    }
    instance = DataProvider._new(fullURL: fullURL);
    return instance!;
  }

  Client client = Client();

  Future<PriceRecordResponse> get(String path, Map<String, dynamic>? arg,
      {String authToken = ""}) async {
    try {
      final uriDetail = Uri.parse(
        "$fullURL$path?date=${arg!["date"]}",
      );
      var response = await client.get(uriDetail);
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PriceRecordResponse.fromJson(json);
      } catch (e, a) {
        return PriceRecordResponse(
          success: false,
          message: "failed with status code ${response.statusCode}",
          status: response.statusCode,
        );
      }
    } catch (e, a) {
      return PriceRecordResponse(
        success: false,
        message: "${e.toString()} Network connection problem",
        status: 500,
      );
    }
  }
}
