import 'dart:convert'; // Often useful for debug printing
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/exception.dart';
import '../models/legal_group_model.dart';
import '../models/legal_content_model.dart';
import '../models/paginated_legal_documents_model.dart';

/// The contract for the remote data source.
abstract class LegalDocumentRemoteDataSource {
  Future<PaginatedLegalGroupsModel> getLegalDocuments({
    required int page,
    required int pageSize,
  });

  Future<List<LegalContentModel>> getLegalDocumentsByCategoryId({
    required String id,
  });
}

/*
// =======================================================================
// ORIGINAL API-CALLING IMPLEMENTATION
// =======================================================================

const String _baseUrl = 'https://your-api.com/api/v1';
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
  Future<PaginatedLegalGroupsModel> getLegalDocuments({
    required int page,
    required int pageSize,
  }) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/groups?page=$page&page_size=$pageSize'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      return PaginatedLegalGroupsModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<LegalContentModel>> getLegalDocumentsByCategoryId({
    required String id,
  }) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/contents/$id'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((jsonItem) => LegalContentModel.fromJson(jsonItem))
          .toList();
    } else {
      throw ServerException();
    }
  }
}
*/

// =======================================================================
// DUMMY DATA IMPLEMENTATION FOR TESTING
// =======================================================================

class DummyLegalDocumentRemoteDataSourceImpl
    implements LegalDocumentRemoteDataSource {
  DummyLegalDocumentRemoteDataSourceImpl();

  @override
  Future<PaginatedLegalGroupsModel> getLegalDocuments({
    required int page,
    required int pageSize,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Dummy groups/categories
    final dummyGroups = [
      const LegalGroupModel(id: 'cat_01', groupName: 'Employment Law'),
      const LegalGroupModel(id: 'cat_02', groupName: 'Family Law'),
      const LegalGroupModel(id: 'cat_03', groupName: 'Property Law'),
      const LegalGroupModel(id: 'cat_04', groupName: 'Business Law'),
    ];

    return PaginatedLegalGroupsModel(
      items: dummyGroups,
      totalItems: dummyGroups.length,
      totalPages: 1,
      currentPage: 1,
      pageSize: 10,
    );
  }

  @override
  Future<List<LegalContentModel>> getLegalDocumentsByCategoryId({
    required String id,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Dummy contents/articles under a group
    final dummyArticles = [
      const LegalContentModel(
        id: 'art_101',
        groupId: 'cat_01',
        groupName: 'Employment Law',
        name: 'Understanding Your Employment Contract',
        description:
            'Learn about key terms and conditions in employment agreements',
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        language: 'EN',
      ),
      const LegalContentModel(
        id: 'art_102',
        groupId: 'cat_01',
        groupName: 'Employment Law',
        name: 'Overtime Pay and Working Hours',
        description: 'Know your rights regarding working time and compensation',
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        language: 'EN',
      ),
      const LegalContentModel(
        id: 'art_103',
        groupId: 'cat_01',
        groupName: 'Employment Law',
        name: 'Workplace Discrimination and Harassment',
        description:
            'Understanding protection against unfair treatment at work',
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        language: 'EN',
      ),
    ];

    return dummyArticles;
  }
}
