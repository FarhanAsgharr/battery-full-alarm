# The Flutter Gradle plugin already supplies the rules for the engine and for
# registered plugins. These entries cover this app's own native surface.

# Entry points reached only by the framework, never by Kotlin call sites.
-keep class com.hananideas.batteryalarm.MainActivity { *; }
-keep class com.hananideas.batteryalarm.service.** { *; }

# org.json ships with the platform; nothing to strip, but keep reflection-free.
-dontwarn org.json.**

# Keep line numbers so release crash reports stay readable.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
