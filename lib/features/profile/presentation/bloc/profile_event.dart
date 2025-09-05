import 'dart:io';
import '../../domain/entities/profile.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class SaveProfile extends ProfileEvent {
  final Profile profile;
  final File? imageFile; // Add the image file here
  SaveProfile(this.profile, this.imageFile);
}
