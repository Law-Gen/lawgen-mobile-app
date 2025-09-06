import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exception.dart'; // Assuming you have this
import '../models/paginated_legal_entities_model.dart';
import '../models/legal_entity_model.dart'; // Import the model for dummy data

/// The contract for the remote data source remains the same.
abstract class LegalAidRemoteDataSource {
  Future<PaginatedLegalEntitiesModel> getLegalEntities({
    required int page,
    required int pageSize,
  });
}

/*
// =======================================================================
// ORIGINAL API-CALLING IMPLEMENTATION (COMMENTED OUT FOR DUMMY DATA TESTING)
// =======================================================================

// NOTE: Using localhost for development. For a real device,
// you must use your computer's IP address (e.g., http://192.168.1.10:8080).
const String _baseUrl = 'http://localhost:8080/api/v1';

class LegalAidRemoteDataSourceImpl implements LegalAidRemoteDataSource {
  final http.Client client;

  LegalAidRemoteDataSourceImpl({required this.client});

  @override
  Future<PaginatedLegalEntitiesModel> getLegalEntities({
    required int page,
    required int pageSize,
  }) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/legal-entities?page=$page&pageSize=$pageSize'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PaginatedLegalEntitiesModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
*/

// =======================================================================
// DUMMY DATA IMPLEMENTATION FOR TESTING
// =======================================================================

class DummyLegalAidRemoteDataSourceImpl implements LegalAidRemoteDataSource {
  // You don't need the http client for the dummy implementation.
  DummyLegalAidRemoteDataSourceImpl();

  @override
  Future<PaginatedLegalEntitiesModel> getLegalEntities({
    required int page,
    required int pageSize,
  }) async {
    // Simulate a network delay to mimic real-world loading.
    await Future.delayed(const Duration(seconds: 1));

    debugPrint("--- DUMMY: Fetching Legal Aid Directory (Page: $page) ---");

    // Dummy data that matches your UI design and API structure.
    final dummyItems = [
      const LegalEntityModel(
        id: '68ba9a882d24e95ce47134bc',
        name: 'Ethiopian Legal Aid Center',
        entityType: 'LEGAL_AID_ORGANIZATION', // Matches "Legal Aid" filter
        dateOfEstablishment: '2010-01-20',
        status: 'ACTIVE',
        phone: ['+251-11-123-4567'],
        email: ['info@elac.org.et'],
        website: 'https://www.elac.org.et',
        city: 'Addis Ababa',
        subCity: 'Arada',
        woreda: '01',
        streetAddress: 'Churchill Road, House 456',
        description:
            'Providing free legal assistance to low-income individuals and families across Ethiopia.',
        servicesOffered: ['Family Law', 'Employment Rights', 'Housing'],
        jurisdiction: 'Federal',
        workingHours: 'Mon-Fri 09:00-17:00',
        contactPerson: 'Abebe Kebede',
      ),
      const LegalEntityModel(
        id: '68ba9a882d24e95ce47134bd',
        name: 'Addis Legal Services',
        entityType: 'PRIVATE_LAW_FIRM', // Matches "Law Firm" filter
        dateOfEstablishment: '2005-03-15',
        status: 'ACTIVE',
        phone: ['+251-11-234-5678'],
        email: ['contact@addislegal.com'],
        website: 'https://www.addislegal.com',
        city: 'Addis Ababa',
        subCity: 'Bole',
        woreda: '03',
        streetAddress: 'Kebele 01, House 12',
        description:
            'Full-service law firm specializing in business and commercial law matters.',
        servicesOffered: [
          'Business Law',
          'Contract Review',
          'Intellectual Property',
        ],
        jurisdiction: 'Federal',
        workingHours: 'Mon-Fri 08:00-17:00',
        contactPerson: 'John Doe',
      ),
      const LegalEntityModel(
        id: '68ba9a882d24e95ce47134be',
        name: 'Pro Bono Advocates Ethiopia',
        entityType: 'PRO_BONO_SERVICE', // Matches "Pro Bono" filter
        dateOfEstablishment: '2018-07-01',
        status: 'ACTIVE',
        phone: ['+251-11-345-6789'],
        email: ['volunteer@probonoethiopia.org'],
        website: 'https://www.probonoethiopia.org',
        city: 'Addis Ababa',
        subCity: 'Kirkos',
        woreda: '05',
        streetAddress: 'Meskel Flower Area, Office 303',
        description:
            'Connecting volunteer lawyers with those who cannot afford legal services, focusing on human rights.',
        servicesOffered: [
          'Human Rights',
          'Asylum Claims',
          'Public Interest Litigation',
        ],
        jurisdiction: 'Federal',
        workingHours: 'By Appointment',
        contactPerson: 'Jane Smith',
      ),
      const LegalEntityModel(
        id: '68ba9a882d24e95ce47134bf',
        name: 'Ministry of Justice - Public Defense Office',
        entityType: 'GOVERNMENT_ENTITY', // Matches "Government" filter
        dateOfEstablishment: '1995-08-21',
        status: 'ACTIVE',
        phone: ['+251-11-555-0000'],
        email: ['info@moj.gov.et'],
        website: 'https://www.moj.gov.et',
        city: 'Addis Ababa',
        subCity: 'Lideta',
        woreda: '02',
        streetAddress: 'Government District, Block C',
        description:
            'Official government body providing legal defense to eligible citizens in criminal cases.',
        servicesOffered: ['Public Defense', 'Criminal Law', 'Appeals'],
        jurisdiction: 'Federal and Regional',
        workingHours: 'Mon-Fri 08:30-17:30',
        contactPerson: 'Public Affairs Office',
      ),
    ];

    return PaginatedLegalEntitiesModel(
      items: dummyItems,
      totalItems: dummyItems.length,
      totalPages: 1,
      currentPage: 1,
      pageSize: 10,
    );
  }
}
