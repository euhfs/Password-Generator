/// Checks if adding [nextChar] to [chars] would create a sequence of [length] (default 3).
/// Returns true if a sequence (ascending or descending) is found.
bool containsSequence(List<String> chars, String nextChar, {int length = 3}) {
  if (chars.length < length - 1) return false;
  int start = (chars.length - (length - 2)).clamp(0, chars.length);
  for (int i = start; i <= chars.length - (length - 1); i++) {
    bool isAscending = true;
    bool isDescending = true;
    for (int j = 0; j < length - 1; j++) {
      int prev = chars[i + j].codeUnitAt(0);
      int curr = (j == length - 2)
          ? nextChar.codeUnitAt(0)
          : chars[i + j + 1].codeUnitAt(0);
      if (curr - prev != 1) isAscending = false;
      if (prev - curr != 1) isDescending = false;
    }
    if (isAscending || isDescending) return true;
  }
  return false;
}

/// Removes ambiguous characters (O, 0, l, 1, I) from [input].
String filterAmbiguous(String input) {
  const ambiguous = 'O0l1I';
  return input.split('').where((c) => !ambiguous.contains(c)).join();
}