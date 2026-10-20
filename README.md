# Ayodhya Zameen (अयोध्या ज़मीन)

Hindi-first Flutter app. Phase 1: foundation + bigha-biswa calculator.

    export PATH=/opt/flutter/bin:$PATH
    flutter pub get && flutter gen-l10n
    flutter test
    flutter run            # needs an Android emulator/device

Unit rules in `lib/features/calculator/data/unit_rules_seed.dart` are DEMO
placeholders. Edit them in the app (calculator → tune icon) or in the seed file.

## Phase 2: map
The map uses OpenStreetMap tiles through `flutter_map`, so no API key is needed.
Tiles come from the public tile.openstreetmap.org server: fine for a personal app, not for heavy use.

Zones load from `assets/geojson/zones_sample.geojson` (DEMO shapes, not the real master plan).

## Phase 3: plots, disputes, lock
- Plots tab: list, filters, favourites, add/edit. Long-press the map to add a plot at that point.
- Dispute tag: red circle on the map; stays on this device behind the PIN.
- Settings: PIN / biometric lock, CSV import (`samples/plots_sample.csv`; `source` is required per row).
- Data is stored on-device for now (see `plots_repository.dart`); Supabase is not wired in yet.

## Phase 4: diary, backup
- Diary tab: date-wise notes, dictation (hi-IN default, en-IN), editable before save, optional link to a plot pin, search by text / date / pin, export to .txt.
- Plot card lists the notes linked to that pin.
- Settings: save a JSON backup of all data and restore it (validated before anything is overwritten).

## Supabase (optional)
1. Create a Supabase project. In the SQL editor run `supabase/schema.sql`.
2. Authentication → Providers → Email. Turn "Allow new users to sign up" off after you and your father have created your accounts if you want a closed app.
3. Run with the project URL and publishable (anon) key — never the service_role key:

       flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
                   --dart-define=SUPABASE_ANON_KEY=sb_publishable_...

Without these defines the app stays local-only. Sync runs after sign-in, when the app goes to
the background, and from Settings → Sync now. DEMO rows are never uploaded.

### Separate accounts, shared data
Each person signs up with their own email and password. The first person creates a
"family space" and becomes its owner; Settings → Family space → Members → Invite member gives a
single-use code (valid 3 days). The second person signs up, enters the code, and both see the same
records. The owner can remove members. Re-run `supabase/schema.sql` to upgrade an existing project:
existing data moves into a family space owned by its previous user.

## Road widening corridor check
A `road_widening` line in the overlay GeoJSON may carry `corridor_width_m` (total width, centred
on the line). Land within half that width is "inside"; within 100 m beyond it is "near". Lines
without a width are never guessed — the plot card says the width is missing.

The same width rule applies to `metro` and `ring_road` lines (`corridor_width_m` on the feature).

### One-sided widening
Instead of `corridor_width_m`, a line can give `corridor_left_m` and/or `corridor_right_m`: metres
taken from the centre line on each side, looking along the line in the order its points are listed
(a missing side counts as 0). They override `corridor_width_m`. The plot card then names the
compass side the plot is on. Check the direction of your line's points when entering data.

### Square corridor ends
Add `"corridor_end": "square"` to a line feature to cut its corridor off flat at the first and last
point. The default, `"round"`, extends the corridor in a rounded cap around those points. Bends in the
middle of a line keep rounded joins. Land beyond a square end is reported as outside, with the
distance measured to the flat end.

### Angled corridor ends
Use `"corridor_end": "angled"` with `corridor_start_angle_deg` and/or `corridor_end_angle_deg`
(−80 to 80, a missing one is 0 = square). The angle turns the cut **anticlockwise from square,
seen from above with north up**. For a line heading north, a positive angle at the far end makes the
east side run further past the last point and the west side stop short of it; at the near end a
positive angle makes the west side start before the first point and the east side start after it.
Angles without `"angled"` are rejected so they are never silently ignored.
Keep each end segment much longer than the corridor reach times tan(angle).

## Real data
- **OpenStreetMap (live API):** the map's "OpenStreetMap" chip downloads real roads, railways and rivers
  around Ayodhya from the public Overpass API and keeps the last download on the phone. Plot forms have a
  "Find on map" button that fills latitude/longitude from Nominatim. © OpenStreetMap contributors, ODbL.
  This is volunteer-mapped data, not an official alignment.
- **No open API exists** for the ADA master plan, IGRSUP circle rates or Bhulekh/Bhunaksha (login/captcha),
  and the app does not scrape them. Read them from the official sites, then use Settings →
  Real data to import zones and overlay GeoJSON, import plots by CSV, and "Remove all DEMO records".

## Data sources (dynamic APIs)
Settings → Data sources (API) lets you add endpoints at run time, with no code change:
- **WMS or XYZ tile layer** (for example a Bhuvan/NRSC OGC layer): drawn on the map, toggled by a chip.
- **GeoJSON URL for zones or for metro/road/acquisition lines**: "Download now" replaces the map's zones or overlays
  after the file parses cleanly.
Every source needs `https://` and a source note. The app ships no endpoint it has not verified; get the exact WMS
URL and layer names from the service's GetCapabilities. Optional header (e.g. `Authorization`) is stored on this
phone only and is excluded from backups and Supabase sync.
Bhulekh and Bhunaksha publish no open API (captcha / web viewer), so they are not scraped. Plot cards copy
district / tehsil / village / khasra to the clipboard and open the official site; NIC Uttar Pradesh is the contact
for an official Bhulekh data API.
