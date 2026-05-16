import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/url.dart';

class AmicsService {
  /// Cerca usuaris que continguin [query] al seu nom d'usuari.
  /// Retorna una llista de maps amb 'username' i 'avatar'.
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/search/?q=${Uri.encodeComponent(query)}',
    );
    final response = await http.get(uri, headers: _headers(token));

    _checkStatus(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  /// Retorna la llista d'amics de l'usuari autenticat.
  Future<List<Map<String, dynamic>>> fetchFriends({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/friends/');
    final response = await http.get(uri, headers: _headers(token));

    _checkStatus(response);

    final decoded = jsonDecode(response.body);

    List<dynamic> rawFriends;

    if (decoded is Map<String, dynamic>) {
      rawFriends = decoded['friends'] as List<dynamic>? ?? [];
    } else if (decoded is List) {
      rawFriends = decoded;
    } else {
      rawFriends = [];
    }

    return rawFriends.map<Map<String, dynamic>>((item) {
      final friend = Map<String, dynamic>.from(item as Map);

      return {
        'username': friend['username'],
        'garden_name':
            friend['garden_name'] ?? friend['garden'] ?? friend['username'],
      };
    }).toList();
  }

  /// Envia una sol·licitud d'amistat a [requestedUsername].
  Future<String> sendFriendRequest({
    required String requestedUsername,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/friends/send_request/');
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'requested': requestedUsername}),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (decoded is Map<String, dynamic>) {
        return decoded['message'] as String? ?? '';
      }

      return '';
    }

    String errorMessage = 'Error desconegut';

    if (decoded is Map<String, dynamic>) {
      errorMessage =
          decoded['error']?.toString() ??
          decoded['detail']?.toString() ??
          'Error desconegut';
    } else if (decoded is List && decoded.isNotEmpty) {
      errorMessage = decoded.first.toString();
    } else if (decoded is String) {
      errorMessage = decoded;
    }

    errorMessage = errorMessage
        .replaceFirst(RegExp(r'^error:\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^Error:\s*', caseSensitive: false), '')
        .trim();

    throw Exception(errorMessage);
  }

  /// Respon una sol·licitud d'amistat rebuda de [requesterUsername].
  /// [action] ha de ser 'accept' o 'reject'.
  Future<String> answerFriendRequest({
    required String requesterUsername,
    required String action, // 'accept' o 'reject'
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/friends/answer_request/');

    final bodyToSend = {'requester': requesterUsername, 'action': action};

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(bodyToSend),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (decoded is Map<String, dynamic>) {
        return decoded['message'] as String? ??
            'Sol·licitud resposta correctament';
      }

      return 'Sol·licitud resposta correctament';
    }

    if (decoded is Map<String, dynamic>) {
      throw Exception(
        decoded['error'] ??
            decoded['detail'] ??
            'Error desconegut responent la sol·licitud',
      );
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  /// Cancel·la una sol·licitud d'amistat enviada a [requestedUsername].
  Future<String> cancelFriendRequest({
    required String requestedUsername,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/friends/cancel_request/');

    final bodyToSend = {'requested': requestedUsername};

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(bodyToSend),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (decoded is Map<String, dynamic>) {
        return decoded['message'] as String? ??
            'Sol·licitud cancel·lada correctament';
      }

      return 'Sol·licitud cancel·lada correctament';
    }

    if (decoded is Map<String, dynamic>) {
      throw Exception(
        decoded['error'] ??
            decoded['detail'] ??
            'Error desconegut cancel·lant la sol·licitud',
      );
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  /// Obté les sol·licituds enviades o rebudes.
  /// [action] ha de ser 'sent' o 'received'.
  Future<List<String>> fetchFriendRequests({
    required String action,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/friends/requests/');

    final bodyResponse = await _getWithBody(
      uri: uri,
      token: token,
      body: {'action': action},
    );

    final data = jsonDecode(bodyResponse.body) as Map<String, dynamic>;

    if (bodyResponse.statusCode == 200) {
      if (action == 'sent') {
        return List<String>.from(
          data['requests_sent_to'] ?? data['requests_sent to'] ?? [],
        );
      } else {
        return List<String>.from(
          data['requests_received_from'] ??
              data['requests_received from'] ??
              [],
        );
      }
    }

    throw Exception(data['error'] ?? 'Error desconegut');
  }

  // ELIMINAR AMIC
  /// Elimina la relació d'amistat amb [username].
  Future<String> deleteFriend({
    required String username,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/friends/$username');
    final response = await http.delete(uri, headers: _headers(token));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return body['success'] as String;
    }
    throw Exception(body['error'] ?? 'Error desconegut');
  }

  /// Dona o treu un "like" al jardí de l'amic [username].
  /// Retorna l'estat final del like: true = like posat, false = like tret.
  Future<bool> likeGarden({
    required String username,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/friends/likes/$username/');
    final response = await http.post(uri, headers: _headers(token));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body['state'] == true;
    }

    throw Exception(body['error'] ?? 'Error desconegut');
  }

  /// Consulta si l'usuari autenticat ja ha fet like al jardí de [username].
  Future<bool> getGardenLikeState({
    required String username,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/friends/likes/$username/');
    final response = await http.get(uri, headers: _headers(token));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body['state'] == true;
    }

    throw Exception(body['error'] ?? 'Error desconegut');
  }

  // HELPERS PRIVATS
  Map<String, String> _headers(String token) => {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  };

  void _checkStatus(http.Response response) {
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Error ${response.statusCode}');
    }
  }

  /// Fa una petició GET amb body (necessari per a l'endpoint de requests).
  Future<http.Response> _getWithBody({
    required Uri uri,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final request = http.Request('GET', uri);
    request.headers.addAll(_headers(token));
    request.body = jsonEncode(body);

    final streamedResponse = await http.Client().send(request);
    return http.Response.fromStream(streamedResponse);
  }

  /// Obté les parts de l'avatar d'un usuari pel seu [username].
  /// Retorna un Map amb les claus: body, eye, expression, hair, facialHair, clothing, accessories.
  /// Retorna null si l'usuari no té avatar o hi ha un error.
  Future<Map<String, dynamic>?> fetchAvatar({
    required String username,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/$username/avatar');
    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
}
