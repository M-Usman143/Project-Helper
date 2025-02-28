import 'package:flutter/material.dart';

class ProductModel {
  final String name;
  final String imageUrl;
  final String description;
  final String phoneNumber;
  final String houseNumber;
  final String streetNumber;
  final String impAreaLocation;
  final String city;
  final String country;
  final String uploadDate;
        bool isFavorite;

  ProductModel({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.phoneNumber,
    required this.houseNumber,
    required this.streetNumber,
    required this.impAreaLocation,
    required this.city,
    required this.country,
    required this.uploadDate,
    this.isFavorite = false,
  });
}
