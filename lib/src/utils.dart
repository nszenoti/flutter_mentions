/// Check if {s} is empty or null
bool isEmptyOrNull(String? s) {
  return s == null || s.isEmpty;
}

/// Check if {s} is comprised of only whitespaces or not
bool isWhiteSpace(String s) {
  return s.trim() == '';
}

/// Detect the Trailing Trigger Query
/// returns start index of detected query
int identify_trailing_query(String txt, RegExp trgr) {
  //* Better Approach (Using Builtin Functions)
  var idx = txt.lastIndexOf(trgr);

  if (idx == -1) return -1;

  // Check for whitespace in front
  if (idx - 1 >= 0) {
    var char = txt[idx - 1];
    return isWhiteSpace(char) ? idx : -1;
  }

  return idx;
}

/// Detect the Trailing Trigger Query
int identify_trailing_query1(String txt, String trgr) {
  //! May be Slower due to solely Regex Approach

  //var re = RegExp('(?<=(^| ))($_triggerPattern)([a-z0-9A-Z]* ?)+\$');
  // var re = RegExp('(?<=(^| ))($_triggerPattern)[a-z0-9A-Z ]*\$');
  var re = RegExp('(?<=(^| ))($trgr)[a-z0-9A-Z ]*\$');
  var m = re.firstMatch(txt);
  return m?.start ?? -1;
}
