import 'dart:convert';
import 'package:firstapp/models/acquisition_record.dart';
import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_inventory.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/models/birth_record.dart';
import 'package:firstapp/models/config.dart';
import 'package:firstapp/models/died_record.dart';
import 'package:firstapp/models/weight_category.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/animal.dart';

class ApiService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final LoggerService _logger = LoggerService();
  static final http.Client _client = http.Client();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Endpoints constants
  static const String _tokenKey = 'access_token';
  static const String _typesEndpoint = '/animals/animal-types/';
  static const String _breedsEndpoint = '/animals/animal-breeds/';
  static const String _birthRecordsEndpoint = '/animals/birth-records/';
  static const String _diedRecordsEndpoint = '/animals/died-records/';
  static const String _acquisitionRecordsEndpoint = '/animals/acquisition_records/';
  static const String _weightCategories = '/animals/weight-categories/';
  static const String _animalInventories = '/animals/animal-inventories/';
  static const String _animalsRecords = '/animals/birth-records/';
  static const String _breedAnimalTypes =
      '/animals/animal-breeds/?animal_type=';

  //Common headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Animal>> fetchAnimals() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(Uri.parse(_baseUrl), headers: headers);

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((item) => Animal.fromJson(item))
            .toList();
      }
      throw _createException('Error loading animals', response);
    } catch (e) {
      _logger.error('Exception in fetchAnimals: $e');
      rethrow;
    }
  }

  Future<List<AnimalInventory>> fetchAnimalInventories() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl$_animalInventories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((item) => AnimalInventory.fromJson(item))
            .toList();
      }
      throw _createException('Error loading animals', response);
    } catch (e) {
      _logger.error('Exception in fetchAnimals: $e');
      rethrow;
    }
  }

  static Future<List<AnimalType>> fetchAnimalTypes() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl$_typesEndpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => AnimalType.fromJson(e))
            .toList();
      }
      throw _createException("Failed to load animal types", response);
    } catch (e) {
      _logger.error('Exception in fetchAnimalTypes: $e');
      rethrow;
    }
  }

  static Future<List<AnimalBreed>> fetchBreeds(int animalTypeId) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse(
        '$_baseUrl$_breedsEndpoint',
      ).replace(queryParameters: {'animal_type': animalTypeId.toString()});
      final response = await _client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => AnimalBreed.fromJson(e))
            .toList();
      }
      throw _createException("Failed to load races", response);
    } catch (e) {
      _logger.error('Exception in fetchBreeds: $e');
      rethrow;
    }
  }

  Future<List<AnimalBreed>> fetchBreedsByAnimalType(int animalTypeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_breedAnimalTypes$animalTypeId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> breedsJson = json.decode(response.body);
        return breedsJson.map((json) => AnimalBreed.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load breeds: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching breeds: $e');
    }
  }

  static Future<List<WeightCategory>> fetchWeightCategories() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl$_weightCategories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => WeightCategory.fromJson(e))
            .toList();
      }
      throw _createException("Failed to load animal inventories", response);
    } catch (e) {
      _logger.error('Exception in WeightCategories: $e');
      rethrow;
    }
  }

  static Future<bool> registerBirth(BirthRecord birthRecord) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('$_baseUrl$_birthRecordsEndpoint'),
        headers: headers,
        body: json.encode(birthRecord.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      }
      _logger.error("Registration error: ${response.body}");
      return false;
    } catch (e) {
      _logger.error('Exception in registerBirth: $e');
      return false;
    }
  }

  Future<List<BirthRecord>> fetchBirthRecords() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$_animalsRecords'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => BirthRecord.fromJson(json)).toList();
    } else {
      _logger.error('Failed to load birth records');
      return [];
    }
  }

  static Future<bool> registerAcquisition(AcquisitionRecord record) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('$_baseUrl$_acquisitionRecordsEndpoint'),
        headers: headers,
        body: json.encode(record.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      }
      _logger.error("Registration error: ${response.body}");
      return false;
    } catch (e) {
      print('Error registering acquisition: $e');
      return false;
    }
  }

  static Future<bool> registerDied(DiedRecord record) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('$_baseUrl$_diedRecordsEndpoint'),
        headers: headers,
        body: json.encode(record.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      }
      _logger.error("Registration error: ${response.body}");
      return false;
    } catch (e) {
      print('Error registering death: $e');
      return false;
    }
  }

  static Exception _createException(String message, http.Response response) {
    return Exception('$message (${response.statusCode}): ${response.body}');
  }

  static void dispose() {
    _client.close();
  }
}
