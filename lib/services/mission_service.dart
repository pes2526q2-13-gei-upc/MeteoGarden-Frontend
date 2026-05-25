import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/url.dart';
import '../models/missions.dart';

class MissionException implements Exception {
  final String message;
  final int? statusCode;

  const MissionException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class MissionService {
  static Future<List<Mission>> fetchMissions({
    required String token,
    http.Client? client,
  }) async {
    final c = client ?? http.Client();
    try {
      final response = await c.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/missions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode != 200) {
        throw MissionException(
          'Error ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body);
      final List list = data['missions'];
      return list.map((e) => Mission.fromJson(e)).toList();
    } on SocketException {
      throw const MissionException('No hi ha connexió amb el servidor.');
    } on HttpException {
      throw const MissionException('Error de comunicació amb el servidor.');
    } on MissionException {
      rethrow;
    } catch (_) {
      throw const MissionException(
        'S\'ha produït un error inesperat carregant les missions.',
      );
    }
  }

  static Future<int> claimMission({
    required String token,
    required Mission mission,
    http.Client? client,
  }) async {
    final c = client ?? http.Client();
    try {
      final response = await c.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/missions/claim/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({'mission': mission.name}),
      );

      if (response.statusCode != 200) {
        final data = _decodeJsonSafely(response.body);
        final errorKey = data['error'] ?? '';
        throw MissionException(errorKey, statusCode: response.statusCode);
      }

      // Devolvemos las monedas ganadas directamente del objeto mission
      return mission.rewardCoins > 0 ? mission.rewardCoins.toInt() : 0;
    } on SocketException {
      throw const MissionException('No hi ha connexió amb el servidor.');
    } on HttpException {
      throw const MissionException('Error de comunicació amb el servidor.');
    } on MissionException {
      rethrow;
    } catch (_) {
      throw const MissionException(
        'S\'ha produït un error inesperat reclamant la recompensa.',
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
}
