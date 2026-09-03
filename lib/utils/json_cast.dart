class JsonCast {
  static int? asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static int intOr(dynamic value, [int fallback = 0]) => asInt(value) ?? fallback;

  static List<int> asIntList(dynamic value) {
    if (value is! List) return const [];
    return value.map(asInt).whereType<int>().toList();
  }
}
