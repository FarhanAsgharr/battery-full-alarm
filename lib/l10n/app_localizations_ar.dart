// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'منبّه اكتمال البطارية';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navHistory => 'السجل';

  @override
  String get navStats => 'الإحصائيات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionReset => 'إعادة تعيين';

  @override
  String get actionOpenSettings => 'فتح الإعدادات';

  @override
  String get actionAllow => 'السماح';

  @override
  String get actionNotNow => 'ليس الآن';

  @override
  String get monitoringOn => 'المراقبة مفعّلة';

  @override
  String get monitoringOff => 'المراقبة متوقفة';

  @override
  String get monitoringOnBody => 'سيتم تنبيهك فور وصول البطارية إلى 100%.';

  @override
  String get monitoringOffBody =>
      'فعّل هذا الخيار ليتم تنبيهك عند اكتمال الشحن.';

  @override
  String get statusCharging => 'قيد الشحن';

  @override
  String get statusFull => 'مشحونة بالكامل';

  @override
  String get statusDischarging => 'تعمل على البطارية';

  @override
  String get chargerAc => 'شاحن كهربائي';

  @override
  String get chargerUsb => 'USB';

  @override
  String get chargerWireless => 'لاسلكي';

  @override
  String get chargerNone => 'غير متصل';

  @override
  String get chargerOther => 'مصدر طاقة خارجي';

  @override
  String get alarmRinging => 'المنبّه يعمل';

  @override
  String get alarmRingingBody => 'افصل الشاحن، أو أوقفه من هنا.';

  @override
  String get actionStopAlarm => 'إيقاف المنبّه';

  @override
  String get actionTestAlarm => 'تجربة المنبّه';

  @override
  String get testAlarmStarted => 'يتم تشغيل دورة منبّه واحدة…';

  @override
  String get detailsTitle => 'تفاصيل البطارية';

  @override
  String get detailTemperature => 'درجة الحرارة';

  @override
  String get detailVoltage => 'الجهد';

  @override
  String get detailHealth => 'الحالة';

  @override
  String get detailTechnology => 'التقنية';

  @override
  String get detailCharger => 'مصدر الطاقة';

  @override
  String get healthGood => 'جيدة';

  @override
  String get healthOverheat => 'ارتفاع في الحرارة';

  @override
  String get healthDead => 'تالفة';

  @override
  String get healthOverVoltage => 'جهد زائد';

  @override
  String get healthCold => 'باردة';

  @override
  String get healthFailure => 'عطل';

  @override
  String get healthUnknown => 'غير معروفة';

  @override
  String get sessionTitle => 'جلسة الشحن الحالية';

  @override
  String get sessionNone => 'لا يتم الشحن حالياً.';

  @override
  String sessionStarted(String time) {
    return 'بدأت الساعة $time';
  }

  @override
  String sessionGained(int from, int to) {
    return 'من $from% إلى $to%';
  }

  @override
  String sessionAlarms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تشغيل $count منبّهات',
      one: 'تم تشغيل منبّه واحد',
      zero: 'لا توجد منبّهات بعد',
    );
    return '$_temp0';
  }

  @override
  String get warnNotificationsTitle => 'الإشعارات محظورة';

  @override
  String get warnNotificationsBody =>
      'يحتاج أندرويد إلى إذن الإشعارات لاستمرار مراقبة البطارية.';

  @override
  String get warnBatteryOptimTitle => 'تحسين البطارية مفعّل';

  @override
  String get warnBatteryOptimBody =>
      'قد يوقف أندرويد المراقبة في الخلفية. اسمح باستخدام البطارية بدون قيود لضمان عمل المنبّه.';

  @override
  String get warnServiceStoppedTitle => 'خدمة المراقبة لا تعمل';

  @override
  String get warnServiceStoppedBody =>
      'أوقف المراقبة ثم فعّلها مرة أخرى لإعادة تشغيلها.';

  @override
  String get warnTtsTitle => 'الصوت غير متوفر لهذه اللغة';

  @override
  String get warnTtsBody =>
      'ثبّت بيانات الصوت من إعدادات تحويل النص إلى كلام في جهازك، وإلا سينطق المنبّه بالإنجليزية.';

  @override
  String get actionTtsSettings => 'إعدادات تحويل النص إلى كلام';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sectionVoice => 'الإعلان الصوتي';

  @override
  String get sectionAlarm => 'المنبّه';

  @override
  String get sectionAlerts => 'التنبيهات';

  @override
  String get sectionStartup => 'بدء التشغيل';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get sectionData => 'البيانات';

  @override
  String get sectionAbout => 'حول التطبيق';

  @override
  String get settingUserName => 'اسمك';

  @override
  String get settingUserNameHint => 'يُستخدم في الرسالة المنطوقة';

  @override
  String get settingUserNameEmpty => 'غير محدد';

  @override
  String get settingVoiceMessage => 'نص الإعلان';

  @override
  String get settingVoiceEnabled => 'نطق الرسالة';

  @override
  String get settingVoiceEnabledBody =>
      'يستخدم محرك تحويل النص إلى كلام المدمج في هاتفك.';

  @override
  String get settingSpeechRate => 'سرعة النطق';

  @override
  String get settingSpeechPitch => 'طبقة الصوت';

  @override
  String get settingAlarmSound => 'صوت المنبّه';

  @override
  String get settingAlarmSoundDefault => 'المنبّه الافتراضي';

  @override
  String get settingSoundEnabled => 'تشغيل صوت المنبّه';

  @override
  String get settingAlarmInterval => 'التكرار كل';

  @override
  String get settingAlarmVolume => 'مستوى صوت المنبّه';

  @override
  String get settingVibration => 'الاهتزاز';

  @override
  String get settingFlash => 'وميض الكشاف';

  @override
  String get settingFlashUnavailable => 'لا يوجد كشاف في هذا الجهاز';

  @override
  String get settingVibrationUnavailable => 'لا يوجد محرك اهتزاز في هذا الجهاز';

  @override
  String get settingNotifications => 'إشعار المنبّه';

  @override
  String get settingNotificationsBody =>
      'يعرض إشعاراً بزر إيقاف أثناء تشغيل المنبّه. أما إشعار المراقبة المستمر فلا يمكن إخفاؤه — يحتاجه أندرويد لإبقاء المراقبة تعمل.';

  @override
  String get settingAutoStart => 'بدء المراقبة تلقائياً';

  @override
  String get settingAutoStartBody => 'يعيد تفعيل المراقبة عند توصيل الشاحن.';

  @override
  String get settingAutoStartBoot => 'البدء بعد إعادة التشغيل';

  @override
  String get settingAutoStartBootBody =>
      'استئناف المراقبة عند إعادة تشغيل الهاتف.';

  @override
  String get settingLanguage => 'اللغة';

  @override
  String get settingTheme => 'السمة';

  @override
  String get settingBatteryOptimization => 'قيود الخلفية';

  @override
  String get settingBatteryOptimizationOk => 'بدون قيود — المنبّه موثوق';

  @override
  String get settingBatteryOptimizationBad => 'مقيّد — قد يتأخر المنبّه';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتحة';

  @override
  String get themeDark => 'داكنة';

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
    return '$count ثانية';
  }

  @override
  String get intervalMinute => 'دقيقة واحدة';

  @override
  String get voiceTitle => 'الإعلان الصوتي';

  @override
  String get voiceMessageLabel => 'ماذا يقول الهاتف؟';

  @override
  String get voiceMessageHelp =>
      'اضغط على وسم لإدراجه. تُستبدل الوسوم عند نطق الرسالة.';

  @override
  String get voiceTokenName => 'اسمك';

  @override
  String get voiceTokenLevel => 'مستوى البطارية';

  @override
  String get voicePreviewTitle => 'معاينة';

  @override
  String get actionPlayPreview => 'تشغيل المعاينة';

  @override
  String get actionStopPreview => 'إيقاف';

  @override
  String get voicePresets => 'اقتراحات';

  @override
  String get voiceMessageEmpty => 'لا يمكن ترك نص الإعلان فارغاً.';

  @override
  String get voiceResetDefault => 'استعادة الرسالة الافتراضية';

  @override
  String get soundTitle => 'صوت المنبّه';

  @override
  String get soundBuiltIn => 'على هذا الجهاز';

  @override
  String get soundCustom => 'أصواتك';

  @override
  String get soundCustomEmpty =>
      'استورد ملفاً صوتياً أو سجّل صوتك لإضافة منبّه خاص بك.';

  @override
  String get actionImportAudio => 'استيراد ملف صوتي';

  @override
  String get actionRecordVoice => 'تسجيل صوتك';

  @override
  String get actionStopRecording => 'إيقاف التسجيل';

  @override
  String get recordingInProgress => 'جارٍ التسجيل… اضغط إيقاف عند الانتهاء.';

  @override
  String get recordingSaved => 'تم حفظ التسجيل.';

  @override
  String get recordingFailed => 'تعذّر حفظ التسجيل.';

  @override
  String get recordingPermission => 'يلزم إذن الميكروفون لتسجيل منبّه.';

  @override
  String get importFailed => 'تعذّر استيراد هذا الملف.';

  @override
  String get importCancelled => 'لم يتم اختيار أي ملف.';

  @override
  String soundDeleteConfirm(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get soundDeleted => 'تم حذف الصوت.';

  @override
  String get soundInUseReset => 'تمت إعادة المنبّه إلى الصوت الافتراضي.';

  @override
  String get historyTitle => 'سجل الشحن';

  @override
  String get historyEmpty => 'لم يتم تسجيل أي جلسة شحن بعد.';

  @override
  String get historyEmptyBody => 'وصّل الشاحن وستظهر الجلسة هنا.';

  @override
  String get actionClearHistory => 'مسح السجل';

  @override
  String get historyClearConfirm => 'حذف جميع جلسات الشحن المسجّلة؟';

  @override
  String get historyCleared => 'تم مسح السجل.';

  @override
  String get historyEntryDeleted => 'تم حذف العنصر.';

  @override
  String get historyInProgress => 'جارية';

  @override
  String historyReachedFull(String duration) {
    return 'وصلت إلى 100% خلال $duration';
  }

  @override
  String get historyNeverFull => 'لم تصل إلى 100%';

  @override
  String historyPluggedFor(String duration) {
    return 'بقيت موصولة $duration';
  }

  @override
  String historyAlarms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منبّهات',
      one: 'منبّه واحد',
      zero: 'بدون منبّهات',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get statsDaily => 'اليوم';

  @override
  String get statsWeekly => 'هذا الأسبوع';

  @override
  String get statsMonthly => 'هذا الشهر';

  @override
  String get statsNoData => 'لا توجد بيانات شحن لهذه الفترة بعد.';

  @override
  String get statsSessions => 'جلسات الشحن';

  @override
  String get statsFullCharges => 'وصلت إلى 100%';

  @override
  String get statsAvgChargeTime => 'متوسط زمن الوصول للاكتمال';

  @override
  String get statsAvgPluggedTime => 'متوسط زمن التوصيل';

  @override
  String get statsTotalAlarms => 'المنبّهات التي شُغّلت';

  @override
  String get statsAvgStartLevel => 'متوسط المستوى عند التوصيل';

  @override
  String get statsEnergyGained => 'متوسط الشحن المكتسب';

  @override
  String get statsChartTitle => 'الجلسات لكل يوم';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String aboutVersion(String version, String build) {
    return 'الإصدار $version ($build)';
  }

  @override
  String aboutDevice(String release, int sdk) {
    return 'أندرويد $release (API $sdk)';
  }

  @override
  String get aboutOfflineTitle => 'يعمل دون اتصال بالكامل';

  @override
  String get aboutOfflineBody =>
      'لا يملك هذا التطبيق إذن الإنترنت. اسمك ورسالتك وتسجيلاتك وسجلك لا تغادر الهاتف أبداً.';

  @override
  String get aboutPermissionsTitle => 'الأذونات المستخدمة';

  @override
  String get aboutHowItWorksTitle => 'كيف يعمل';

  @override
  String get aboutHowItWorksBody =>
      'تراقب خدمة أمامية بث البطارية في النظام. وعند بلوغ المستوى 100% مع توصيل الشاحن، يتكرر صوت المنبّه والرسالة المنطوقة والاهتزاز والكشاف بالفاصل الزمني الذي اخترته حتى تفصل الشاحن.';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds ث';
  }

  @override
  String get valueUnavailable => '—';

  @override
  String percentValue(int value) {
    return '$value%';
  }
}
