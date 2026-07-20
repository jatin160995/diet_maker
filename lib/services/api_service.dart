// lib/services/api_service.dart
import 'dart:convert';
import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/main.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> _handleUnauthorized() async {
    await StorageService.clearLoginData();

    // Navigate to login from anywhere in the app
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  //--------------------------Get Request----------------------//
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    print('$baseUrl$endpoint');
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      return showToast("Session expired. Please login again.");
    }
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message:
            json.decode(response.body)['message'] ?? 'Something went wrong',
        code: response.statusCode,
        errorBody: "API Error",
      );
    }
  }

  //--------------------------Put with Token Request----------------------//
  Future<dynamic> getWithToken(
    String endpoint,
    Map<String, String>? headers,
  ) async {
    String? token = (await StorageService.getLoginData())?.accessToken;
    print('$baseUrl$endpoint');
    print(token);
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
    );
    print(response.body);
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      return showToast("Session expired. Please login again.");
    }
    // print(response.statusCode);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message:
            json.decode(response.body)['message'] ?? 'Something went wrong',
        code: response.statusCode,
        errorBody: "API Error",
      );
    }
  }

  //--------------------------Post Request----------------------//
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    String? token = (await StorageService.getLoginData())?.accessToken;
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      return showToast("Session expired. Please login again.");
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message:
            json.decode(response.body)['message'] ?? 'Something went wrong',
        code: response.statusCode,
        errorBody: "API Error",
      );
    }
  }

  //--------------------------Post With Token Request----------------------//
  Future<dynamic> postWithToken(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    String? token = (await StorageService.getLoginData())?.accessToken;
    print("$baseUrl$endpoint");
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      return showToast("Session expired. Please login again.");
    }
    if (response.statusCode == 429) {
      return json.decode(response.body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message:
            json.decode(response.body)['message'] ?? 'Something went wrong',
        code: response.statusCode,
        errorBody: "API Error",
      );
    }
  }

  //--------------------------Put with Token Request----------------------//
  Future<dynamic> putRequest(
    String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic> body,
  ) async {
    print(endpoint);
    //print(body);
    String? token = (await StorageService.getLoginData())?.accessToken;
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers, // additional headers if passed
      },
      body: jsonEncode(body),
    );
    print(response.body);
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      return showToast("Session expired. Please login again.");
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message:
            json.decode(response.body)['message'] ?? 'Something went wrong',
        code: response.statusCode,
        errorBody: "API Error",
      );
    }
  }

  //--------------------------Patch with Token Request----------------------//
  Future<dynamic> patchRequest(
    String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic> body,
  ) async {
    print(endpoint);
    print(body);
    String? token = (await StorageService.getLoginData())?.accessToken;
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers, // additional headers if passed
      },
      body: jsonEncode(body),
    );
    print(response.body);
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      return showToast("Session expired. Please login again.");
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message:
            handleApiError(json.decode(response.body)) ??
            'Something went wrong',
        code: response.statusCode,
        errorBody: "API Error",
      );
    }
  }

  handleApiError(Map<String, dynamic> json) {
    print(json);
    if (json.containsKey('messages')) {
      Map<String, dynamic> messages = json['messages'];

      // Convert all values to a single string
      String errorText = messages.values.join('\n');

      return errorText;
    } else {
      return "Unexpected error response";
    }
  }

  //--------------------------delete with Token Request----------------------//
  Future<dynamic> deleteWithToken(
    String endpoint,
    Map<String, String>? headers,
  ) async {
    String? token = (await StorageService.getLoginData())?.accessToken;
    print('$baseUrl$endpoint');
    print(token);

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      },
    );
    if (response.statusCode == 401) {
      await _handleUnauthorized();
      return showToast("Session expired. Please login again.");
    }
    // print(response.body);
    // print(response.statusCode);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        message:
            json.decode(response.body)['message'] ?? 'Something went wrong',
        code: response.statusCode,
        errorBody: "API Error",
      );
    }
  }

  //--------------------------Post Multipart with Token----------------------//
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, dynamic> fields, {
    Map<String, String>? headers,
    List<http.MultipartFile>? files,
  }) async {
    String? token = (await StorageService.getLoginData())?.accessToken;

    print('$baseUrl$endpoint');
    print("FIELDS: $fields");

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    // Headers
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    });

    /// Add fields
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    /// Add files if any
    if (files != null) {
      request.files.addAll(files);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return showToast("Session expired. Please login again.");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          message:
              json.decode(response.body)['message'] ?? 'Something went wrong',
          code: response.statusCode,
          errorBody: "API Error",
        );
      }
    } catch (e) {
      throw ApiException(
        message: e.toString(),
        code: 500,
        errorBody: "Multipart Exception",
      );
    }
  }
}
