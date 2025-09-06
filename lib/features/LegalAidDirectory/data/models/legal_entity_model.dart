import '../../domain/entities/legal_entity.dart';

class LegalEntityModel extends LegalEntity {
  const LegalEntityModel({
    required super.id,
    required super.name,
    required super.entityType,
    required super.dateOfEstablishment,
    required super.status,
    required super.phone,
    required super.email,
    required super.website,
    required super.city,
    required super.subCity,
    required super.woreda,
    required super.streetAddress,
    required super.description,
    required super.servicesOffered,
    required super.jurisdiction,
    required super.workingHours,
    required super.contactPerson,
  });

  factory LegalEntityModel.fromJson(Map<String, dynamic> json) {
    return LegalEntityModel(
      id: json['id'],
      name: json['name'],
      entityType: json['entity_type'],
      dateOfEstablishment: json['date_of_establishment'],
      status: json['status'],
      phone: List<String>.from(json['phone']),
      email: List<String>.from(json['email']),
      website: json['website'],
      city: json['city'],
      subCity: json['sub_city'],
      woreda: json['woreda'],
      streetAddress: json['street_address'],
      description: json['description'],
      servicesOffered: List<String>.from(json['services_offered']),
      jurisdiction: json['jurisdiction'],
      workingHours: json['working_hours'],
      contactPerson: json['contact_person'],
    );
  }

  LegalEntity toEntity() {
    return LegalEntity(
      id: id,
      name: name,
      entityType: entityType,
      dateOfEstablishment: dateOfEstablishment,
      status: status,
      phone: phone,
      email: email,
      website: website,
      city: city,
      subCity: subCity,
      woreda: woreda,
      streetAddress: streetAddress,
      description: description,
      servicesOffered: servicesOffered,
      jurisdiction: jurisdiction,
      workingHours: workingHours,
      contactPerson: contactPerson,
    );
  }
}
