import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import 'data_source.dart';
import 'data_sources_repository.dart';

String kindLabel(AppLocalizations t, SourceKind k) => switch (k) {
      SourceKind.wms => t.kindWms,
      SourceKind.xyz => t.kindXyz,
      SourceKind.zonesGeojson => t.kindZones,
      SourceKind.overlaysGeojson => t.kindOverlays,
    };

class DataSourcesScreen extends ConsumerWidget {
  const DataSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final sources = ref.watch(dataSourcesProvider);
    final notifier = ref.read(dataSourcesProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(t.dataSources)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: Text(t.addSource),
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(t.dataSourcesHelp)),
        if (sources.isEmpty)
          Padding(padding: const EdgeInsets.all(16), child: Text(t.noSources, style: Theme.of(context).textTheme.bodySmall)),
        for (final s in sources)
          ListTile(
            title: Text(s.name),
            subtitle: Text('${kindLabel(t, s.kind)}\n${s.note}'
                '${s.lastFetched == null ? '' : '\n${t.lastUpdated}: ${s.lastFetched!.substring(0, 16).replaceFirst('T', ' ')} (${s.lastCount})'}'),
            isThreeLine: true,
            onTap: () => _edit(context, ref, s),
            trailing: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (s.isGeojson)
                IconButton(
                  tooltip: t.fetchNow,
                  icon: const Icon(Icons.cloud_download),
                  onPressed: () async {
                    final err = await notifier.fetch(s.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err == null ? t.fetchDone : '${t.fetchFailed}: $err')));
                    }
                  },
                )
              else
                Switch(value: s.enabled, onChanged: (v) => notifier.setEnabled(s.id, v)),
              IconButton(
                tooltip: t.deleteRule,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => notifier.remove(s.id),
              ),
            ]),
          ),
      ]),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, DataSource? s) async {
    final t = AppLocalizations.of(context);
    final name = TextEditingController(text: s?.name);
    final url = TextEditingController(text: s?.url);
    final layers = TextEditingController(text: s?.layers);
    final hName = TextEditingController(text: s?.headerName);
    final hValue = TextEditingController(text: s?.headerValue);
    final note = TextEditingController(text: s?.note);
    var kind = s?.kind ?? SourceKind.wms;
    String? error;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(s == null ? t.addSource : t.editRule),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<SourceKind>(
                initialValue: kind,
                decoration: InputDecoration(labelText: t.sourceType),
                items: [for (final k in SourceKind.values) DropdownMenuItem(value: k, child: Text(kindLabel(t, k)))],
                onChanged: (k) => setS(() => kind = k!),
              ),
              TextField(controller: name, decoration: InputDecoration(labelText: t.unitName)),
              TextField(
                controller: url,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: kind == SourceKind.xyz ? t.tileUrl : t.endpointUrl),
              ),
              if (kind == SourceKind.wms)
                TextField(controller: layers, decoration: InputDecoration(labelText: t.wmsLayers)),
              TextField(controller: hName, decoration: InputDecoration(labelText: t.headerName)),
              TextField(controller: hValue, obscureText: true, decoration: InputDecoration(labelText: t.headerValue)),
              TextField(controller: note, decoration: InputDecoration(labelText: t.sourceNote)),
              if (error != null)
                Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
            FilledButton(
              onPressed: () {
                final e = validateSource(
                    name: name.text, note: note.text, url: url.text, kind: kind, layers: layers.text);
                if (e == null) {
                  Navigator.pop(ctx, true);
                } else {
                  setS(() => error = switch (e) {
                        'name' => t.required,
                        'note' => t.sourceRequired,
                        'https' => t.needHttps,
                        'layers' => t.wmsLayers,
                        'template' => t.needTemplate,
                        _ => t.invalidUrl,
                      });
                }
              },
              child: Text(t.save),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    ref.read(dataSourcesProvider.notifier).upsert(DataSource(
          id: s?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
          name: name.text.trim(), kind: kind, url: url.text.trim(), layers: layers.text.trim(),
          headerName: hName.text.trim(), headerValue: hValue.text, note: note.text.trim(),
          enabled: s?.enabled ?? true, lastFetched: s?.lastFetched, lastCount: s?.lastCount,
        ));
  }
}
