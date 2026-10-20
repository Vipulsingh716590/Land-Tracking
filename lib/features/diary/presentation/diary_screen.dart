import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../plots/data/plots_repository.dart';
import '../data/diary_repository.dart';
import '../domain/diary_entry.dart';
import '../../backup/backup_service.dart';
import 'diary_editor.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final q = ref.watch(diaryQueryProvider);
    final plots = ref.watch(plotsProvider);
    final entries = searchDiary(ref.watch(diaryProvider), q);
    String plotName(String id) => plots.where((p) => p.id == id).firstOrNull?.location ?? '—';
    void setQ(DiaryQuery n) => ref.read(diaryQueryProvider.notifier).set(n);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: t.newNote,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryEditor())),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            decoration: InputDecoration(
                hintText: t.search, prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: t.exportDiary, icon: const Icon(Icons.ios_share),
                  onPressed: () => exportDiary(context, ref)),
            ),
            onChanged: (v) => setQ(DiaryQuery(text: v, date: q.date, plotId: q.plotId)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            ActionChip(
              avatar: const Icon(Icons.calendar_today, size: 16),
              label: Text(q.date ?? t.anyDate),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context, initialDate: DateTime.now(),
                  firstDate: DateTime(2000), lastDate: DateTime(2100));
                setQ(DiaryQuery(text: q.text, date: d?.toIso8601String().substring(0, 10), plotId: q.plotId));
              },
            ),
            if (q.date != null)
              IconButton(icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setQ(DiaryQuery(text: q.text, plotId: q.plotId))),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String?>(
                value: plots.any((p) => p.id == q.plotId) ? q.plotId : null,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: null, child: Text(t.allPins)),
                  for (final p in plots) DropdownMenuItem(value: p.id, child: Text(p.location, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setQ(DiaryQuery(text: q.text, date: q.date, plotId: v)),
              ),
            ),
          ]),
        ),
        Expanded(
          child: entries.isEmpty
              ? Center(child: Text(t.noNotes))
              : ListView(children: [
                  for (final e in entries)
                    Dismissible(
                      key: ValueKey(e.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red, alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) => ref.read(diaryProvider.notifier).remove(e.id),
                      child: ListTile(
                        title: Text(e.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${e.date}${e.plotId == null ? '' : ' · ${plotName(e.plotId!)}'}'),
                        leading: Icon(e.plotId == null ? Icons.notes : Icons.place),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryEditor(entry: e))),
                      ),
                    ),
                ]),
        ),
      ]),
    );
  }
}
