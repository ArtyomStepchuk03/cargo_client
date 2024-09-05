import 'package:http/http.dart' as http;
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/http_utility/status_code.dart'
    as http_utility;

class Server {
  final String baseUrl;
  final Map<String, String> baseHeaders;

  Server(this.baseUrl, this.baseHeaders);

  void addHeader(String name, String value) => baseHeaders[name] = value;
  void removeHeader(String name) => baseHeaders.remove(name);

  Future<dynamic> performGet(String relativeUrl,
      {Map<String, String> headers}) async {
    final response = await http.get(Uri.parse(baseUrl + relativeUrl),
        headers: _getHeaders(null, headers));
    if (http_utility.isServerError(response.statusCode)) {
      throw ConnectionErrorException();
    }
    if (response.statusCode == http_utility.statusCodeNotFound) {
      return null;
    }
    if (http_utility.isClientError(response.statusCode)) {
      throw RequestFailedException();
    }
    if (response.statusCode != http_utility.statusCodeOk) {
      throw InvalidResponseException();
    }
    return response.body;
  }

  Future<dynamic> performPost(String relativeUrl,
      {dynamic body, String contentType, Map<String, String> headers}) async {
    final response = await http.post(Uri.parse(baseUrl + relativeUrl),
        headers: _getHeaders(contentType, headers), body: body);
    if (http_utility.isServerError(response.statusCode)) {
      throw ConnectionErrorException();
    }
    if (http_utility.isClientError(response.statusCode)) {
      throw RequestFailedException();
    }
    if (response.statusCode != http_utility.statusCodeOk &&
        response.statusCode != http_utility.statusCodeCreated) {
      throw InvalidResponseException();
    }
    return response.body;
  }

  Future<void> performPut(String relativeUrl,
      {dynamic body, String contentType, Map<String, String> headers}) async {
    final response = await http.put(Uri.parse(baseUrl + relativeUrl),
        headers: _getHeaders(contentType, headers), body: body);
    if (http_utility.isServerError(response.statusCode)) {
      throw ConnectionErrorException();
    }
    if (http_utility.isClientError(response.statusCode)) {
      throw RequestFailedException();
    }
    if (response.statusCode != http_utility.statusCodeOk) {
      throw InvalidResponseException();
    }
  }

  Future<void> performDelete(String relativeUrl,
      {Map<String, String> headers}) async {
    final response = await http.delete(Uri.parse(baseUrl + relativeUrl),
        headers: _getHeaders(null, headers));
    if (http_utility.isServerError(response.statusCode)) {
      throw ConnectionErrorException();
    }
    if (http_utility.isClientError(response.statusCode)) {
      throw RequestFailedException();
    }
    if (response.statusCode != http_utility.statusCodeOk) {
      throw InvalidResponseException();
    }
  }

  Map<String, String> _getHeaders(
      String contentType, Map<String, String> additionalHeaders) {
    if (contentType == null && additionalHeaders == null) {
      return baseHeaders;
    }
    final headers = Map<String, String>.from(baseHeaders);
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }
}
