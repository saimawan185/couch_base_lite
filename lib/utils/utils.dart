class Utils {
  static String generateFlagEmojiUnicode(String countryCode) {
    const base = 127397;

    return countryCode.codeUnits
        .map((e) => String.fromCharCode(base + e))
        .toList()
        .reduce((value, element) => value + element)
        .toString();
  }
}
