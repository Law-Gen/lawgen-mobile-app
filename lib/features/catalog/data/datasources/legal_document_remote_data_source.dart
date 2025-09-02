import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exception.dart';
import '../models/legal_document_model.dart';
import '../models/paginated_legal_documents_model.dart';

abstract class LegalDocumentRemoteDataSource {
  Future<PaginatedLegalDocumentsModel> getLegalDocuments({
    required int page,
    required int pageSize,
  });

  Future<List<LegalDocumentModel>> getLegalDocumentsByCategoryId({
    required String id,
  });
}

const String _baseUrl =
    'https://your-api.com/api/v1'; // Ganti dengan URL API Anda
const String CACHED_AUTH_TOKEN = 'ACCESS_TOKEN';

class LegalDocumentRemoteDataSourceImpl
    implements LegalDocumentRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  LegalDocumentRemoteDataSourceImpl({
    required this.client,
    required this.secureStorage,
  });

  Future<Map<String, String>> get _headers async {
    final token = await secureStorage.read(key: CACHED_AUTH_TOKEN);
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  @override
  Future<PaginatedLegalDocumentsModel> getLegalDocuments({
    required int page,
    required int pageSize,
  }) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/contents?page=$page&page_size=$pageSize'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return PaginatedLegalDocumentsModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<LegalDocumentModel>> getLegalDocumentsByCategoryId({
    required String id,
  }) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/contents/$id'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((jsonItem) => LegalDocumentModel.fromJson(jsonItem))
          .toList();
    } else {
      throw ServerException();
    }
  }
}
