

bool containsSubstring(String mainString, List<String> substrings) {
  for (String substring in substrings) {
    if (mainString.contains(substring)) {
      return true;
    }
  }
  return false;
}