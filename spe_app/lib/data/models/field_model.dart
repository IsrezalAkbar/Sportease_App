import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String fieldId;
  final String ownerId;
  final String name;
  final String locationName;
  final GeoPoint locationLatLng;
  final String description;
  final List<String> facilityList;
  final List<String> photos;
  final int pricePerHour;
  final bool isApproved;

  FieldModel({
    required this.fieldId,
    required this.ownerId,
    required this.name,
    required this.locationName,
    required this.locationLatLng,
    required this.description,
    required this.facilityList,
    required this.photos,
    required this.pricePerHour,
    required this.isApproved,
  });

  Map<String, dynamic> toMap() => {
    "fieldId": fieldId,
    "ownerId": ownerId,
    "name": name,
    "locationName": locationName,
    "locationLatLng": locationLatLng,
    "description": description,
    "facilityList": facilityList,
    "photos": photos,
    "pricePerHour": pricePerHour,
    "isApproved": isApproved,
  };

  factory FieldModel.fromMap(Map<String, dynamic> map) => FieldModel(
    fieldId: map["fieldId"],
    ownerId: map["ownerId"],
    name: map["name"],
    locationName: map["locationName"],
    locationLatLng: map["locationLatLng"],
    description: map["description"],
    facilityList: List<String>.from(map["facilityList"]),
    photos: List<String>.from(map["photos"]),
    pricePerHour: map["pricePerHour"],
    isApproved: map["isApproved"],
  );
}
