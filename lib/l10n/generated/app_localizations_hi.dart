// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'अयोध्या ज़मीन';

  @override
  String get welcomeTitle => 'स्वागत है';

  @override
  String get welcomeSubtitle => 'अयोध्या की ज़मीन का आपका निजी हिसाब-किताब';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get continueBtn => 'आगे बढ़ें';

  @override
  String get home => 'होम';

  @override
  String get calculator => 'कैलकुलेटर';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get map => 'नक्शा';

  @override
  String get plots => 'प्लॉट';

  @override
  String get diary => 'डायरी';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get language => 'भाषा';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get district => 'ज़िला';

  @override
  String get value => 'मान';

  @override
  String get fromUnit => 'इस इकाई से';

  @override
  String get results => 'परिणाम';

  @override
  String get formula => 'सूत्र';

  @override
  String get source => 'स्रोत';

  @override
  String get lastUpdated => 'आख़िरी अपडेट';

  @override
  String get demo => 'डेमो';

  @override
  String get unverified => 'अपुष्ट — कृपया खुद जाँचें';

  @override
  String get ratePerUnit => 'दर (प्रति इकाई)';

  @override
  String get rateUnit => 'दर की इकाई';

  @override
  String get totalPrice => 'कुल कीमत';

  @override
  String get unitRules => 'इकाई नियम';

  @override
  String get editRule => 'नियम बदलें';

  @override
  String get addRule => 'नियम जोड़ें';

  @override
  String get deleteRule => 'नियम हटाएँ';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get biswaPerBigha => 'बीघा में बिस्वा';

  @override
  String get biswansiPerBiswa => 'बिस्वा में बिस्वांसी';

  @override
  String get sqftPerBiswa => 'एक बिस्वा में वर्ग फुट';

  @override
  String get unitName => 'बीघा का प्रकार';

  @override
  String get sourceNote => 'स्रोत टिप्पणी';

  @override
  String get invalidNumber => 'सही संख्या लिखें';

  @override
  String get unit_bigha => 'बीघा';

  @override
  String get unit_biswa => 'बिस्वा';

  @override
  String get unit_biswansi => 'बिस्वांसी';

  @override
  String get unit_sqft => 'वर्ग फुट';

  @override
  String get unit_sqyd => 'वर्ग गज';

  @override
  String get unit_sqm => 'वर्ग मीटर';

  @override
  String get unit_acre => 'एकड़';

  @override
  String get disclaimer =>
      'केवल जानकारी के लिए, कानूनी सलाह नहीं। तहसील या रजिस्ट्री कार्यालय में सत्यापित करें।';

  @override
  String formulaBigha(String biswa, String sqft, String biswansi) {
    return '1 बीघा = $biswa बिस्वा; 1 बिस्वा = $sqft वर्ग फुट; 1 बिस्वा = $biswansi बिस्वांसी';
  }

  @override
  String get formulaFixed =>
      '1 वर्ग गज = 9 वर्ग फुट; 1 वर्ग मीटर = 10.7639 वर्ग फुट; 1 एकड़ = 43,560 वर्ग फुट';

  @override
  String get formulaTotal => 'कुल कीमत = दर × क्षेत्रफल (दर की इकाई में)';

  @override
  String get planYear => 'योजना वर्ष';

  @override
  String get zoneType => 'क्षेत्र का प्रकार';

  @override
  String get heightLimit => 'ऊँचाई सीमा';

  @override
  String get notSet => 'तय नहीं';

  @override
  String get noZoneHere => 'इस बिंदु पर कोई क्षेत्र नहीं';

  @override
  String get mapLoadError => 'नक्शा लोड नहीं हुआ';

  @override
  String get required => 'ज़रूरी';

  @override
  String get addPlot => 'प्लॉट जोड़ें';

  @override
  String get editPlot => 'प्लॉट बदलें';

  @override
  String get deletePlot => 'प्लॉट हटाएँ';

  @override
  String get location => 'स्थान';

  @override
  String get latitude => 'अक्षांश (lat)';

  @override
  String get longitude => 'देशांतर (lng)';

  @override
  String get khasraNo => 'खसरा नं.';

  @override
  String get area => 'क्षेत्रफल';

  @override
  String get areaUnit => 'क्षेत्रफल की इकाई';

  @override
  String get status => 'स्थिति';

  @override
  String get statusForSale => 'बिक्री के लिए';

  @override
  String get statusHold => 'रुका हुआ';

  @override
  String get statusSold => 'बिक चुका';

  @override
  String get riskNote => 'मास्टर प्लान जोखिम';

  @override
  String get sourceRequired => 'स्रोत (ज़रूरी)';

  @override
  String get currentOwner => 'वर्तमान मालिक';

  @override
  String get previousOwners => 'पिछले मालिक (कॉमा से अलग)';

  @override
  String get dealer => 'डीलर';

  @override
  String get dealerPhone => 'डीलर का फ़ोन';

  @override
  String get disputed => 'विवादित / केस लंबित';

  @override
  String get caseType => 'केस का प्रकार';

  @override
  String get court => 'न्यायालय';

  @override
  String get nextDate => 'अगली तारीख';

  @override
  String get casePending => 'लंबित';

  @override
  String get caseResolved => 'निपटा हुआ';

  @override
  String get note => 'टिप्पणी';

  @override
  String get favourite => 'पसंदीदा';

  @override
  String get watchlist => 'वॉच-लिस्ट';

  @override
  String get favouritesOnly => 'केवल पसंदीदा';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get areaFilter => 'इलाका';

  @override
  String get maxBudget => 'अधिकतम बजट (₹)';

  @override
  String get minSqft => 'न्यूनतम वर्ग फुट';

  @override
  String get maxSqft => 'अधिकतम वर्ग फुट';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get openBhulekh => 'भूलेख खोलें';

  @override
  String get openBhunaksha => 'भूनक्शा खोलें';

  @override
  String get importCsv => 'CSV आयात करें';

  @override
  String get importResult => 'आयात परिणाम';

  @override
  String get imported => 'जोड़े गए';

  @override
  String get skipped => 'छोड़े गए';

  @override
  String get row => 'पंक्ति';

  @override
  String get csvColumnsHint => 'कॉलम';

  @override
  String get ok => 'ठीक है';

  @override
  String get privateMode => 'निजी मोड (लॉक)';

  @override
  String get setPin => 'PIN सेट करें';

  @override
  String get changePin => 'PIN बदलें';

  @override
  String get removePin => 'PIN हटाएँ';

  @override
  String get pinHint => '4 से 8 अंक';

  @override
  String get useBiometric => 'बायोमेट्रिक का उपयोग करें';

  @override
  String get enterPin => 'PIN डालें';

  @override
  String get unlock => 'खोलें';

  @override
  String get wrongPin => 'गलत PIN';

  @override
  String get newNote => 'नया नोट';

  @override
  String get editNote => 'नोट बदलें';

  @override
  String get noteText => 'नोट';

  @override
  String get transcriptEditable =>
      'बोले हुए शब्द यहाँ दिखेंगे; सहेजने से पहले बदल सकते हैं';

  @override
  String get speak => 'बोलकर लिखें';

  @override
  String get stopListening => 'रोकें';

  @override
  String get micUnavailable =>
      'माइक या बोली पहचान उपलब्ध नहीं है; आप टाइप कर सकते हैं';

  @override
  String get linkedPin => 'जुड़ा हुआ पिन (प्लॉट)';

  @override
  String get noPin => 'कोई पिन नहीं';

  @override
  String get search => 'खोजें';

  @override
  String get anyDate => 'कोई भी तारीख';

  @override
  String get allPins => 'सभी पिन';

  @override
  String get noNotes => 'कोई नोट नहीं';

  @override
  String get exportDiary => 'डायरी निर्यात करें';

  @override
  String get addNoteForPin => 'इस पिन के लिए नोट जोड़ें';

  @override
  String get backupData => 'बैकअप सहेजें (JSON)';

  @override
  String get restoreData => 'बैकअप से वापस लाएँ';

  @override
  String get backupSaved => 'फ़ाइल सहेज ली गई';

  @override
  String get restoreDone => 'डेटा वापस लाया गया';

  @override
  String get restoreFailed => 'यह फ़ाइल सही बैकअप नहीं है; कुछ नहीं बदला';

  @override
  String get layers => 'परतें';

  @override
  String get layerMetro => 'मेट्रो';

  @override
  String get layerRingRoad => 'रिंग रोड';

  @override
  String get layerWidening => 'सड़क चौड़ीकरण';

  @override
  String get layerAcquisition => 'संभावित अधिग्रहण';

  @override
  String get acquisitionWarning => 'यह बिंदु संभावित अधिग्रहण क्षेत्र में है';

  @override
  String get signIn => 'साइन इन';

  @override
  String get createAccount => 'खाता बनाएँ';

  @override
  String get useOffline => 'बिना खाते के इस फ़ोन पर चलाएँ';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get credentialsHint => 'ईमेल लिखें; पासवर्ड कम से कम 6 अक्षर का हो';

  @override
  String get confirmEmail =>
      'अपना ईमेल खोलकर खाते की पुष्टि करें, फिर साइन इन करें';

  @override
  String get account => 'खाता और सिंक';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get syncFailed => 'सिंक नहीं हुआ';

  @override
  String get neverSynced => 'अभी तक सिंक नहीं हुआ';

  @override
  String get lastSynced => 'आख़िरी सिंक';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get offlineMode => 'अभी केवल इस फ़ोन पर';

  @override
  String get familySpace => 'परिवार का स्पेस';

  @override
  String get joinWithCode => 'आमंत्रण कोड से जुड़ें';

  @override
  String get inviteCode => 'आमंत्रण कोड';

  @override
  String get join => 'जुड़ें';

  @override
  String get orStartNew => 'या नया स्पेस बनाएँ';

  @override
  String get familyName => 'स्पेस का नाम';

  @override
  String get createFamily => 'नया स्पेस बनाएँ';

  @override
  String get manageMembers => 'सदस्य';

  @override
  String get inviteMember => 'सदस्य बुलाएँ';

  @override
  String get inviteHelp =>
      'यह कोड 3 दिन तक और केवल एक बार चलेगा। उन्हें अपना खाता बनाकर यह कोड डालना होगा।';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get you => 'आप';

  @override
  String get roleOwner => 'मालिक';

  @override
  String get roleMember => 'सदस्य';

  @override
  String get removeMember => 'सदस्य हटाएँ';

  @override
  String get leaveFamily => 'स्पेस छोड़ें';

  @override
  String get confirmRemove => 'इस सदस्य की पहुँच तुरंत बंद हो जाएगी। ठीक है?';

  @override
  String get confirmLeave => 'आप इस स्पेस का डेटा देखना बंद कर देंगे। ठीक है?';

  @override
  String get removedKeepsCopy =>
      'हटाए गए सदस्य के फ़ोन में पहले से सिंक हुई नकल रह सकती है; नई जानकारी उन्हें नहीं मिलेगी।';

  @override
  String get acquisitionCheck => 'अधिग्रहण जाँच';

  @override
  String get riskNone =>
      'किसी संभावित अधिग्रहण क्षेत्र में नहीं (उपलब्ध डेटा के अनुसार)';

  @override
  String get riskInside => 'संभावित अधिग्रहण क्षेत्र के अंदर';

  @override
  String riskNear(int m) {
    return 'संभावित अधिग्रहण क्षेत्र से $m मीटर दूर';
  }

  @override
  String get corridorWidth => 'गलियारे की कुल चौड़ाई';

  @override
  String corridorCheckOf(String layer) {
    return '$layer जाँच';
  }

  @override
  String corridorNoneOf(String layer) {
    return 'किसी गलियारे में नहीं (उपलब्ध डेटा के अनुसार)';
  }

  @override
  String corridorInsideOf(String layer) {
    return '$layer गलियारे के अंदर';
  }

  @override
  String corridorNearOf(String layer, int m) {
    return '$layer गलियारे से $m मीटर दूर';
  }

  @override
  String corridorWidthUnknownOf(String layer) {
    return 'पास में $layer मार्ग है पर डेटा में चौड़ाई नहीं दी गई';
  }

  @override
  String get sideNorth => 'उत्तर की ओर';

  @override
  String get sideSouth => 'दक्षिण की ओर';

  @override
  String get sideEast => 'पूर्व की ओर';

  @override
  String get sideWest => 'पश्चिम की ओर';

  @override
  String corridorSides(String left, String right) {
    return 'गलियारा: बाएँ $left मी, दाएँ $right मी (रेखा की दिशा में देखते हुए)';
  }

  @override
  String get corridorSquareEnds => 'गलियारे के सिरे सीधे कटे हुए (चौकोर)';

  @override
  String corridorAngledEnds(String start, String end) {
    return 'गलियारे के सिरे तिरछे कटे हुए: शुरू $start°, अंत $end° (वामावर्त, ऊपर से देखने पर)';
  }
}
