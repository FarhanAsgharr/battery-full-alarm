import java.util.Properties

plugins {
    id("com.android.application")
    // Kotlin comes from AGP's built-in support — no Kotlin Gradle Plugin, per
    // https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

/**
 * Release signing is read from `android/key.properties`, which is git-ignored and never
 * committed. When it is absent the release build falls back to the debug key so a fresh
 * clone can still run `flutter build apk --release` — see BUILD.md for generating a real
 * upload key before publishing.
 */
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "com.hananideas.batteryalarm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.hananideas.batteryalarm"
        // API 26 gives NotificationChannel, VibrationEffect and AudioFocusRequest
        // unconditionally, which keeps the alarm path free of compatibility branches.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
    }

    testOptions {
        unitTests.isReturnDefaultValues = true
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // JVM unit tests for the pure monitoring logic (see src/test/kotlin).
    testImplementation("junit:junit:4.13.2")
    // org.json ships with Android but is stubbed out in JVM unit tests. Adding the
    // real implementation lets the serialisation tests exercise actual JSON.
    testImplementation("org.json:json:20250107")
}

flutter {
    source = "../.."
}
