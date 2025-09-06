import 'dart:convert'; // Often useful for debug printing
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exception.dart';
import '../models/legal_document_model.dart';
import '../models/paginated_legal_documents_model.dart';

/// The contract for the remote data source remains the same.
abstract class LegalDocumentRemoteDataSource {
  Future<PaginatedLegalDocumentsModel> getLegalDocuments({
    required int page,
    required int pageSize,
  });

  Future<List<LegalDocumentModel>> getLegalDocumentsByCategoryId({
    required String id,
  });
}

/*
// =======================================================================
// ORIGINAL API-CALLING IMPLEMENTATION (COMMENTED OUT FOR DUMMY DATA TESTING)
// =======================================================================

const String _baseUrl =
    'https://lawgen-backend-1.onrender.com/api/v1/legal-entities';
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
    final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjhiOTg4OWZhNzViMGFlMzA3NWZhMDE5Iiwicm9sZSI6ImFkbWluIiwicGxhbiI6ImVudGVycHJpc2UiLCJhZ2UiOjI1LCJnZW5kZXIiOiJtYWxlIiwiZXhwIjoxNzU3MTUyMDAxLCJpYXQiOjE3NTcxNTExMDF9.tLhEOoaVkeoUvGE1pZqIsF0YUNZbGOWS7q4ke_GXhK4";
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
*/

// =======================================================================
// DUMMY DATA IMPLEMENTATION FOR TESTING
// =======================================================================

class DummyLegalDocumentRemoteDataSourceImpl
    implements LegalDocumentRemoteDataSource {
  // You don't need the http client or secure storage for the dummy implementation.
  DummyLegalDocumentRemoteDataSourceImpl();

  @override
  Future<PaginatedLegalDocumentsModel> getLegalDocuments({
    required int page,
    required int pageSize,
  }) async {
    // Simulate a network delay of 1 second
    await Future.delayed(const Duration(seconds: 1));

    //debugPrint("--- DUMMY: Fetching Legal Categories (Page: $page) ---");

    // Dummy data for the categories page (Paginated)
    final dummyCategories = [
      const LegalDocumentModel(
        id: 'cat_01',
        groupName: "Legal Documents",
        name: "Employment Law",
        description: "Rights and responsibilities in the workplace",
        url: "", // Categories don't have a URL
        language: "EN",
      ),
      const LegalDocumentModel(
        id: 'cat_02',
        groupName: "Legal Documents",
        name: "Family Law",
        description: "Marriage, divorce, child custody, and family matters",
        url: "",
        language: "EN",
      ),
      const LegalDocumentModel(
        id: 'cat_03',
        groupName: "Legal Documents",
        name: "Property Law",
        description: "Real estate, rental agreements, and property rights",
        url: "",
        language: "EN",
      ),
      const LegalDocumentModel(
        id: 'cat_04',
        groupName: "Legal Documents",
        name: "Business Law",
        description: "Starting and running a business legally",
        url: "",
        language: "EN",
      ),
    ];

    return PaginatedLegalDocumentsModel(
      items: dummyCategories,
      totalItems: 4,
      totalPages: 1,
      currentPage: 1,
      pageSize: 10,
    );
  }

  @override
  Future<List<LegalDocumentModel>> getLegalDocumentsByCategoryId({
    required String id,
  }) async {
    // Simulate a network delay of 1 second
    await Future.delayed(const Duration(seconds: 1));

    //debugPrint("--- DUMMY: Fetching Articles for Category ID: $id ---");

    // Dummy data for the articles page (List)
    // For simplicity, this returns the same list regardless of the category ID.
    // You could add logic here (e.g., a map) to return different articles for different IDs.
    final dummyArticles = [
      const LegalDocumentModel(
        id: 'art_101',
        groupName: "Employment Law",
        name: "Understanding Your Employment Contract",
        description:
            "Learn about key terms and conditions in employment agreements",
        url:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        language: "EN",
      ),
      const LegalDocumentModel(
        id: 'art_102',
        groupName: "Employment Law",
        name: "Overtime Pay and Working Hours",
        description: "Know your rights regarding working time and compensation",
        url:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        language: "EN",
      ),
      const LegalDocumentModel(
        id: 'art_103',
        groupName: "Employment Law",
        name: "Workplace Discrimination and Harassment",
        description:
            "Understanding protection against unfair treatment at work",
        url:
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        language: "EN",
      ),
    ];

    return dummyArticles;
  }
}
