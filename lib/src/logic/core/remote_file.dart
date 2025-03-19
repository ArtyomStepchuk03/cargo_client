class RemoteFile {
  String name;
  String url;
  RemoteFile(this.name, this.url);

  @override
  bool operator==(dynamic other) {
    if (other is! RemoteFile) {
      return false;
    }
    final RemoteFile otherFile = other;
    return name == otherFile.name;
  }

  @override
  int get hashCode => name.hashCode;
}
