import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In hi, this message translates to:
  /// **'अयोध्या ज़मीन'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In hi, this message translates to:
  /// **'स्वागत है'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In hi, this message translates to:
  /// **'अयोध्या की ज़मीन का आपका निजी हिसाब-किताब'**
  String get welcomeSubtitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In hi, this message translates to:
  /// **'भाषा चुनें'**
  String get chooseLanguage;

  /// No description provided for @continueBtn.
  ///
  /// In hi, this message translates to:
  /// **'आगे बढ़ें'**
  String get continueBtn;

  /// No description provided for @home.
  ///
  /// In hi, this message translates to:
  /// **'होम'**
  String get home;

  /// No description provided for @calculator.
  ///
  /// In hi, this message translates to:
  /// **'कैलकुलेटर'**
  String get calculator;

  /// No description provided for @settings.
  ///
  /// In hi, this message translates to:
  /// **'सेटिंग्स'**
  String get settings;

  /// No description provided for @map.
  ///
  /// In hi, this message translates to:
  /// **'नक्शा'**
  String get map;

  /// No description provided for @plots.
  ///
  /// In hi, this message translates to:
  /// **'प्लॉट'**
  String get plots;

  /// No description provided for @diary.
  ///
  /// In hi, this message translates to:
  /// **'डायरी'**
  String get diary;

  /// No description provided for @comingSoon.
  ///
  /// In hi, this message translates to:
  /// **'जल्द आ रहा है'**
  String get comingSoon;

  /// No description provided for @language.
  ///
  /// In hi, this message translates to:
  /// **'भाषा'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In hi, this message translates to:
  /// **'डार्क मोड'**
  String get darkMode;

  /// No description provided for @district.
  ///
  /// In hi, this message translates to:
  /// **'ज़िला'**
  String get district;

  /// No description provided for @value.
  ///
  /// In hi, this message translates to:
  /// **'मान'**
  String get value;

  /// No description provided for @fromUnit.
  ///
  /// In hi, this message translates to:
  /// **'इस इकाई से'**
  String get fromUnit;

  /// No description provided for @results.
  ///
  /// In hi, this message translates to:
  /// **'परिणाम'**
  String get results;

  /// No description provided for @formula.
  ///
  /// In hi, this message translates to:
  /// **'सूत्र'**
  String get formula;

  /// No description provided for @source.
  ///
  /// In hi, this message translates to:
  /// **'स्रोत'**
  String get source;

  /// No description provided for @lastUpdated.
  ///
  /// In hi, this message translates to:
  /// **'आख़िरी अपडेट'**
  String get lastUpdated;

  /// No description provided for @demo.
  ///
  /// In hi, this message translates to:
  /// **'डेमो'**
  String get demo;

  /// No description provided for @unverified.
  ///
  /// In hi, this message translates to:
  /// **'अपुष्ट — कृपया खुद जाँचें'**
  String get unverified;

  /// No description provided for @ratePerUnit.
  ///
  /// In hi, this message translates to:
  /// **'दर (प्रति इकाई)'**
  String get ratePerUnit;

  /// No description provided for @rateUnit.
  ///
  /// In hi, this message translates to:
  /// **'दर की इकाई'**
  String get rateUnit;

  /// No description provided for @totalPrice.
  ///
  /// In hi, this message translates to:
  /// **'कुल कीमत'**
  String get totalPrice;

  /// No description provided for @unitRules.
  ///
  /// In hi, this message translates to:
  /// **'इकाई नियम'**
  String get unitRules;

  /// No description provided for @editRule.
  ///
  /// In hi, this message translates to:
  /// **'नियम बदलें'**
  String get editRule;

  /// No description provided for @addRule.
  ///
  /// In hi, this message translates to:
  /// **'नियम जोड़ें'**
  String get addRule;

  /// No description provided for @deleteRule.
  ///
  /// In hi, this message translates to:
  /// **'नियम हटाएँ'**
  String get deleteRule;

  /// No description provided for @save.
  ///
  /// In hi, this message translates to:
  /// **'सहेजें'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In hi, this message translates to:
  /// **'रद्द करें'**
  String get cancel;

  /// No description provided for @biswaPerBigha.
  ///
  /// In hi, this message translates to:
  /// **'बीघा में बिस्वा'**
  String get biswaPerBigha;

  /// No description provided for @biswansiPerBiswa.
  ///
  /// In hi, this message translates to:
  /// **'बिस्वा में बिस्वांसी'**
  String get biswansiPerBiswa;

  /// No description provided for @sqftPerBiswa.
  ///
  /// In hi, this message translates to:
  /// **'एक बिस्वा में वर्ग फुट'**
  String get sqftPerBiswa;

  /// No description provided for @unitName.
  ///
  /// In hi, this message translates to:
  /// **'बीघा का प्रकार'**
  String get unitName;

  /// No description provided for @sourceNote.
  ///
  /// In hi, this message translates to:
  /// **'स्रोत टिप्पणी'**
  String get sourceNote;

  /// No description provided for @invalidNumber.
  ///
  /// In hi, this message translates to:
  /// **'सही संख्या लिखें'**
  String get invalidNumber;

  /// No description provided for @unit_bigha.
  ///
  /// In hi, this message translates to:
  /// **'बीघा'**
  String get unit_bigha;

  /// No description provided for @unit_biswa.
  ///
  /// In hi, this message translates to:
  /// **'बिस्वा'**
  String get unit_biswa;

  /// No description provided for @unit_biswansi.
  ///
  /// In hi, this message translates to:
  /// **'बिस्वांसी'**
  String get unit_biswansi;

  /// No description provided for @unit_sqft.
  ///
  /// In hi, this message translates to:
  /// **'वर्ग फुट'**
  String get unit_sqft;

  /// No description provided for @unit_sqyd.
  ///
  /// In hi, this message translates to:
  /// **'वर्ग गज'**
  String get unit_sqyd;

  /// No description provided for @unit_sqm.
  ///
  /// In hi, this message translates to:
  /// **'वर्ग मीटर'**
  String get unit_sqm;

  /// No description provided for @unit_acre.
  ///
  /// In hi, this message translates to:
  /// **'एकड़'**
  String get unit_acre;

  /// No description provided for @disclaimer.
  ///
  /// In hi, this message translates to:
  /// **'केवल जानकारी के लिए, कानूनी सलाह नहीं। तहसील या रजिस्ट्री कार्यालय में सत्यापित करें।'**
  String get disclaimer;

  /// No description provided for @formulaBigha.
  ///
  /// In hi, this message translates to:
  /// **'1 बीघा = {biswa} बिस्वा; 1 बिस्वा = {sqft} वर्ग फुट; 1 बिस्वा = {biswansi} बिस्वांसी'**
  String formulaBigha(String biswa, String sqft, String biswansi);

  /// No description provided for @formulaFixed.
  ///
  /// In hi, this message translates to:
  /// **'1 वर्ग गज = 9 वर्ग फुट; 1 वर्ग मीटर = 10.7639 वर्ग फुट; 1 एकड़ = 43,560 वर्ग फुट'**
  String get formulaFixed;

  /// No description provided for @formulaTotal.
  ///
  /// In hi, this message translates to:
  /// **'कुल कीमत = दर × क्षेत्रफल (दर की इकाई में)'**
  String get formulaTotal;

  /// No description provided for @planYear.
  ///
  /// In hi, this message translates to:
  /// **'योजना वर्ष'**
  String get planYear;

  /// No description provided for @zoneType.
  ///
  /// In hi, this message translates to:
  /// **'क्षेत्र का प्रकार'**
  String get zoneType;

  /// No description provided for @heightLimit.
  ///
  /// In hi, this message translates to:
  /// **'ऊँचाई सीमा'**
  String get heightLimit;

  /// No description provided for @notSet.
  ///
  /// In hi, this message translates to:
  /// **'तय नहीं'**
  String get notSet;

  /// No description provided for @noZoneHere.
  ///
  /// In hi, this message translates to:
  /// **'इस बिंदु पर कोई क्षेत्र नहीं'**
  String get noZoneHere;

  /// No description provided for @mapLoadError.
  ///
  /// In hi, this message translates to:
  /// **'नक्शा लोड नहीं हुआ'**
  String get mapLoadError;

  /// No description provided for @required.
  ///
  /// In hi, this message translates to:
  /// **'ज़रूरी'**
  String get required;

  /// No description provided for @addPlot.
  ///
  /// In hi, this message translates to:
  /// **'प्लॉट जोड़ें'**
  String get addPlot;

  /// No description provided for @editPlot.
  ///
  /// In hi, this message translates to:
  /// **'प्लॉट बदलें'**
  String get editPlot;

  /// No description provided for @deletePlot.
  ///
  /// In hi, this message translates to:
  /// **'प्लॉट हटाएँ'**
  String get deletePlot;

  /// No description provided for @location.
  ///
  /// In hi, this message translates to:
  /// **'स्थान'**
  String get location;

  /// No description provided for @latitude.
  ///
  /// In hi, this message translates to:
  /// **'अक्षांश (lat)'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In hi, this message translates to:
  /// **'देशांतर (lng)'**
  String get longitude;

  /// No description provided for @khasraNo.
  ///
  /// In hi, this message translates to:
  /// **'खसरा नं.'**
  String get khasraNo;

  /// No description provided for @area.
  ///
  /// In hi, this message translates to:
  /// **'क्षेत्रफल'**
  String get area;

  /// No description provided for @areaUnit.
  ///
  /// In hi, this message translates to:
  /// **'क्षेत्रफल की इकाई'**
  String get areaUnit;

  /// No description provided for @status.
  ///
  /// In hi, this message translates to:
  /// **'स्थिति'**
  String get status;

  /// No description provided for @statusForSale.
  ///
  /// In hi, this message translates to:
  /// **'बिक्री के लिए'**
  String get statusForSale;

  /// No description provided for @statusHold.
  ///
  /// In hi, this message translates to:
  /// **'रुका हुआ'**
  String get statusHold;

  /// No description provided for @statusSold.
  ///
  /// In hi, this message translates to:
  /// **'बिक चुका'**
  String get statusSold;

  /// No description provided for @riskNote.
  ///
  /// In hi, this message translates to:
  /// **'मास्टर प्लान जोखिम'**
  String get riskNote;

  /// No description provided for @sourceRequired.
  ///
  /// In hi, this message translates to:
  /// **'स्रोत (ज़रूरी)'**
  String get sourceRequired;

  /// No description provided for @currentOwner.
  ///
  /// In hi, this message translates to:
  /// **'वर्तमान मालिक'**
  String get currentOwner;

  /// No description provided for @previousOwners.
  ///
  /// In hi, this message translates to:
  /// **'पिछले मालिक (कॉमा से अलग)'**
  String get previousOwners;

  /// No description provided for @dealer.
  ///
  /// In hi, this message translates to:
  /// **'डीलर'**
  String get dealer;

  /// No description provided for @dealerPhone.
  ///
  /// In hi, this message translates to:
  /// **'डीलर का फ़ोन'**
  String get dealerPhone;

  /// No description provided for @disputed.
  ///
  /// In hi, this message translates to:
  /// **'विवादित / केस लंबित'**
  String get disputed;

  /// No description provided for @caseType.
  ///
  /// In hi, this message translates to:
  /// **'केस का प्रकार'**
  String get caseType;

  /// No description provided for @court.
  ///
  /// In hi, this message translates to:
  /// **'न्यायालय'**
  String get court;

  /// No description provided for @nextDate.
  ///
  /// In hi, this message translates to:
  /// **'अगली तारीख'**
  String get nextDate;

  /// No description provided for @casePending.
  ///
  /// In hi, this message translates to:
  /// **'लंबित'**
  String get casePending;

  /// No description provided for @caseResolved.
  ///
  /// In hi, this message translates to:
  /// **'निपटा हुआ'**
  String get caseResolved;

  /// No description provided for @note.
  ///
  /// In hi, this message translates to:
  /// **'टिप्पणी'**
  String get note;

  /// No description provided for @favourite.
  ///
  /// In hi, this message translates to:
  /// **'पसंदीदा'**
  String get favourite;

  /// No description provided for @watchlist.
  ///
  /// In hi, this message translates to:
  /// **'वॉच-लिस्ट'**
  String get watchlist;

  /// No description provided for @favouritesOnly.
  ///
  /// In hi, this message translates to:
  /// **'केवल पसंदीदा'**
  String get favouritesOnly;

  /// No description provided for @filters.
  ///
  /// In hi, this message translates to:
  /// **'फ़िल्टर'**
  String get filters;

  /// No description provided for @areaFilter.
  ///
  /// In hi, this message translates to:
  /// **'इलाका'**
  String get areaFilter;

  /// No description provided for @maxBudget.
  ///
  /// In hi, this message translates to:
  /// **'अधिकतम बजट (₹)'**
  String get maxBudget;

  /// No description provided for @minSqft.
  ///
  /// In hi, this message translates to:
  /// **'न्यूनतम वर्ग फुट'**
  String get minSqft;

  /// No description provided for @maxSqft.
  ///
  /// In hi, this message translates to:
  /// **'अधिकतम वर्ग फुट'**
  String get maxSqft;

  /// No description provided for @clear.
  ///
  /// In hi, this message translates to:
  /// **'साफ़ करें'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In hi, this message translates to:
  /// **'लागू करें'**
  String get apply;

  /// No description provided for @openBhulekh.
  ///
  /// In hi, this message translates to:
  /// **'भूलेख खोलें'**
  String get openBhulekh;

  /// No description provided for @openBhunaksha.
  ///
  /// In hi, this message translates to:
  /// **'भूनक्शा खोलें'**
  String get openBhunaksha;

  /// No description provided for @importCsv.
  ///
  /// In hi, this message translates to:
  /// **'CSV आयात करें'**
  String get importCsv;

  /// No description provided for @importResult.
  ///
  /// In hi, this message translates to:
  /// **'आयात परिणाम'**
  String get importResult;

  /// No description provided for @imported.
  ///
  /// In hi, this message translates to:
  /// **'जोड़े गए'**
  String get imported;

  /// No description provided for @skipped.
  ///
  /// In hi, this message translates to:
  /// **'छोड़े गए'**
  String get skipped;

  /// No description provided for @row.
  ///
  /// In hi, this message translates to:
  /// **'पंक्ति'**
  String get row;

  /// No description provided for @csvColumnsHint.
  ///
  /// In hi, this message translates to:
  /// **'कॉलम'**
  String get csvColumnsHint;

  /// No description provided for @ok.
  ///
  /// In hi, this message translates to:
  /// **'ठीक है'**
  String get ok;

  /// No description provided for @privateMode.
  ///
  /// In hi, this message translates to:
  /// **'निजी मोड (लॉक)'**
  String get privateMode;

  /// No description provided for @setPin.
  ///
  /// In hi, this message translates to:
  /// **'PIN सेट करें'**
  String get setPin;

  /// No description provided for @changePin.
  ///
  /// In hi, this message translates to:
  /// **'PIN बदलें'**
  String get changePin;

  /// No description provided for @removePin.
  ///
  /// In hi, this message translates to:
  /// **'PIN हटाएँ'**
  String get removePin;

  /// No description provided for @pinHint.
  ///
  /// In hi, this message translates to:
  /// **'4 से 8 अंक'**
  String get pinHint;

  /// No description provided for @useBiometric.
  ///
  /// In hi, this message translates to:
  /// **'बायोमेट्रिक का उपयोग करें'**
  String get useBiometric;

  /// No description provided for @enterPin.
  ///
  /// In hi, this message translates to:
  /// **'PIN डालें'**
  String get enterPin;

  /// No description provided for @unlock.
  ///
  /// In hi, this message translates to:
  /// **'खोलें'**
  String get unlock;

  /// No description provided for @wrongPin.
  ///
  /// In hi, this message translates to:
  /// **'गलत PIN'**
  String get wrongPin;

  /// No description provided for @newNote.
  ///
  /// In hi, this message translates to:
  /// **'नया नोट'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In hi, this message translates to:
  /// **'नोट बदलें'**
  String get editNote;

  /// No description provided for @noteText.
  ///
  /// In hi, this message translates to:
  /// **'नोट'**
  String get noteText;

  /// No description provided for @transcriptEditable.
  ///
  /// In hi, this message translates to:
  /// **'बोले हुए शब्द यहाँ दिखेंगे; सहेजने से पहले बदल सकते हैं'**
  String get transcriptEditable;

  /// No description provided for @speak.
  ///
  /// In hi, this message translates to:
  /// **'बोलकर लिखें'**
  String get speak;

  /// No description provided for @stopListening.
  ///
  /// In hi, this message translates to:
  /// **'रोकें'**
  String get stopListening;

  /// No description provided for @micUnavailable.
  ///
  /// In hi, this message translates to:
  /// **'माइक या बोली पहचान उपलब्ध नहीं है; आप टाइप कर सकते हैं'**
  String get micUnavailable;

  /// No description provided for @linkedPin.
  ///
  /// In hi, this message translates to:
  /// **'जुड़ा हुआ पिन (प्लॉट)'**
  String get linkedPin;

  /// No description provided for @noPin.
  ///
  /// In hi, this message translates to:
  /// **'कोई पिन नहीं'**
  String get noPin;

  /// No description provided for @search.
  ///
  /// In hi, this message translates to:
  /// **'खोजें'**
  String get search;

  /// No description provided for @anyDate.
  ///
  /// In hi, this message translates to:
  /// **'कोई भी तारीख'**
  String get anyDate;

  /// No description provided for @allPins.
  ///
  /// In hi, this message translates to:
  /// **'सभी पिन'**
  String get allPins;

  /// No description provided for @noNotes.
  ///
  /// In hi, this message translates to:
  /// **'कोई नोट नहीं'**
  String get noNotes;

  /// No description provided for @exportDiary.
  ///
  /// In hi, this message translates to:
  /// **'डायरी निर्यात करें'**
  String get exportDiary;

  /// No description provided for @addNoteForPin.
  ///
  /// In hi, this message translates to:
  /// **'इस पिन के लिए नोट जोड़ें'**
  String get addNoteForPin;

  /// No description provided for @backupData.
  ///
  /// In hi, this message translates to:
  /// **'बैकअप सहेजें (JSON)'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In hi, this message translates to:
  /// **'बैकअप से वापस लाएँ'**
  String get restoreData;

  /// No description provided for @backupSaved.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल सहेज ली गई'**
  String get backupSaved;

  /// No description provided for @restoreDone.
  ///
  /// In hi, this message translates to:
  /// **'डेटा वापस लाया गया'**
  String get restoreDone;

  /// No description provided for @restoreFailed.
  ///
  /// In hi, this message translates to:
  /// **'यह फ़ाइल सही बैकअप नहीं है; कुछ नहीं बदला'**
  String get restoreFailed;

  /// No description provided for @layers.
  ///
  /// In hi, this message translates to:
  /// **'परतें'**
  String get layers;

  /// No description provided for @layerMetro.
  ///
  /// In hi, this message translates to:
  /// **'मेट्रो'**
  String get layerMetro;

  /// No description provided for @layerRingRoad.
  ///
  /// In hi, this message translates to:
  /// **'रिंग रोड'**
  String get layerRingRoad;

  /// No description provided for @layerWidening.
  ///
  /// In hi, this message translates to:
  /// **'सड़क चौड़ीकरण'**
  String get layerWidening;

  /// No description provided for @layerAcquisition.
  ///
  /// In hi, this message translates to:
  /// **'संभावित अधिग्रहण'**
  String get layerAcquisition;

  /// No description provided for @acquisitionWarning.
  ///
  /// In hi, this message translates to:
  /// **'यह बिंदु संभावित अधिग्रहण क्षेत्र में है'**
  String get acquisitionWarning;

  /// No description provided for @signIn.
  ///
  /// In hi, this message translates to:
  /// **'साइन इन'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In hi, this message translates to:
  /// **'खाता बनाएँ'**
  String get createAccount;

  /// No description provided for @useOffline.
  ///
  /// In hi, this message translates to:
  /// **'बिना खाते के इस फ़ोन पर चलाएँ'**
  String get useOffline;

  /// No description provided for @email.
  ///
  /// In hi, this message translates to:
  /// **'ईमेल'**
  String get email;

  /// No description provided for @password.
  ///
  /// In hi, this message translates to:
  /// **'पासवर्ड'**
  String get password;

  /// No description provided for @credentialsHint.
  ///
  /// In hi, this message translates to:
  /// **'ईमेल लिखें; पासवर्ड कम से कम 6 अक्षर का हो'**
  String get credentialsHint;

  /// No description provided for @confirmEmail.
  ///
  /// In hi, this message translates to:
  /// **'अपना ईमेल खोलकर खाते की पुष्टि करें, फिर साइन इन करें'**
  String get confirmEmail;

  /// No description provided for @account.
  ///
  /// In hi, this message translates to:
  /// **'खाता और सिंक'**
  String get account;

  /// No description provided for @syncNow.
  ///
  /// In hi, this message translates to:
  /// **'अभी सिंक करें'**
  String get syncNow;

  /// No description provided for @syncFailed.
  ///
  /// In hi, this message translates to:
  /// **'सिंक नहीं हुआ'**
  String get syncFailed;

  /// No description provided for @neverSynced.
  ///
  /// In hi, this message translates to:
  /// **'अभी तक सिंक नहीं हुआ'**
  String get neverSynced;

  /// No description provided for @lastSynced.
  ///
  /// In hi, this message translates to:
  /// **'आख़िरी सिंक'**
  String get lastSynced;

  /// No description provided for @signOut.
  ///
  /// In hi, this message translates to:
  /// **'साइन आउट'**
  String get signOut;

  /// No description provided for @offlineMode.
  ///
  /// In hi, this message translates to:
  /// **'अभी केवल इस फ़ोन पर'**
  String get offlineMode;

  /// No description provided for @familySpace.
  ///
  /// In hi, this message translates to:
  /// **'परिवार का स्पेस'**
  String get familySpace;

  /// No description provided for @joinWithCode.
  ///
  /// In hi, this message translates to:
  /// **'आमंत्रण कोड से जुड़ें'**
  String get joinWithCode;

  /// No description provided for @inviteCode.
  ///
  /// In hi, this message translates to:
  /// **'आमंत्रण कोड'**
  String get inviteCode;

  /// No description provided for @join.
  ///
  /// In hi, this message translates to:
  /// **'जुड़ें'**
  String get join;

  /// No description provided for @orStartNew.
  ///
  /// In hi, this message translates to:
  /// **'या नया स्पेस बनाएँ'**
  String get orStartNew;

  /// No description provided for @familyName.
  ///
  /// In hi, this message translates to:
  /// **'स्पेस का नाम'**
  String get familyName;

  /// No description provided for @createFamily.
  ///
  /// In hi, this message translates to:
  /// **'नया स्पेस बनाएँ'**
  String get createFamily;

  /// No description provided for @manageMembers.
  ///
  /// In hi, this message translates to:
  /// **'सदस्य'**
  String get manageMembers;

  /// No description provided for @inviteMember.
  ///
  /// In hi, this message translates to:
  /// **'सदस्य बुलाएँ'**
  String get inviteMember;

  /// No description provided for @inviteHelp.
  ///
  /// In hi, this message translates to:
  /// **'यह कोड 3 दिन तक और केवल एक बार चलेगा। उन्हें अपना खाता बनाकर यह कोड डालना होगा।'**
  String get inviteHelp;

  /// No description provided for @copy.
  ///
  /// In hi, this message translates to:
  /// **'कॉपी करें'**
  String get copy;

  /// No description provided for @you.
  ///
  /// In hi, this message translates to:
  /// **'आप'**
  String get you;

  /// No description provided for @roleOwner.
  ///
  /// In hi, this message translates to:
  /// **'मालिक'**
  String get roleOwner;

  /// No description provided for @roleMember.
  ///
  /// In hi, this message translates to:
  /// **'सदस्य'**
  String get roleMember;

  /// No description provided for @removeMember.
  ///
  /// In hi, this message translates to:
  /// **'सदस्य हटाएँ'**
  String get removeMember;

  /// No description provided for @leaveFamily.
  ///
  /// In hi, this message translates to:
  /// **'स्पेस छोड़ें'**
  String get leaveFamily;

  /// No description provided for @confirmRemove.
  ///
  /// In hi, this message translates to:
  /// **'इस सदस्य की पहुँच तुरंत बंद हो जाएगी। ठीक है?'**
  String get confirmRemove;

  /// No description provided for @confirmLeave.
  ///
  /// In hi, this message translates to:
  /// **'आप इस स्पेस का डेटा देखना बंद कर देंगे। ठीक है?'**
  String get confirmLeave;

  /// No description provided for @removedKeepsCopy.
  ///
  /// In hi, this message translates to:
  /// **'हटाए गए सदस्य के फ़ोन में पहले से सिंक हुई नकल रह सकती है; नई जानकारी उन्हें नहीं मिलेगी।'**
  String get removedKeepsCopy;

  /// No description provided for @acquisitionCheck.
  ///
  /// In hi, this message translates to:
  /// **'अधिग्रहण जाँच'**
  String get acquisitionCheck;

  /// No description provided for @riskNone.
  ///
  /// In hi, this message translates to:
  /// **'किसी संभावित अधिग्रहण क्षेत्र में नहीं (उपलब्ध डेटा के अनुसार)'**
  String get riskNone;

  /// No description provided for @riskInside.
  ///
  /// In hi, this message translates to:
  /// **'संभावित अधिग्रहण क्षेत्र के अंदर'**
  String get riskInside;

  /// No description provided for @riskNear.
  ///
  /// In hi, this message translates to:
  /// **'संभावित अधिग्रहण क्षेत्र से {m} मीटर दूर'**
  String riskNear(int m);

  /// No description provided for @corridorWidth.
  ///
  /// In hi, this message translates to:
  /// **'गलियारे की कुल चौड़ाई'**
  String get corridorWidth;

  /// No description provided for @corridorCheckOf.
  ///
  /// In hi, this message translates to:
  /// **'{layer} जाँच'**
  String corridorCheckOf(String layer);

  /// No description provided for @corridorNoneOf.
  ///
  /// In hi, this message translates to:
  /// **'किसी गलियारे में नहीं (उपलब्ध डेटा के अनुसार)'**
  String corridorNoneOf(String layer);

  /// No description provided for @corridorInsideOf.
  ///
  /// In hi, this message translates to:
  /// **'{layer} गलियारे के अंदर'**
  String corridorInsideOf(String layer);

  /// No description provided for @corridorNearOf.
  ///
  /// In hi, this message translates to:
  /// **'{layer} गलियारे से {m} मीटर दूर'**
  String corridorNearOf(String layer, int m);

  /// No description provided for @corridorWidthUnknownOf.
  ///
  /// In hi, this message translates to:
  /// **'पास में {layer} मार्ग है पर डेटा में चौड़ाई नहीं दी गई'**
  String corridorWidthUnknownOf(String layer);

  /// No description provided for @sideNorth.
  ///
  /// In hi, this message translates to:
  /// **'उत्तर की ओर'**
  String get sideNorth;

  /// No description provided for @sideSouth.
  ///
  /// In hi, this message translates to:
  /// **'दक्षिण की ओर'**
  String get sideSouth;

  /// No description provided for @sideEast.
  ///
  /// In hi, this message translates to:
  /// **'पूर्व की ओर'**
  String get sideEast;

  /// No description provided for @sideWest.
  ///
  /// In hi, this message translates to:
  /// **'पश्चिम की ओर'**
  String get sideWest;

  /// No description provided for @corridorSides.
  ///
  /// In hi, this message translates to:
  /// **'गलियारा: बाएँ {left} मी, दाएँ {right} मी (रेखा की दिशा में देखते हुए)'**
  String corridorSides(String left, String right);

  /// No description provided for @corridorSquareEnds.
  ///
  /// In hi, this message translates to:
  /// **'गलियारे के सिरे सीधे कटे हुए (चौकोर)'**
  String get corridorSquareEnds;

  /// No description provided for @corridorAngledEnds.
  ///
  /// In hi, this message translates to:
  /// **'गलियारे के सिरे तिरछे कटे हुए: शुरू {start}°, अंत {end}° (वामावर्त, ऊपर से देखने पर)'**
  String corridorAngledEnds(String start, String end);

  /// No description provided for @layerOsm.
  ///
  /// In hi, this message translates to:
  /// **'OpenStreetMap (असली सड़क/रेल/नदी)'**
  String get layerOsm;

  /// No description provided for @osmLoading.
  ///
  /// In hi, this message translates to:
  /// **'लोड हो रहा है'**
  String get osmLoading;

  /// No description provided for @osmFailed.
  ///
  /// In hi, this message translates to:
  /// **'डाउनलोड नहीं हुआ'**
  String get osmFailed;

  /// No description provided for @osmUpdated.
  ///
  /// In hi, this message translates to:
  /// **'अपडेट'**
  String get osmUpdated;

  /// No description provided for @osmSaved.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोन में सहेजा'**
  String get osmSaved;

  /// No description provided for @refresh.
  ///
  /// In hi, this message translates to:
  /// **'ताज़ा करें'**
  String get refresh;

  /// No description provided for @osmNotOfficial.
  ///
  /// In hi, this message translates to:
  /// **'यह स्वयंसेवकों का बनाया नक्शा है, सरकारी रेखांकन नहीं। मास्टर प्लान से मिलाकर जाँचें।'**
  String get osmNotOfficial;

  /// No description provided for @realData.
  ///
  /// In hi, this message translates to:
  /// **'असली डेटा'**
  String get realData;

  /// No description provided for @realDataHelp.
  ///
  /// In hi, this message translates to:
  /// **'ADA मास्टर प्लान, IGRSUP रेट और भूलेख के लिए कोई खुला API नहीं है। उन्हें आधिकारिक साइट से देखकर यहाँ फ़ाइल से डालें।'**
  String get realDataHelp;

  /// No description provided for @importZones.
  ///
  /// In hi, this message translates to:
  /// **'ज़ोन GeoJSON आयात करें'**
  String get importZones;

  /// No description provided for @importOverlays.
  ///
  /// In hi, this message translates to:
  /// **'मेट्रो/रिंग रोड/चौड़ीकरण/अधिग्रहण GeoJSON आयात करें'**
  String get importOverlays;

  /// No description provided for @resetToDemo.
  ///
  /// In hi, this message translates to:
  /// **'नक्शे का डेटा डेमो पर वापस करें'**
  String get resetToDemo;

  /// No description provided for @removeDemo.
  ///
  /// In hi, this message translates to:
  /// **'सभी डेमो रिकॉर्ड हटाएँ'**
  String get removeDemo;

  /// No description provided for @removed.
  ///
  /// In hi, this message translates to:
  /// **'हटाए गए'**
  String get removed;

  /// No description provided for @importBad.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल सही नहीं है; कुछ नहीं बदला'**
  String get importBad;

  /// No description provided for @findOnMap.
  ///
  /// In hi, this message translates to:
  /// **'नक्शे पर खोजें'**
  String get findOnMap;

  /// No description provided for @pickPlace.
  ///
  /// In hi, this message translates to:
  /// **'स्थान चुनें'**
  String get pickPlace;

  /// No description provided for @noPlaceFound.
  ///
  /// In hi, this message translates to:
  /// **'कोई स्थान नहीं मिला'**
  String get noPlaceFound;

  /// No description provided for @searchFailed.
  ///
  /// In hi, this message translates to:
  /// **'खोज नहीं हो सकी'**
  String get searchFailed;

  /// No description provided for @dataSources.
  ///
  /// In hi, this message translates to:
  /// **'डेटा स्रोत (API)'**
  String get dataSources;

  /// No description provided for @dataSourcesShort.
  ///
  /// In hi, this message translates to:
  /// **'आधिकारिक WMS/टाइल/GeoJSON endpoint जोड़ें'**
  String get dataSourcesShort;

  /// No description provided for @dataSourcesHelp.
  ///
  /// In hi, this message translates to:
  /// **'भूलेख और भूनक्शा का कोई खुला API नहीं है, इसलिए ऐप उन्हें स्क्रैप नहीं करता। भुवन (ISRO) जैसी सरकारी सेवाओं के WMS/टाइल लेयर या किसी विभाग की GeoJSON फ़ाइल का वह endpoint यहाँ जोड़ें जिसे इस्तेमाल करने का आपको अधिकार है। हर स्रोत के साथ उसका स्रोत-टिप्पणी देना ज़रूरी है। यह सूची केवल इसी फ़ोन में रहती है।'**
  String get dataSourcesHelp;

  /// No description provided for @noSources.
  ///
  /// In hi, this message translates to:
  /// **'अभी कोई स्रोत नहीं जोड़ा गया है। ऐप कोई endpoint अपनी ओर से नहीं भरता।'**
  String get noSources;

  /// No description provided for @addSource.
  ///
  /// In hi, this message translates to:
  /// **'स्रोत जोड़ें'**
  String get addSource;

  /// No description provided for @sourceType.
  ///
  /// In hi, this message translates to:
  /// **'प्रकार'**
  String get sourceType;

  /// No description provided for @kindWms.
  ///
  /// In hi, this message translates to:
  /// **'WMS नक्शा-परत'**
  String get kindWms;

  /// No description provided for @kindXyz.
  ///
  /// In hi, this message translates to:
  /// **'टाइल (XYZ) परत'**
  String get kindXyz;

  /// No description provided for @kindZones.
  ///
  /// In hi, this message translates to:
  /// **'ज़ोन GeoJSON (URL)'**
  String get kindZones;

  /// No description provided for @kindOverlays.
  ///
  /// In hi, this message translates to:
  /// **'मेट्रो/सड़क/अधिग्रहण GeoJSON (URL)'**
  String get kindOverlays;

  /// No description provided for @tileUrl.
  ///
  /// In hi, this message translates to:
  /// **'टाइल URL (जिसमें z, x और y के स्थान हों)'**
  String get tileUrl;

  /// No description provided for @endpointUrl.
  ///
  /// In hi, this message translates to:
  /// **'endpoint URL'**
  String get endpointUrl;

  /// No description provided for @wmsLayers.
  ///
  /// In hi, this message translates to:
  /// **'WMS परत के नाम (कॉमा से अलग)'**
  String get wmsLayers;

  /// No description provided for @headerName.
  ///
  /// In hi, this message translates to:
  /// **'हेडर का नाम (वैकल्पिक, जैसे Authorization)'**
  String get headerName;

  /// No description provided for @headerValue.
  ///
  /// In hi, this message translates to:
  /// **'हेडर का मान / टोकन'**
  String get headerValue;

  /// No description provided for @needHttps.
  ///
  /// In hi, this message translates to:
  /// **'केवल https:// URL मान्य है'**
  String get needHttps;

  /// No description provided for @needTemplate.
  ///
  /// In hi, this message translates to:
  /// **'URL में z, x और y के स्थान होने चाहिए (जैसे .../z/x/y.png)'**
  String get needTemplate;

  /// No description provided for @invalidUrl.
  ///
  /// In hi, this message translates to:
  /// **'URL सही नहीं है'**
  String get invalidUrl;

  /// No description provided for @fetchNow.
  ///
  /// In hi, this message translates to:
  /// **'अभी डाउनलोड करें'**
  String get fetchNow;

  /// No description provided for @fetchDone.
  ///
  /// In hi, this message translates to:
  /// **'डाउनलोड हो गया'**
  String get fetchDone;

  /// No description provided for @fetchFailed.
  ///
  /// In hi, this message translates to:
  /// **'डाउनलोड नहीं हुआ'**
  String get fetchFailed;

  /// No description provided for @village.
  ///
  /// In hi, this message translates to:
  /// **'गाँव'**
  String get village;

  /// No description provided for @tehsil.
  ///
  /// In hi, this message translates to:
  /// **'तहसील'**
  String get tehsil;

  /// No description provided for @copyForBhulekh.
  ///
  /// In hi, this message translates to:
  /// **'भूलेख के लिए विवरण कॉपी करें'**
  String get copyForBhulekh;

  /// No description provided for @copied.
  ///
  /// In hi, this message translates to:
  /// **'कॉपी हो गया; भूलेख में चिपकाएँ'**
  String get copied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
