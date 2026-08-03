import '../models/cross_job_dependency.dart';

/// Read/write dot-separated paths in JSON-like maps.
class FieldPath {
  static dynamic read(Map<String, dynamic> map, String path) {
    final parts = path.split('.');
    dynamic current = map;
    for (final part in parts) {
      if (current is! Map) {
        throw FormatException('Cannot read "$part" in path "$path".');
      }
      current = current[part];
      if (current == null) {
        throw FormatException('Missing "$part" in path "$path".');
      }
    }
    return current;
  }

  static void write(Map<String, dynamic> map, String path, dynamic value) {
    final parts = path.split('.');
    if (parts.length == 1) {
      map[parts.single] = value;
      return;
    }

    dynamic current = map;
    for (var i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      final next = current[part];
      if (next is Map<String, dynamic>) {
        current = next;
        continue;
      }
      if (next == null) {
        final created = <String, dynamic>{};
        if (current is Map<String, dynamic>) {
          current[part] = created;
        }
        current = created;
        continue;
      }
      throw FormatException('Cannot write "$part" in path "$path".');
    }
    if (current is! Map<String, dynamic>) {
      throw FormatException('Cannot write path "$path".');
    }
    current[parts.last] = value;
  }

  static Map<String, dynamic> applyMappings(
    Map<String, dynamic> target,
    Map<String, dynamic> source,
    List<FieldMapping> mappings,
  ) {
    final result = Map<String, dynamic>.from(target);
    for (final mapping in mappings) {
      write(result, mapping.to, read(source, mapping.from));
    }
    return result;
  }
}
