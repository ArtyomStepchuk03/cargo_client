Map<String, dynamic> jsonForOperation(String name, List<dynamic> values) {
  return {
    '__op': name,
    'objects': values
  };
}
