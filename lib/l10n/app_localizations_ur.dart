// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'بیٹری فُل الارم';

  @override
  String get navHome => 'ہوم';

  @override
  String get navHistory => 'تاریخ';

  @override
  String get navStats => 'اعداد و شمار';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get actionSave => 'محفوظ کریں';

  @override
  String get actionCancel => 'منسوخ کریں';

  @override
  String get actionDelete => 'حذف کریں';

  @override
  String get actionClose => 'بند کریں';

  @override
  String get actionReset => 'ری سیٹ';

  @override
  String get actionOpenSettings => 'ترتیبات کھولیں';

  @override
  String get actionAllow => 'اجازت دیں';

  @override
  String get actionNotNow => 'ابھی نہیں';

  @override
  String get monitoringOn => 'نگرانی فعال ہے';

  @override
  String get monitoringOff => 'نگرانی بند ہے';

  @override
  String get monitoringOnBody => 'بیٹری 100% ہوتے ہی آپ کو اطلاع دی جائے گی۔';

  @override
  String get monitoringOffBody =>
      'چارجنگ مکمل ہونے پر اطلاع کے لیے اسے آن کریں۔';

  @override
  String get statusCharging => 'چارج ہو رہی ہے';

  @override
  String get statusFull => 'مکمل چارج';

  @override
  String get statusDischarging => 'بیٹری پر';

  @override
  String get chargerAc => 'اے سی چارجر';

  @override
  String get chargerUsb => 'یو ایس بی';

  @override
  String get chargerWireless => 'وائرلیس';

  @override
  String get chargerNone => 'منسلک نہیں';

  @override
  String get chargerOther => 'بیرونی پاور';

  @override
  String get alarmRinging => 'الارم بج رہا ہے';

  @override
  String get alarmRingingBody => 'چارجر نکال دیں، یا یہاں سے بند کریں۔';

  @override
  String get actionStopAlarm => 'الارم بند کریں';

  @override
  String get actionTestAlarm => 'الارم آزمائیں';

  @override
  String get testAlarmStarted => 'ایک الارم سائیکل چل رہا ہے…';

  @override
  String get detailsTitle => 'بیٹری کی تفصیلات';

  @override
  String get detailTemperature => 'درجہ حرارت';

  @override
  String get detailVoltage => 'وولٹیج';

  @override
  String get detailHealth => 'صحت';

  @override
  String get detailTechnology => 'ٹیکنالوجی';

  @override
  String get detailCharger => 'پاور ذریعہ';

  @override
  String get healthGood => 'بہتر';

  @override
  String get healthOverheat => 'زیادہ گرم';

  @override
  String get healthDead => 'ناکارہ';

  @override
  String get healthOverVoltage => 'زائد وولٹیج';

  @override
  String get healthCold => 'ٹھنڈی';

  @override
  String get healthFailure => 'خرابی';

  @override
  String get healthUnknown => 'نامعلوم';

  @override
  String get sessionTitle => 'موجودہ چارجنگ سیشن';

  @override
  String get sessionNone => 'اس وقت چارج نہیں ہو رہی۔';

  @override
  String sessionStarted(String time) {
    return '$time پر شروع ہوا';
  }

  @override
  String sessionGained(int from, int to) {
    return '$from% سے $to%';
  }

  @override
  String sessionAlarms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count الارم بجے',
      one: '1 الارم بجا',
      zero: 'ابھی کوئی الارم نہیں',
    );
    return '$_temp0';
  }

  @override
  String get warnNotificationsTitle => 'اطلاعات بلاک ہیں';

  @override
  String get warnNotificationsBody =>
      'بیٹری کی نگرانی جاری رکھنے کے لیے اینڈرائیڈ کو اطلاعات کی اجازت درکار ہے۔';

  @override
  String get warnBatteryOptimTitle => 'بیٹری آپٹیمائزیشن فعال ہے';

  @override
  String get warnBatteryOptimBody =>
      'اینڈرائیڈ پس منظر میں نگرانی روک سکتا ہے۔ قابلِ اعتماد الارم کے لیے غیر محدود بیٹری استعمال کی اجازت دیں۔';

  @override
  String get warnServiceStoppedTitle => 'نگرانی کی سروس نہیں چل رہی';

  @override
  String get warnServiceStoppedBody =>
      'اسے دوبارہ شروع کرنے کے لیے نگرانی بند کر کے دوبارہ آن کریں۔';

  @override
  String get warnTtsTitle => 'اس زبان کے لیے آواز دستیاب نہیں';

  @override
  String get warnTtsBody =>
      'اپنے فون کی ٹیکسٹ ٹو اسپیچ ترتیبات میں وائس ڈیٹا انسٹال کریں، ورنہ الارم انگریزی میں بولے گا۔';

  @override
  String get actionTtsSettings => 'ٹیکسٹ ٹو اسپیچ ترتیبات';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get sectionVoice => 'صوتی اعلان';

  @override
  String get sectionAlarm => 'الارم';

  @override
  String get sectionAlerts => 'انتباہات';

  @override
  String get sectionStartup => 'آغاز';

  @override
  String get sectionAppearance => 'ظاہری شکل';

  @override
  String get sectionData => 'ڈیٹا';

  @override
  String get sectionAbout => 'تعارف';

  @override
  String get settingUserName => 'آپ کا نام';

  @override
  String get settingUserNameHint => 'بولے جانے والے پیغام میں استعمال ہوگا';

  @override
  String get settingUserNameEmpty => 'مقرر نہیں';

  @override
  String get settingVoiceMessage => 'اعلان';

  @override
  String get settingVoiceEnabled => 'پیغام بولیں';

  @override
  String get settingVoiceEnabledBody =>
      'آپ کے فون کی بلٹ اِن ٹیکسٹ ٹو اسپیچ استعمال کرتا ہے۔';

  @override
  String get settingSpeechRate => 'بولنے کی رفتار';

  @override
  String get settingSpeechPitch => 'آواز کی پچ';

  @override
  String get settingAlarmSound => 'الارم کی آواز';

  @override
  String get settingAlarmSoundDefault => 'ڈیفالٹ الارم';

  @override
  String get settingSoundEnabled => 'الارم کی آواز چلائیں';

  @override
  String get settingAlarmInterval => 'دہرانے کا وقفہ';

  @override
  String get settingAlarmVolume => 'الارم کی آواز کی سطح';

  @override
  String get settingVibration => 'وائبریشن';

  @override
  String get settingFlash => 'ٹارچ چمکائیں';

  @override
  String get settingFlashUnavailable => 'اس ڈیوائس میں فلیش نہیں ہے';

  @override
  String get settingVibrationUnavailable =>
      'اس ڈیوائس میں وائبریشن موٹر نہیں ہے';

  @override
  String get settingNotifications => 'الارم کی اطلاع';

  @override
  String get settingNotificationsBody =>
      'الارم بجنے کے دوران بند کرنے کے بٹن کے ساتھ اطلاع دکھاتا ہے۔ مسلسل نگرانی والی اطلاع چھپائی نہیں جا سکتی — اینڈرائیڈ کو نگرانی جاری رکھنے کے لیے یہ درکار ہے۔';

  @override
  String get settingAutoStart => 'خودکار نگرانی شروع کریں';

  @override
  String get settingAutoStartBody =>
      'چارجر لگانے پر نگرانی دوبارہ فعال کر دیتا ہے۔';

  @override
  String get settingAutoStartBoot => 'ری اسٹارٹ کے بعد شروع کریں';

  @override
  String get settingAutoStartBootBody =>
      'فون دوبارہ چالو ہونے پر نگرانی بحال کریں۔';

  @override
  String get settingLanguage => 'زبان';

  @override
  String get settingTheme => 'تھیم';

  @override
  String get settingBatteryOptimization => 'پس منظر کی پابندیاں';

  @override
  String get settingBatteryOptimizationOk =>
      'غیر محدود — الارم قابلِ اعتماد ہیں';

  @override
  String get settingBatteryOptimizationBad =>
      'محدود — الارم میں تاخیر ہو سکتی ہے';

  @override
  String get themeSystem => 'سسٹم';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تاریک';

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
    return '$count سیکنڈ';
  }

  @override
  String get intervalMinute => '1 منٹ';

  @override
  String get voiceTitle => 'صوتی اعلان';

  @override
  String get voiceMessageLabel => 'فون کو کیا کہنا چاہیے؟';

  @override
  String get voiceMessageHelp =>
      'داخل کرنے کے لیے ٹیگ پر ٹیپ کریں۔ پیغام بولتے وقت ٹیگ تبدیل ہو جاتے ہیں۔';

  @override
  String get voiceTokenName => 'آپ کا نام';

  @override
  String get voiceTokenLevel => 'بیٹری کی سطح';

  @override
  String get voicePreviewTitle => 'جھلک';

  @override
  String get actionPlayPreview => 'جھلک چلائیں';

  @override
  String get actionStopPreview => 'بند کریں';

  @override
  String get voicePresets => 'تجاویز';

  @override
  String get voiceMessageEmpty => 'اعلان خالی نہیں ہو سکتا۔';

  @override
  String get voiceResetDefault => 'ڈیفالٹ پیغام بحال کریں';

  @override
  String get soundTitle => 'الارم کی آواز';

  @override
  String get soundBuiltIn => 'اس ڈیوائس پر';

  @override
  String get soundCustom => 'آپ کی آوازیں';

  @override
  String get soundCustomEmpty =>
      'اپنا الارم شامل کرنے کے لیے آڈیو فائل درآمد کریں یا اپنی آواز ریکارڈ کریں۔';

  @override
  String get actionImportAudio => 'آڈیو فائل درآمد کریں';

  @override
  String get actionRecordVoice => 'اپنی آواز ریکارڈ کریں';

  @override
  String get actionStopRecording => 'ریکارڈنگ روکیں';

  @override
  String get recordingInProgress =>
      'ریکارڈنگ جاری… مکمل ہونے پر روکیں پر ٹیپ کریں۔';

  @override
  String get recordingSaved => 'ریکارڈنگ محفوظ ہو گئی۔';

  @override
  String get recordingFailed => 'ریکارڈنگ محفوظ نہیں ہو سکی۔';

  @override
  String get recordingPermission =>
      'الارم ریکارڈ کرنے کے لیے مائیکروفون کی اجازت درکار ہے۔';

  @override
  String get importFailed => 'یہ فائل درآمد نہیں ہو سکی۔';

  @override
  String get importCancelled => 'کوئی فائل منتخب نہیں کی گئی۔';

  @override
  String get historyTitle => 'چارجنگ کی تاریخ';

  @override
  String get historyEmpty => 'ابھی کوئی چارجنگ سیشن ریکارڈ نہیں ہوا۔';

  @override
  String get historyEmptyBody => 'چارجر لگائیں، سیشن یہاں ظاہر ہوگا۔';

  @override
  String get actionClearHistory => 'تاریخ صاف کریں';

  @override
  String get historyClearConfirm => 'تمام ریکارڈ شدہ چارجنگ سیشن حذف کریں؟';

  @override
  String get historyCleared => 'تاریخ صاف ہو گئی۔';

  @override
  String get historyEntryDeleted => 'اندراج حذف ہو گیا۔';

  @override
  String get historyInProgress => 'جاری ہے';

  @override
  String historyReachedFull(String duration) {
    return '$duration میں 100% تک پہنچا';
  }

  @override
  String get historyNeverFull => '100% تک نہیں پہنچا';

  @override
  String historyPluggedFor(String duration) {
    return '$duration تک لگا رہا';
  }

  @override
  String historyAlarms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count الارم',
      one: '1 الارم',
      zero: 'کوئی الارم نہیں',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'اعداد و شمار';

  @override
  String get statsDaily => 'آج';

  @override
  String get statsWeekly => 'اس ہفتے';

  @override
  String get statsMonthly => 'اس مہینے';

  @override
  String get statsNoData => 'اس مدت کا کوئی چارجنگ ڈیٹا نہیں۔';

  @override
  String get statsSessions => 'چارجنگ سیشنز';

  @override
  String get statsFullCharges => '100% تک پہنچے';

  @override
  String get statsAvgChargeTime => 'مکمل ہونے کا اوسط وقت';

  @override
  String get statsAvgPluggedTime => 'اوسط پلگ اِن وقت';

  @override
  String get statsTotalAlarms => 'بجائے گئے الارم';

  @override
  String get statsAvgStartLevel => 'پلگ لگاتے وقت اوسط سطح';

  @override
  String get statsEnergyGained => 'اوسط چارج اضافہ';

  @override
  String get statsChartTitle => 'روزانہ سیشنز';

  @override
  String get aboutTitle => 'تعارف';

  @override
  String aboutVersion(String version, String build) {
    return 'ورژن $version ($build)';
  }

  @override
  String aboutDevice(String release, int sdk) {
    return 'اینڈرائیڈ $release (API $sdk)';
  }

  @override
  String get aboutOfflineTitle => 'مکمل طور پر آف لائن کام کرتا ہے';

  @override
  String get aboutOfflineBody =>
      'اس ایپ کو انٹرنیٹ کی اجازت نہیں ہے۔ آپ کا نام، پیغام، ریکارڈنگز اور تاریخ کبھی فون سے باہر نہیں جاتے۔';

  @override
  String get aboutPermissionsTitle => 'استعمال شدہ اجازتیں';

  @override
  String get aboutHowItWorksTitle => 'یہ کیسے کام کرتا ہے';

  @override
  String get aboutHowItWorksBody =>
      'ایک فورگراؤنڈ سروس سسٹم کے بیٹری براڈکاسٹ کو دیکھتی ہے۔ چارجر لگے ہونے کی حالت میں جیسے ہی سطح 100% ہوتی ہے، الارم کی آواز، بولا گیا پیغام، وائبریشن اور ٹارچ آپ کے منتخب وقفے سے دہرائے جاتے ہیں جب تک آپ چارجر نہ نکال دیں۔';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours گھنٹے $minutes منٹ';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes منٹ';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds سیکنڈ';
  }

  @override
  String get valueUnavailable => '—';

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get soundDeleteTitle => 'الارم کی آواز حذف کریں؟';

  @override
  String get soundDeleteMessage =>
      'کیا آپ واقعی یہ الارم آواز ہٹانا چاہتے ہیں؟';

  @override
  String get soundDeleteDeviceNote =>
      'یہ آپ کی ڈیوائس کی رنگ ٹون ہے۔ اسے صرف اس فہرست سے چھپایا جائے گا، فون سے حذف نہیں کیا جائے گا، اور آپ اسے ترتیبات سے بحال کر سکتے ہیں۔';

  @override
  String get soundDeletedFile => 'آواز حذف ہو گئی۔';

  @override
  String get soundHiddenFromList => 'آواز چھپا دی گئی۔ ترتیبات سے بحال کریں۔';

  @override
  String get soundActiveFallback =>
      'یہ آپ کی الارم آواز تھی، اس لیے الارم واپس ڈیوائس کی ڈیفالٹ آواز پر منتقل ہو گیا۔';

  @override
  String get soundNoneTitle => 'فہرست میں کوئی آواز نہیں';

  @override
  String get soundNoneBody =>
      'الارم آپ کی ڈیوائس کی ڈیفالٹ آواز استعمال کرے گا۔ کوئی اور آواز منتخب کرنے کے لیے فہرست بحال کریں۔';

  @override
  String get settingRestoreSounds => 'ڈیفالٹ آوازیں بحال کریں';

  @override
  String get settingRestoreSoundsNone => 'کچھ چھپا ہوا نہیں';

  @override
  String settingRestoreSoundsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آوازیں چھپی ہوئی',
      one: '1 آواز چھپی ہوئی',
    );
    return '$_temp0';
  }

  @override
  String get restoreSoundsConfirm =>
      'کیا آپ کی چھپائی ہوئی تمام الارم آوازیں واپس لائی جائیں؟';

  @override
  String soundsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آوازیں بحال ہو گئیں',
      one: '1 آواز بحال ہو گئی',
      zero: 'بحال کرنے کو کچھ نہیں',
    );
    return '$_temp0';
  }
}
