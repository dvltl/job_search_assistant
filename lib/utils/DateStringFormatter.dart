class DateStringFormatter {
  static String getDateAsString(DateTime date) {
    String year, month, day;
    year = date.year.toString();
    month = _fixedLengthStringFromInt(date.month);
    day = _fixedLengthStringFromInt(date.day);
    return '$day.$month.$year';
  }

  static String _fixedLengthStringFromInt(int number) {
    if (number < 10) {
      return '0' + number.toString();
    } else {
      return number.toString();
    }
  }
}
