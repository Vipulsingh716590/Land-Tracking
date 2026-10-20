// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ayodhya Zameen';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Your private record of land in Ayodhya';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get continueBtn => 'Continue';

  @override
  String get home => 'Home';

  @override
  String get calculator => 'Calculator';

  @override
  String get settings => 'Settings';

  @override
  String get map => 'Map';

  @override
  String get plots => 'Plots';

  @override
  String get diary => 'Diary';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get district => 'District';

  @override
  String get value => 'Value';

  @override
  String get fromUnit => 'From unit';

  @override
  String get results => 'Results';

  @override
  String get formula => 'Formula';

  @override
  String get source => 'Source';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get demo => 'DEMO';

  @override
  String get unverified => 'Unverified — please check yourself';

  @override
  String get ratePerUnit => 'Rate (per unit)';

  @override
  String get rateUnit => 'Rate unit';

  @override
  String get totalPrice => 'Total price';

  @override
  String get unitRules => 'Unit rules';

  @override
  String get editRule => 'Edit rule';

  @override
  String get addRule => 'Add rule';

  @override
  String get deleteRule => 'Delete rule';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get biswaPerBigha => 'Biswa per bigha';

  @override
  String get biswansiPerBiswa => 'Biswansi per biswa';

  @override
  String get sqftPerBiswa => 'Sq ft per biswa';

  @override
  String get unitName => 'Bigha type';

  @override
  String get sourceNote => 'Source note';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get unit_bigha => 'Bigha';

  @override
  String get unit_biswa => 'Biswa';

  @override
  String get unit_biswansi => 'Biswansi';

  @override
  String get unit_sqft => 'Sq ft';

  @override
  String get unit_sqyd => 'Sq yard';

  @override
  String get unit_sqm => 'Sq metre';

  @override
  String get unit_acre => 'Acre';

  @override
  String get disclaimer =>
      'Information only, not legal advice. Verify at the tehsil or registry office.';

  @override
  String formulaBigha(String biswa, String sqft, String biswansi) {
    return '1 bigha = $biswa biswa; 1 biswa = $sqft sq ft; 1 biswa = $biswansi biswansi';
  }

  @override
  String get formulaFixed =>
      '1 sq yd = 9 sq ft; 1 sq m = 10.7639 sq ft; 1 acre = 43,560 sq ft';

  @override
  String get formulaTotal => 'Total price = rate × area (in the rate\'s unit)';

  @override
  String get planYear => 'Plan year';

  @override
  String get zoneType => 'Zone type';

  @override
  String get heightLimit => 'Height limit';

  @override
  String get notSet => 'Not set';

  @override
  String get noZoneHere => 'No zone at this point';

  @override
  String get mapLoadError => 'Could not load map';

  @override
  String get required => 'Required';

  @override
  String get addPlot => 'Add plot';

  @override
  String get editPlot => 'Edit plot';

  @override
  String get deletePlot => 'Delete plot';

  @override
  String get location => 'Location';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get khasraNo => 'Khasra no.';

  @override
  String get area => 'Area';

  @override
  String get areaUnit => 'Area unit';

  @override
  String get status => 'Status';

  @override
  String get statusForSale => 'For sale';

  @override
  String get statusHold => 'On hold';

  @override
  String get statusSold => 'Sold';

  @override
  String get riskNote => 'Master-plan risk';

  @override
  String get sourceRequired => 'Source (required)';

  @override
  String get currentOwner => 'Current owner';

  @override
  String get previousOwners => 'Previous owners (comma separated)';

  @override
  String get dealer => 'Dealer';

  @override
  String get dealerPhone => 'Dealer phone';

  @override
  String get disputed => 'Disputed / case pending';

  @override
  String get caseType => 'Case type';

  @override
  String get court => 'Court';

  @override
  String get nextDate => 'Next date';

  @override
  String get casePending => 'Pending';

  @override
  String get caseResolved => 'Resolved';

  @override
  String get note => 'Note';

  @override
  String get favourite => 'Favourite';

  @override
  String get watchlist => 'Watch-list';

  @override
  String get favouritesOnly => 'Favourites only';

  @override
  String get filters => 'Filters';

  @override
  String get areaFilter => 'Area';

  @override
  String get maxBudget => 'Max budget (₹)';

  @override
  String get minSqft => 'Min sq ft';

  @override
  String get maxSqft => 'Max sq ft';

  @override
  String get clear => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get openBhulekh => 'Open Bhulekh';

  @override
  String get openBhunaksha => 'Open Bhunaksha';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importResult => 'Import result';

  @override
  String get imported => 'Added';

  @override
  String get skipped => 'Skipped';

  @override
  String get row => 'Row';

  @override
  String get csvColumnsHint => 'Columns';

  @override
  String get ok => 'OK';

  @override
  String get privateMode => 'Private mode (lock)';

  @override
  String get setPin => 'Set PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get removePin => 'Remove PIN';

  @override
  String get pinHint => '4 to 8 digits';

  @override
  String get useBiometric => 'Use biometrics';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get unlock => 'Unlock';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get newNote => 'New note';

  @override
  String get editNote => 'Edit note';

  @override
  String get noteText => 'Note';

  @override
  String get transcriptEditable =>
      'Spoken words appear here; edit before saving';

  @override
  String get speak => 'Speak';

  @override
  String get stopListening => 'Stop';

  @override
  String get micUnavailable =>
      'Microphone or speech recognition is unavailable; you can type instead';

  @override
  String get linkedPin => 'Linked pin (plot)';

  @override
  String get noPin => 'No pin';

  @override
  String get search => 'Search';

  @override
  String get anyDate => 'Any date';

  @override
  String get allPins => 'All pins';

  @override
  String get noNotes => 'No notes';

  @override
  String get exportDiary => 'Export diary';

  @override
  String get addNoteForPin => 'Add note for this pin';

  @override
  String get backupData => 'Save backup (JSON)';

  @override
  String get restoreData => 'Restore from backup';

  @override
  String get backupSaved => 'File saved';

  @override
  String get restoreDone => 'Data restored';

  @override
  String get restoreFailed => 'Not a valid backup file; nothing was changed';

  @override
  String get layers => 'Layers';

  @override
  String get layerMetro => 'Metro';

  @override
  String get layerRingRoad => 'Ring road';

  @override
  String get layerWidening => 'Road widening';

  @override
  String get layerAcquisition => 'Possible acquisition';

  @override
  String get acquisitionWarning =>
      'This point is inside a possible acquisition area';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get useOffline => 'Use on this phone without an account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get credentialsHint =>
      'Enter an email; password must be at least 6 characters';

  @override
  String get confirmEmail =>
      'Open your email to confirm the account, then sign in';

  @override
  String get account => 'Account and sync';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get neverSynced => 'Not synced yet';

  @override
  String get lastSynced => 'Last synced';

  @override
  String get signOut => 'Sign out';

  @override
  String get offlineMode => 'Currently on this phone only';

  @override
  String get familySpace => 'Family space';

  @override
  String get joinWithCode => 'Join with an invite code';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get join => 'Join';

  @override
  String get orStartNew => 'Or start a new space';

  @override
  String get familyName => 'Space name';

  @override
  String get createFamily => 'Create new space';

  @override
  String get manageMembers => 'Members';

  @override
  String get inviteMember => 'Invite member';

  @override
  String get inviteHelp =>
      'This code works once and for 3 days. They must create their own account, then enter it.';

  @override
  String get copy => 'Copy';

  @override
  String get you => 'you';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleMember => 'Member';

  @override
  String get removeMember => 'Remove member';

  @override
  String get leaveFamily => 'Leave space';

  @override
  String get confirmRemove => 'This person loses access immediately. Continue?';

  @override
  String get confirmLeave =>
      'You will stop seeing this space\'s data. Continue?';

  @override
  String get removedKeepsCopy =>
      'A removed member may still hold a copy already synced to their phone; they will not receive anything new.';

  @override
  String get acquisitionCheck => 'Acquisition check';

  @override
  String get riskNone =>
      'Not in any possible acquisition area (per the data available)';

  @override
  String get riskInside => 'Inside a possible acquisition area';

  @override
  String riskNear(int m) {
    return '$m m from a possible acquisition area';
  }

  @override
  String get corridorWidth => 'Total corridor width';

  @override
  String corridorCheckOf(String layer) {
    return '$layer check';
  }

  @override
  String corridorNoneOf(String layer) {
    return 'not in any $layer corridor (per the data available)';
  }

  @override
  String corridorInsideOf(String layer) {
    return 'Inside a $layer corridor';
  }

  @override
  String corridorNearOf(String layer, int m) {
    return '$m m from a $layer corridor';
  }

  @override
  String corridorWidthUnknownOf(String layer) {
    return 'A $layer route is close but the data gives no corridor width';
  }

  @override
  String get sideNorth => 'north side';

  @override
  String get sideSouth => 'south side';

  @override
  String get sideEast => 'east side';

  @override
  String get sideWest => 'west side';

  @override
  String corridorSides(String left, String right) {
    return 'Corridor: left $left m, right $right m (looking along the line)';
  }

  @override
  String get corridorSquareEnds => 'Corridor ends are cut off square';

  @override
  String corridorAngledEnds(String start, String end) {
    return 'Corridor ends cut at an angle: start $start°, end $end° (anticlockwise, seen from above)';
  }
}
