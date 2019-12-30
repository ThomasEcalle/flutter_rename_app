class RequiredChange {
  final RegExp regexp;
  final String replacement;
  final List<String> paths;
  final bool isDirectory;

  RequiredChange({
    this.regexp,
    this.replacement,
    this.paths,
    this.isDirectory = false,
  });
}
