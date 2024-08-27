
import 'package:url_launcher/url_launcher.dart' as url_launcher;

Future<void> callPhoneNumber(String phoneNumber) async {
  if (phoneNumber == null) {
    return;
  }
  final url = _urlFromPhoneNumber(phoneNumber);
  if (!await url_launcher.canLaunchUrl(url)) {
    return;
  }
  await url_launcher.launchUrl(url);
}

Uri _urlFromPhoneNumber(String phoneNumber) {
  final strippedPhoneNumber = _stripPhoneNumber(phoneNumber);
  return Uri(scheme: 'tel', path: strippedPhoneNumber);
}

String _stripPhoneNumber(String phoneNumber) {
  return phoneNumber.replaceAll(RegExp(r'[\s()-]'), '');
}
