/// Simple Error in case of bad yaml configuration
class MissingConfiguration extends Error {
  final String message;

  MissingConfiguration(this.message);
}
