class RequiredChange {
  final RegExp regexp;
  final String replacement;
  final List<String> paths;

  RequiredChange({
    this.regexp,
    this.replacement,
    this.paths,
  });
}
