import 'dart:convert';
import 'package:firstapp/models/animal/animal.dart';
import 'package:firstapp/models/config.dart';
import 'package:firstapp/services/api_helper.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:http/http.dart' as http;

class AnimalService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final http.Client _client = http.Client();
  static final _logger = LoggerService();

  static const String _endpoint = '/productions/animals/';

  static Future<List<Animal>> fetchAnimals({
    int? farmId,
    int? animalTypeId,
    int? breedId,
    String? status,
  }) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final queryParams = <String, String>{};
      if (farmId != null) queryParams['farm'] = '$farmId';
      if (animalTypeId != null) queryParams['animal_type'] = '$animalTypeId';
      if (breedId != null) queryParams['breed'] = '$breedId';
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$_baseUrl$_endpoint').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: headers);

      if (response.statusCode == 200) {

          final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> results = decoded['results'];
        return results.map((e) => Animal.fromJson(e)).toList();

        // final List<dynamic> data = json.decode(response.body);
        // return data.map((json) => Animal.fromJson(json)).toList();
      } else {
        throw Exception('Erreur chargement animaux: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Erreur fetchAnimals: $e');
      rethrow;
    }
  }

  static Future<Animal> getAnimal(int id) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl$_endpoint$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Animal.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur récupération animal: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Erreur getAnimal: $e');
      rethrow;
    }
  }

  static Future<bool> createAnimal(Animal animal) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.post(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: headers,
        body: json.encode(animal.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      }
      _logger.error("Erreur création animal: ${response.body}");
      return false;
    } catch (e) {
      _logger.error('Erreur createAnimal: $e');
      return false;
    }
  }

  static Future<bool> updateAnimal(int id, Animal animal) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.put(
        Uri.parse('$_baseUrl$_endpoint$id/'),
        headers: headers,
        body: json.encode(animal.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.error('Erreur updateAnimal: $e');
      return false;
    }
  }

  static Future<bool> deleteAnimal(int id) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.delete(
        Uri.parse('$_baseUrl$_endpoint$id/'),
        headers: headers,
      );
      return response.statusCode == 204;
    } catch (e) {
      _logger.error('Erreur deleteAnimal: $e');
      return false;
    }
  }
}
