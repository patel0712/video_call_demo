class UserEntity {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final AddressEntity address;
  final CompanyEntity company;

  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  // Helper methods for backward compatibility
  String get firstName => name.split(' ').first;
  String get lastName => name.split(' ').length > 1 ? name.split(' ').last : '';
  String get avatar =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';
}

class AddressEntity {
  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final GeoEntity geo;

  const AddressEntity({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });
}

class GeoEntity {
  final String lat;
  final String lng;

  const GeoEntity({
    required this.lat,
    required this.lng,
  });
}

class CompanyEntity {
  final String name;
  final String catchPhrase;
  final String bs;

  const CompanyEntity({
    required this.name,
    required this.catchPhrase,
    required this.bs,
  });
}
