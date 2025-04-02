import 'dart:convert';

import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

import 'constants.dart';
import 'objects/objects.dart';
import 'server.dart';
import 'url_requests.dart' as url_requests;
import 'urls.dart';

export 'server.dart';

class QueryBuilder {
  QueryBuilder(String className)
      : this._internal(getClassRelativeUrl(className), className);
  QueryBuilder.users() : this._internal(userRelativeUrl, userClassName);

  void equalTo(String key, dynamic value) => _equalTo(key, value);
  void equalToObject(String key, String className, String? id) =>
      _equalTo(key, jsonForPointer(className, id));

  void equalToUserObject(String key, String? id) =>
      equalToObject(key, userClassName, id);

  void lessThan(String key, num value) => _addConstraint(key, '\$lt', value);
  void lessThanOrEqualTo(String key, num value) =>
      _addConstraint(key, '\$lte', value);
  void greaterThan(String key, num value) => _addConstraint(key, '\$gt', value);
  void greaterThanOrEqualTo(String key, num value) =>
      _addConstraint(key, '\$gte', value);

  void lessThanDate(String key, DateTime value) =>
      _addConstraint(key, '\$lt', jsonFromDate(value));
  void lessThanOrEqualToDate(String key, DateTime value) =>
      _addConstraint(key, '\$lte', jsonFromDate(value));
  void greaterThanDate(String key, DateTime value) =>
      _addConstraint(key, '\$gt', jsonFromDate(value));
  void greaterThanOrEqualToDate(String key, DateTime value) =>
      _addConstraint(key, '\$gte', jsonFromDate(value));

  void containedIn(String key, List<dynamic> values) =>
      _addConstraint(key, '\$in', values);
  void notContainedIn(String key, List<dynamic> values) =>
      _addConstraint(key, '\$nin', values);

  void exists(String key) => _exists(key, true);
  void doesNotExist(String key) => _exists(key, false);

  void matchesQuery(String key, QueryBuilder other) => _addConstraint(
      key, '\$inQuery', {'where': other._where, 'className': other._className});

  void relatedTo(String className, String id, String key) {
    _where['\$relatedTo'] = {
      'object': jsonForPointer(className, id),
      'key': key,
    };
  }

  void skip(int? skip) => _skip = skip;
  void limit(int? limit) => _limit = limit;

  void addAscending(String key) => _order.add(key);
  void addDescending(String key) => _order.add('-$key');

  void include(String key) => _include.add(key);
  void includeAll(List<String> keys) => _include.addAll(keys);

  Future<List<Map<String, dynamic>>> find(Server server) async {
    String? encodedWhere = _where.isNotEmpty ? json.encode(_where) : null;
    final results = await url_requests.find(
      server,
      _relativeUrl,
      where: encodedWhere,
      include: _include,
      skip: _skip,
      limit: _limit,
      order: _order,
    );
    if (!results.every((result) => result is Map<String, dynamic>)) {
      throw InvalidResponseException();
    }
    return results.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> findFirst(Server server) async {
    String? encodedWhere = _where.isNotEmpty ? json.encode(_where) : null;
    final results = await url_requests.find(
      server,
      _relativeUrl,
      where: encodedWhere,
      include: _include,
      skip: _skip,
      limit: 1,
      order: _order,
    );
    if (results.length == 0) {
      return null;
    }
    final result = results[0];
    if (result is! Map<String, dynamic>) {
      throw InvalidResponseException();
    }
    return result;
  }

  Future<int> count(Server server) async {
    String? encodedWhere = _where.isNotEmpty ? json.encode(_where) : null;
    return await url_requests.count(
      server,
      _relativeUrl,
      where: encodedWhere,
    );
  }

  Future<List<Map<String, dynamic>>> findAll(Server server) async {
    const portionSize = 1000;
    final results = <Map<String, dynamic>>[];
    limit(portionSize);
    while (true) {
      skip(results.length);
      final portion = await find(server);
      results.addAll(portion);
      if (portion.length != portionSize) {
        break;
      }
    }
    return results;
  }

  String get className => _className;
  Map<String, dynamic> get where => _where;

  String _relativeUrl;
  String _className;

  Map<String, dynamic> _where;
  List<String> _include;
  int? _skip;
  int? _limit;
  List<String> _order;

  QueryBuilder._internal(this._relativeUrl, this._className)
      : _where = {},
        _include = [],
        _skip = 0,
        _limit = 100,
        _order = [];

  void _equalTo(String key, dynamic value) => _where[key] = value;

  void _exists(String key, bool value) =>
      _addConstraint(key, '\$exists', value);

  void _addConstraint(
      String key, String constraintKey, dynamic constraintValue) {
    var constraints = _where[key];
    if (constraints == null) {
      constraints = <String, dynamic>{};
      _where[key] = constraints;
    }
    constraints[constraintKey] = constraintValue;
  }
}
