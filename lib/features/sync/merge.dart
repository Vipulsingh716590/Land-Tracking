import 'dart:convert';

import 'package:crypto/crypto.dart';

/// A row as stored on the server.
class RemoteRow {
  const RemoteRow(this.data, this.updatedAt, this.deleted);
  final Map<String, dynamic> data;
  final String updatedAt;
  final bool deleted;
}

/// What the last successful sync left behind for one record.
class BaseEntry {
  const BaseEntry(this.hash, this.remoteUpdatedAt);
  final String hash;
  final String remoteUpdatedAt;

  Map<String, dynamic> toJson() => {'h': hash, 'u': remoteUpdatedAt};
  factory BaseEntry.fromJson(Map<String, dynamic> j) => BaseEntry(j['h'], j['u']);
}

class MergePlan {
  MergePlan(this.result, this.push, this.tombstones, this.remoteStamp);

  /// Records the device should hold after the sync.
  final Map<String, Map<String, dynamic>> result;

  /// Records to upload (new or changed locally).
  final Map<String, Map<String, dynamic>> push;

  /// Ids deleted on this device that must be marked deleted on the server.
  final Set<String> tombstones;

  /// Server timestamp for each kept record that is not being pushed.
  final Map<String, String> remoteStamp;
}

String canonical(Object? v) => jsonEncode(_sorted(v));

Object? _sorted(Object? v) {
  if (v is Map) {
    final keys = v.keys.map((k) => k.toString()).toList()..sort();
    return {for (final k in keys) k: _sorted(v[k])};
  }
  if (v is List) return [for (final e in v) _sorted(e)];
  return v;
}

String hashOf(Map<String, dynamic> data) =>
    sha1.convert(utf8.encode(canonical(data))).toString();

/// Three-way merge of one collection. Rules:
///  * only one side changed → that side wins;
///  * both changed → this device wins (it is the newer action);
///  * a delete beats an unchanged copy, but an edit beats a delete.
MergePlan mergeCollection({
  required Map<String, Map<String, dynamic>> local,
  required Map<String, RemoteRow> remote,
  required Map<String, BaseEntry> base,
}) {
  final result = <String, Map<String, dynamic>>{};
  final push = <String, Map<String, dynamic>>{};
  final tombstones = <String>{};
  final stamp = <String, String>{};

  for (final id in {...local.keys, ...remote.keys, ...base.keys}) {
    final l = local[id], r = remote[id], b = base[id];
    final localChanged = l != null && (b == null || hashOf(l) != b.hash);
    final localDeleted = l == null && b != null;
    final remoteLive = r != null && !r.deleted;
    final remoteChanged = r != null && (b == null || r.updatedAt != b.remoteUpdatedAt);

    if (l != null) {
      if (r == null || (r.deleted && localChanged)) {
        result[id] = l;
        push[id] = l;
      } else if (r.deleted) {
        // unchanged here, deleted elsewhere → follow the delete
      } else if (localChanged) {
        result[id] = l;
        push[id] = l;
      } else if (remoteChanged) {
        result[id] = r.data;
        stamp[id] = r.updatedAt;
      } else {
        result[id] = l;
        stamp[id] = r.updatedAt;
      }
    } else if (remoteLive) {
      if (localDeleted && !remoteChanged) {
        tombstones.add(id);
      } else {
        result[id] = r.data;
        stamp[id] = r.updatedAt;
      }
    }
  }
  return MergePlan(result, push, tombstones, stamp);
}
