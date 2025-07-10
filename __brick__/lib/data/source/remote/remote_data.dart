import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

class RemoteData {
  static RemoteData instance = GetIt.instance.get<RemoteData>();
  final Dio _dio = Dio();
  final internetConnectionChecker = InternetConnectionChecker.instance;

  Future<dynamic> getData({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }

      final apiUrl = Uri.parse(url).replace(queryParameters: queryParameters);

      final response = await http
          .get(apiUrl, headers: headers ?? {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = jsonDecode(response.body);
        if (decodedBody is List) {
          return {"data": decodedBody};
        } else if (decodedBody is Map<String, dynamic>) {
          return decodedBody;
        } else {
          throw 'Unexpected response format';
        }
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('error')) {
          throw ApiException(data['error']);
        } else if (data.containsKey('errors')) {
          throw ApiException(data['errors'].toString());
        } else {
          throw ApiException(data['message']);
        }
      }
    } on TimeoutException catch (_) {
      throw 'The request timed out. Please try again later.';
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else if (e == 'No internet connection') {
        rethrow;
      }
      rethrow;
    }
  }

  Future<dynamic> postData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }

      final apiUrl = Uri.parse(url);
      final response = await http
          .post(
            apiUrl,
            headers: headers ?? {'Content-Type': 'application/json'},
            body: data == null ? null : jsonEncode(data),
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('error')) {
          throw ApiException(data['error']);
        } else if (data.containsKey('errors')) {
          throw ApiException(data['errors'].toString());
        } else {
          throw ApiException(data['message']);
        }
      }
    } on TimeoutException catch (_) {
      throw 'The request timed out. Please try again later.';
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else if (e == 'No internet connection') {
        rethrow;
      }
      rethrow;
    }
  }

  Future<String> postRawData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }

      final apiUrl = Uri.parse(url);
      final response = await http
          .post(
            apiUrl,
            headers: headers ?? {'Content-Type': 'application/json'},
            body: data == null ? null : jsonEncode(data),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(data['message']);
      }
    } on TimeoutException catch (_) {
      throw 'The request timed out. Please try again later.';
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else if (e == 'No internet connection') {
        rethrow;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }
      final apiUrl = Uri.parse(url);

      final response = await http.patch(
        apiUrl,
        headers: headers ?? {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw data['msg'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> putData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }
      final apiUrl = Uri.parse(url);

      final response = await http.put(
        apiUrl,
        headers: headers ?? {'Content-Type': 'application/json'},
        body: data == null ? null : jsonEncode(data),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postFileFormData({
    required String url,
    required File file,
    Map<String, String>? headers,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }

      FormData formDataToSend = FormData();

      String fileName = file.path.split('/').last;
      formDataToSend.files.add(
        MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );

      final response = await _dio.post(
        url,
        data: formDataToSend,
        options: Options(headers: headers),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        final data = jsonDecode(response.data);
        throw data['message'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> sendDataWithImage({
    required String url,
    required Map<String, dynamic> formData,
    required File imageFile,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }
      FormData formDataToSend = FormData.fromMap(formData);

      String fileName = imageFile.path.split('/').last;
      formDataToSend.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path, filename: fileName),
        ),
      );

      final response = await _dio.post(url, data: formDataToSend);

      if (response.statusCode == 201) {
      } else {
        final data = jsonDecode(response.data);
        throw data['message'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Uint8List> download({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }

      final apiUrl = Uri.parse(url);
      final response = await http
          .get(apiUrl, headers: headers ?? {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(data['message']);
      }
    } on TimeoutException catch (_) {
      throw 'The request timed out. Please try again later.';
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else if (e == 'No internet connection') {
        rethrow;
      }
      rethrow;
    }
  }

  Future<void> checkInternetConnection() async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<InternetConnectionStatus> streamInternetConnect() {
    return internetConnectionChecker.onStatusChange;
  }

  Future<Uint8List> getFile({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      bool result = await internetConnectionChecker.hasConnection;
      if (!result) {
        throw 'No internet connection';
      }

      final apiUrl = Uri.parse(url);
      final response = await http
          .get(apiUrl, headers: headers ?? {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(data['message']);
      }
    } on TimeoutException catch (_) {
      throw 'The request timed out. Please try again later.';
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else if (e == 'No internet connection') {
        rethrow;
      }
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
