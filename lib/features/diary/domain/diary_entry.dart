class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.date,
    required this.text,
    required this.language,
    this.plotId,
    this.audioRef = '',
  });

  final String id, date, text, language, audioRef; // date: yyyy-MM-dd
  final String? plotId;

  Map<String, dynamic> toJson() => {
        'id': id, 'date': date, 'text': text, 'language': language,
        'plot_id': plotId, 'audio_ref': audioRef,
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> j) => DiaryEntry(
      id: j['id'], date: j['date'], text: j['text'], language: j['language'],
      plotId: j['plot_id'], audioRef: j['audio_ref'] ?? '');
}

class DiaryQuery {
  const DiaryQuery({this.text = '', this.date, this.plotId});
  final String text;
  final String? date, plotId;
}

/// Newest first. Text match is case-insensitive substring.
List<DiaryEntry> searchDiary(List<DiaryEntry> all, DiaryQuery q) {
  final needle = q.text.trim().toLowerCase();
  return [
    for (final e in all)
      if ((needle.isEmpty || e.text.toLowerCase().contains(needle)) &&
          (q.date == null || e.date == q.date) &&
          (q.plotId == null || e.plotId == q.plotId))
        e
  ]..sort((a, b) => b.date.compareTo(a.date));
}

/// Plain-text export, one block per entry. [plotName] maps a plot id to a label.
String exportDiaryText(List<DiaryEntry> entries, String Function(String) plotName) {
  final b = StringBuffer();
  for (final e in searchDiary(entries, const DiaryQuery())) {
    b.writeln(e.date + (e.plotId == null ? '' : '  [${plotName(e.plotId!)}]'));
    b.writeln(e.text);
    b.writeln();
  }
  return b.toString();
}
