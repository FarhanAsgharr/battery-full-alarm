// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'बैटरी फुल अलार्म';

  @override
  String get navHome => 'होम';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navStats => 'आँकड़े';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionDelete => 'हटाएँ';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get actionReset => 'रीसेट';

  @override
  String get actionOpenSettings => 'सेटिंग्स खोलें';

  @override
  String get actionAllow => 'अनुमति दें';

  @override
  String get actionNotNow => 'अभी नहीं';

  @override
  String get monitoringOn => 'निगरानी चालू है';

  @override
  String get monitoringOff => 'निगरानी बंद है';

  @override
  String get monitoringOnBody => 'बैटरी 100% पहुँचते ही आपको सूचित किया जाएगा।';

  @override
  String get monitoringOffBody =>
      'चार्जिंग पूरी होने पर सूचना पाने के लिए इसे चालू करें।';

  @override
  String get statusCharging => 'चार्ज हो रही है';

  @override
  String get statusFull => 'पूरी तरह चार्ज';

  @override
  String get statusDischarging => 'बैटरी पर';

  @override
  String get chargerAc => 'एसी चार्जर';

  @override
  String get chargerUsb => 'यूएसबी';

  @override
  String get chargerWireless => 'वायरलेस';

  @override
  String get chargerNone => 'कनेक्ट नहीं है';

  @override
  String get chargerOther => 'बाहरी पावर';

  @override
  String get alarmRinging => 'अलार्म बज रहा है';

  @override
  String get alarmRingingBody => 'चार्जर निकालें, या इसे यहाँ से बंद करें।';

  @override
  String get actionStopAlarm => 'अलार्म बंद करें';

  @override
  String get actionTestAlarm => 'अलार्म जाँचें';

  @override
  String get testAlarmStarted => 'एक अलार्म चक्र चल रहा है…';

  @override
  String get detailsTitle => 'बैटरी विवरण';

  @override
  String get detailTemperature => 'तापमान';

  @override
  String get detailVoltage => 'वोल्टेज';

  @override
  String get detailHealth => 'स्थिति';

  @override
  String get detailTechnology => 'तकनीक';

  @override
  String get detailCharger => 'पावर स्रोत';

  @override
  String get healthGood => 'अच्छी';

  @override
  String get healthOverheat => 'अधिक गर्म';

  @override
  String get healthDead => 'खराब';

  @override
  String get healthOverVoltage => 'अधिक वोल्टेज';

  @override
  String get healthCold => 'ठंडी';

  @override
  String get healthFailure => 'विफलता';

  @override
  String get healthUnknown => 'अज्ञात';

  @override
  String get sessionTitle => 'वर्तमान चार्जिंग सत्र';

  @override
  String get sessionNone => 'अभी चार्ज नहीं हो रही है।';

  @override
  String sessionStarted(String time) {
    return '$time पर शुरू हुआ';
  }

  @override
  String sessionGained(int from, int to) {
    return '$from% से $to%';
  }

  @override
  String sessionAlarms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अलार्म बजे',
      one: '1 अलार्म बजा',
      zero: 'अभी कोई अलार्म नहीं',
    );
    return '$_temp0';
  }

  @override
  String get warnNotificationsTitle => 'सूचनाएँ अवरुद्ध हैं';

  @override
  String get warnNotificationsBody =>
      'बैटरी निगरानी चालू रखने के लिए एंड्रॉइड को सूचना की अनुमति चाहिए।';

  @override
  String get warnBatteryOptimTitle => 'बैटरी ऑप्टिमाइज़ेशन चालू है';

  @override
  String get warnBatteryOptimBody =>
      'एंड्रॉइड पृष्ठभूमि में निगरानी रोक सकता है। भरोसेमंद अलार्म के लिए अप्रतिबंधित बैटरी उपयोग की अनुमति दें।';

  @override
  String get warnServiceStoppedTitle => 'निगरानी सेवा नहीं चल रही';

  @override
  String get warnServiceStoppedBody =>
      'इसे फिर से शुरू करने के लिए निगरानी बंद करके दोबारा चालू करें।';

  @override
  String get warnTtsTitle => 'इस भाषा के लिए आवाज़ उपलब्ध नहीं';

  @override
  String get warnTtsBody =>
      'अपने फ़ोन की टेक्स्ट-टू-स्पीच सेटिंग्स में वॉइस डेटा इंस्टॉल करें, अन्यथा अलार्म अंग्रेज़ी में बोलेगा।';

  @override
  String get actionTtsSettings => 'टेक्स्ट-टू-स्पीच सेटिंग्स';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get sectionVoice => 'आवाज़ घोषणा';

  @override
  String get sectionAlarm => 'अलार्म';

  @override
  String get sectionAlerts => 'सूचनाएँ';

  @override
  String get sectionStartup => 'शुरुआत';

  @override
  String get sectionAppearance => 'रूप';

  @override
  String get sectionData => 'डेटा';

  @override
  String get sectionAbout => 'परिचय';

  @override
  String get settingUserName => 'आपका नाम';

  @override
  String get settingUserNameHint => 'बोले जाने वाले संदेश में उपयोग होगा';

  @override
  String get settingUserNameEmpty => 'सेट नहीं है';

  @override
  String get settingVoiceMessage => 'घोषणा';

  @override
  String get settingVoiceEnabled => 'संदेश बोलें';

  @override
  String get settingVoiceEnabledBody =>
      'आपके फ़ोन के अंतर्निहित टेक्स्ट-टू-स्पीच का उपयोग करता है।';

  @override
  String get settingSpeechRate => 'बोलने की गति';

  @override
  String get settingSpeechPitch => 'आवाज़ की पिच';

  @override
  String get settingAlarmSound => 'अलार्म की ध्वनि';

  @override
  String get settingAlarmSoundDefault => 'डिफ़ॉल्ट अलार्म';

  @override
  String get settingSoundEnabled => 'अलार्म ध्वनि बजाएँ';

  @override
  String get settingAlarmInterval => 'हर बार दोहराएँ';

  @override
  String get settingAlarmVolume => 'अलार्म वॉल्यूम';

  @override
  String get settingVibration => 'कंपन';

  @override
  String get settingFlash => 'टॉर्च चमकाएँ';

  @override
  String get settingFlashUnavailable => 'इस डिवाइस में फ़्लैश नहीं है';

  @override
  String get settingVibrationUnavailable => 'इस डिवाइस में कंपन मोटर नहीं है';

  @override
  String get settingNotifications => 'अलार्म सूचना';

  @override
  String get settingNotificationsBody =>
      'अलार्म बजते समय बंद करने के बटन वाली सूचना दिखाता है। लगातार दिखने वाली मॉनिटर सूचना छिपाई नहीं जा सकती — निगरानी चालू रखने के लिए एंड्रॉइड को वह चाहिए।';

  @override
  String get settingAutoStart => 'निगरानी अपने आप शुरू करें';

  @override
  String get settingAutoStartBody =>
      'चार्जर जोड़ने पर निगरानी फिर से सक्रिय कर देता है।';

  @override
  String get settingAutoStartBoot => 'रीस्टार्ट के बाद शुरू करें';

  @override
  String get settingAutoStartBootBody =>
      'फ़ोन दोबारा चालू होने पर निगरानी फिर शुरू करें।';

  @override
  String get settingLanguage => 'भाषा';

  @override
  String get settingTheme => 'थीम';

  @override
  String get settingBatteryOptimization => 'पृष्ठभूमि प्रतिबंध';

  @override
  String get settingBatteryOptimizationOk =>
      'अप्रतिबंधित — अलार्म भरोसेमंद हैं';

  @override
  String get settingBatteryOptimizationBad =>
      'प्रतिबंधित — अलार्म में देरी हो सकती है';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'हल्की';

  @override
  String get themeDark => 'गहरी';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String intervalSeconds(int count) {
    return '$count सेकंड';
  }

  @override
  String get intervalMinute => '1 मिनट';

  @override
  String get voiceTitle => 'आवाज़ घोषणा';

  @override
  String get voiceMessageLabel => 'फ़ोन को क्या कहना चाहिए?';

  @override
  String get voiceMessageHelp =>
      'जोड़ने के लिए टैग पर टैप करें। संदेश बोलते समय टैग बदल दिए जाते हैं।';

  @override
  String get voiceTokenName => 'आपका नाम';

  @override
  String get voiceTokenLevel => 'बैटरी स्तर';

  @override
  String get voicePreviewTitle => 'पूर्वावलोकन';

  @override
  String get actionPlayPreview => 'पूर्वावलोकन चलाएँ';

  @override
  String get actionStopPreview => 'रोकें';

  @override
  String get voicePresets => 'सुझाव';

  @override
  String get voiceMessageEmpty => 'घोषणा खाली नहीं हो सकती।';

  @override
  String get voiceResetDefault => 'डिफ़ॉल्ट संदेश वापस लाएँ';

  @override
  String get soundTitle => 'अलार्म की ध्वनि';

  @override
  String get soundBuiltIn => 'इस डिवाइस पर';

  @override
  String get soundCustom => 'आपकी ध्वनियाँ';

  @override
  String get soundCustomEmpty =>
      'अपना अलार्म जोड़ने के लिए ऑडियो फ़ाइल आयात करें या अपनी आवाज़ रिकॉर्ड करें।';

  @override
  String get actionImportAudio => 'ऑडियो फ़ाइल आयात करें';

  @override
  String get actionRecordVoice => 'अपनी आवाज़ रिकॉर्ड करें';

  @override
  String get actionStopRecording => 'रिकॉर्डिंग रोकें';

  @override
  String get recordingInProgress =>
      'रिकॉर्डिंग जारी… पूरा होने पर रोकें दबाएँ।';

  @override
  String get recordingSaved => 'रिकॉर्डिंग सहेजी गई।';

  @override
  String get recordingFailed => 'रिकॉर्डिंग सहेजी नहीं जा सकी।';

  @override
  String get recordingPermission =>
      'अलार्म रिकॉर्ड करने के लिए माइक्रोफ़ोन की अनुमति चाहिए।';

  @override
  String get importFailed => 'वह फ़ाइल आयात नहीं हो सकी।';

  @override
  String get importCancelled => 'कोई फ़ाइल नहीं चुनी गई।';

  @override
  String soundDeleteConfirm(String name) {
    return '\"$name\" हटाएँ?';
  }

  @override
  String get soundDeleted => 'ध्वनि हटा दी गई।';

  @override
  String get soundInUseReset =>
      'अलार्म वापस डिफ़ॉल्ट ध्वनि पर सेट कर दिया गया।';

  @override
  String get historyTitle => 'चार्जिंग इतिहास';

  @override
  String get historyEmpty => 'अभी तक कोई चार्जिंग सत्र दर्ज नहीं हुआ।';

  @override
  String get historyEmptyBody => 'चार्जर लगाएँ, सत्र यहाँ दिखाई देगा।';

  @override
  String get actionClearHistory => 'इतिहास मिटाएँ';

  @override
  String get historyClearConfirm => 'सभी दर्ज चार्जिंग सत्र हटाएँ?';

  @override
  String get historyCleared => 'इतिहास मिटा दिया गया।';

  @override
  String get historyEntryDeleted => 'प्रविष्टि हटा दी गई।';

  @override
  String get historyInProgress => 'जारी है';

  @override
  String historyReachedFull(String duration) {
    return '$duration में 100% तक पहुँचा';
  }

  @override
  String get historyNeverFull => '100% तक नहीं पहुँचा';

  @override
  String historyPluggedFor(String duration) {
    return '$duration तक लगा रहा';
  }

  @override
  String historyAlarms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अलार्म',
      one: '1 अलार्म',
      zero: 'कोई अलार्म नहीं',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'आँकड़े';

  @override
  String get statsDaily => 'आज';

  @override
  String get statsWeekly => 'इस सप्ताह';

  @override
  String get statsMonthly => 'इस महीने';

  @override
  String get statsNoData => 'इस अवधि का कोई चार्जिंग डेटा नहीं है।';

  @override
  String get statsSessions => 'चार्जिंग सत्र';

  @override
  String get statsFullCharges => '100% तक पहुँचे';

  @override
  String get statsAvgChargeTime => 'पूरा होने का औसत समय';

  @override
  String get statsAvgPluggedTime => 'औसत प्लग-इन समय';

  @override
  String get statsTotalAlarms => 'बजाए गए अलार्म';

  @override
  String get statsAvgStartLevel => 'प्लग लगाते समय औसत स्तर';

  @override
  String get statsEnergyGained => 'औसत चार्ज वृद्धि';

  @override
  String get statsChartTitle => 'प्रतिदिन सत्र';

  @override
  String get aboutTitle => 'परिचय';

  @override
  String aboutVersion(String version, String build) {
    return 'संस्करण $version ($build)';
  }

  @override
  String aboutDevice(String release, int sdk) {
    return 'एंड्रॉइड $release (API $sdk)';
  }

  @override
  String get aboutOfflineTitle => 'पूरी तरह ऑफ़लाइन काम करता है';

  @override
  String get aboutOfflineBody =>
      'इस ऐप के पास इंटरनेट अनुमति नहीं है। आपका नाम, संदेश, रिकॉर्डिंग और इतिहास कभी फ़ोन से बाहर नहीं जाते।';

  @override
  String get aboutPermissionsTitle => 'उपयोग की गई अनुमतियाँ';

  @override
  String get aboutHowItWorksTitle => 'यह कैसे काम करता है';

  @override
  String get aboutHowItWorksBody =>
      'एक फ़ोरग्राउंड सेवा सिस्टम के बैटरी ब्रॉडकास्ट पर नज़र रखती है। चार्जर लगे होने पर जैसे ही स्तर 100% पहुँचता है, अलार्म ध्वनि, बोला गया संदेश, कंपन और टॉर्च आपके चुने अंतराल पर तब तक दोहराए जाते हैं जब तक आप चार्जर न निकालें।';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours घं $minutes मि';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes मि';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds से';
  }

  @override
  String get valueUnavailable => '—';

  @override
  String percentValue(int value) {
    return '$value%';
  }
}
