class ContactModel {
  String? name;
  String countryCode;
  String countryFlag;
  String phone;

  ContactModel({
    this.name,
    required this.countryCode,
    required this.countryFlag,
    required this.phone,
  });
}
