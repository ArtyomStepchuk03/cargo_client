class Contact {
  final String? name;
  final String? phoneNumber;

  Contact({this.name, this.phoneNumber});

  static const className = 'Contact';

  static Contact? decode(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    final name = data['name'];
    final phoneNumber = data['phoneNumber'];
    if (name == null && phoneNumber == null) {
      return null;
    }
    return Contact(name: name, phoneNumber: phoneNumber);
  }

  Map<String, dynamic> encode() {
    return {
      if (name != null) 'name': name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Contact) {
      return false;
    }
    final Contact otherContact = other;
    return name == otherContact.name && phoneNumber == otherContact.phoneNumber;
  }

  @override
  int get hashCode => Object.hash(name, phoneNumber);
}
