import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tcg_card.dart';

/// Pokémon TCG API Service (no API key for Flutter Web)
class TcgApi {
  static const String _baseUrl = 'https://api.pokemontcg.io/v2';

  /// Fetches Grass-type Pokémon cards (green color)
  static Future<List<TcgCard>> fetchGrassCards({int page = 1, int pageSize = 20}) async {
    final uri = Uri.parse(
      '$_baseUrl/cards'
      '?q=types:grass'
      '&select=id,name,images'
      '&page=$page'
      '&pageSize=$pageSize'
      '&orderBy=name',
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw Exception('Request timed out (30s).');
    });

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List<dynamic>? ?? []);
    return data.map((e) => TcgCard.fromJson(e as Map<String, dynamic>)).toList();
  }
}
