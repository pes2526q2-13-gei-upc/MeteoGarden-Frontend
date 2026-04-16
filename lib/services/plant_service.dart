import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/url.dart';
import '../models/plant_identification.dart';

class PlantIdentificationException implements Exception {
  final String message;
  final int? statusCode;

  const PlantIdentificationException(
      this.message, {
        this.statusCode,
      });

  @override
  String toString() => message;
}

class PlantService {
  static Future<PlantIdentification> identifyPlant({
    required String username,
    required String imagePath,
    String organ = 'leaf',
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/plants/identify');

      final request = http.MultipartRequest('POST', uri)
        ..fields['username'] = username
        ..fields['organ'] = organ
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse =
      await request.send().timeout(const Duration(seconds: 40));

      final response = await http.Response.fromStream(streamedResponse);
      final body = _decodeJsonSafely(response.body);

      if (response.statusCode != 201) {
        throw _mapError(
          statusCode: response.statusCode,
          body: body,
          rawBody: response.body,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PlantIdentification.fromJson(data);
    } on SocketException {
      throw const PlantIdentificationException(
        'No hi ha connexió amb el servidor.',
      );
    } on HttpException {
      throw const PlantIdentificationException(
        'Error de comunicació amb el servidor.',
      );
    } on PlantIdentificationException {
      rethrow;
    } catch (_) {
      throw const PlantIdentificationException(
        'S’ha produït un error inesperat durant la identificació.',
      );
    }
  }

  static Map<String, dynamic> _decodeJsonSafely(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  static PlantIdentificationException _mapError({
    required int statusCode,
    required Map<String, dynamic> body,
    required String rawBody,
  }) {
    final message = switch (statusCode) {
      400 => _firstNonEmpty([
        body['detail'],
        body['error'],
        body['image'],
        body['username'],
        body['organ'],
        body['organs'],
      ]) ??
          'La petició no és correcta.',
      404 =>
      _stringOrNull(body['username']) ?? 'No s’ha trobat el recurs demanat.',
      422 =>
      _stringOrNull(body['detail']) ?? 'No s’ha pogut identificar la planta.',
      502 =>
      _stringOrNull(body['detail']) ?? 'El servei d’identificació ha fallat.',
      _ when statusCode >= 500 =>
      _stringOrNull(body['detail']) ?? 'Error intern del servidor.',
      _ => 'Error $statusCode: $rawBody',
    };

    return PlantIdentificationException(
      message,
      statusCode: statusCode,
    );
  }

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = _stringOrNull(value);
      if (text != null && text.trim().isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  static String? _stringOrNull(dynamic value) {
    return value is String ? value : null;
  }
}