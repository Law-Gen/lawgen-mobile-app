import 'package:equatable/equatable.dart';

class LegalEntity extends Equatable {
  final String id;
  final String name;
  final String entityType;
  final String dateOfEstablishment;
  final String status;
  final List<String> phone;
  final List<String> email;
  final String website;
  final String city;
  final String subCity;
  final String woreda;
  final String streetAddress;
  final String description;
  final List<String> servicesOffered;
  final String jurisdiction;
  final String workingHours;
  final String contactPerson;

  const LegalEntity({
    required this.id,
    required this.name,
    required this.entityType,
    required this.dateOfEstablishment,
    required this.status,
    required this.phone,
    required this.email,
    required this.website,
    required this.city,
    required this.subCity,
    required this.woreda,
    required this.streetAddress,
    required this.description,
    required this.servicesOffered,
    required this.jurisdiction,
    required this.workingHours,
    required this.contactPerson,
  });

  @override
  List<Object?> get props => [id, name, city, entityType];
}
