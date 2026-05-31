void main() {
  var today = DateTime.now();
  var todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  var lastStr = '2026-05-28';
  var last = DateTime.tryParse(lastStr)!;
  print("today: $today");
  print("todayStr: $todayStr");
  print("last: $last");
  print("diff: ${today.difference(last).inDays}");
}
