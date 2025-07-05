
///  "kendy" → ["k", "ke", "ken", "kend", "kendy"]

List<String> buildSearchKeywords(String input) {
  input = input.toLowerCase().trim();
  final keywords = <String>[];
  for (var i = 1; i <= input.length; i++) {
    keywords.add(input.substring(0, i));
  }
  return keywords;
}
