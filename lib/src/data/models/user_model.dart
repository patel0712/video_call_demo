import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final Address address;
  final Company company;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Helper methods for backward compatibility
  String get firstName => name.split(' ').first;
  String get lastName => name.split(' ').length > 1 ? name.split(' ').last : '';
  String get avatar =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';
}

@JsonSerializable()
class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

@JsonSerializable()
class Geo {
  const Geo({
    required this.lat,
    required this.lng,
  });

  factory Geo.fromJson(Map<String, dynamic> json) => _$GeoFromJson(json);

  final String lat;
  final String lng;

  Map<String, dynamic> toJson() => _$GeoToJson(this);
}

@JsonSerializable()
class Company {
  const Company({
    required this.name,
    required this.catchPhrase,
    required this.bs,
  });

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  final String name;
  @JsonKey(name: 'catchPhrase')
  final String catchPhrase;
  final String bs;

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}

// Keep the old response structure for backward compatibility
@JsonSerializable()
class UsersResponse {
  const UsersResponse({
    required this.data,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) =>
      _$UsersResponseFromJson(json);

  final List<UserModel> data;

  Map<String, dynamic> toJson() => _$UsersResponseToJson(this);
}
