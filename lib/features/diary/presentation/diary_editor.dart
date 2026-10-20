import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../plots/data/plots_repository.dart';
import '../data/diary_repository.dart';
import '../domain/diary_entry.dart';

class DiaryEditor extends ConsumerStatefulWidget {
  const DiaryEditor({super.key, this.entry, this.plotId});
  final DiaryEntry? entry;
  final String? plotId;

  @override
  ConsumerState<DiaryEditor> createState() => _DiaryEditorState();
}

class _DiaryEditorState extends ConsumerState<DiaryEditor> {
  final _speech = SpeechToText();
  late final TextEditingController text;
  late String date, lang;
  String? plotId;
  bool listening = false;
  String base = ''; // text already in the box when listening started

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    text = TextEditingController(text: e?.text);
    date = e?.date ?? DateTime.now().toIso8601String().substring(0, 10);
    lang = e?.language ?? 'hi'; // Hindi first
    plotId = e?.plotId ?? widget.plotId;
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final t = AppLocalizations.of(context);
    if (listening) {
      await _speech.stop();
      setState(() => listening = false);
      return;
    }
    final ok = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => listening = false);
      },
    );
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.micUnavailable)));
      }
      return;
    }
    // The transcript only fills the editable box; nothing is saved until Save.
    base = text.text.isEmpty ? '' : '${text.text} ';
    setState(() => listening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(
          localeId: lang == 'hi' ? 'hi_IN' : 'en_IN', partialResults: true),
      onResult: (r) => setState(() {
        text.text = base + r.recognizedWords;
        text.selection = TextSelection.collapsed(offset: text.text.length);
      }),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(date) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => date = d.toIso8601String().substring(0, 10));
  }

  void _save() {
    if (text.text.trim().isEmpty) return;
    ref.read(diaryProvider.notifier).upsert(DiaryEntry(
          id: widget.entry?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
          date: date, text: text.text.trim(), language: lang, plotId: plotId,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final plots = ref.watch(plotsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? t.newNote : t.editNote),
        actions: [TextButton(onPressed: _save, child: Text(t.save))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today), label: Text(date),
              onPressed: _pickDate),
          ),
          const SizedBox(width: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'hi', label: Text('हिन्दी')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {lang},
            onSelectionChanged: (s) => setState(() => lang = s.first),
          ),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: plots.any((p) => p.id == plotId) ? plotId : null,
          isExpanded: true,
          decoration: InputDecoration(labelText: t.linkedPin),
          items: [
            DropdownMenuItem(value: null, child: Text(t.noPin)),
            for (final p in plots) DropdownMenuItem(value: p.id, child: Text(p.location)),
          ],
          onChanged: (v) => setState(() => plotId = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: text, minLines: 6, maxLines: 14,
          decoration: InputDecoration(labelText: t.noteText, helperText: t.transcriptEditable,
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: Icon(listening ? Icons.stop : Icons.mic),
          label: Text(listening ? t.stopListening : t.speak),
          onPressed: _toggleMic,
        ),
      ]),
    );
  }
}
