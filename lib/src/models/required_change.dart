/// This class represent a Required Change
/// [regexp] is what we are looking for
/// [replacement] is the String we want to replace [regexp] with
/// [paths] is the list of affected paths
/// [isDirectory] is used in order to do the changes recursively in the directory
/// [needChanges] is the condition that must be fulfill in order to proceed the changes
class RequiredChange {
  final RegExp regexp;
  final String replacement;
  final List<String> paths;
  final bool isDirectory;
  final bool needChanges;

  RequiredChange({
    required this.regexp,
    required this.replacement,
    required this.paths,
    this.isDirectory = false,
    this.needChanges = true,
  });
}
