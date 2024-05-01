class ConversionUtils {
  static int stringToInt(String str) {
    return int.tryParse(str) ?? 0;
  }

  static double stringToDouble(String str) {
    return double.tryParse(str) ?? 0.0;
  }
}
