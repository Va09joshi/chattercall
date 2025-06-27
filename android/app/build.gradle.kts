plugins {
    id("com.android.application")
    // --- FlutterFire / Firebase ---
    id("com.google.gms.google-services")          // Google Services
    // --------------------------------
    id("kotlin-android")
    // Flutter Gradle plugin *must* come last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.chat_application"

    // These two are provided by the Flutter plugin; if you prefer,
    // replace with concrete values such as 34 for compileSdk
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion          // keep only one ndkVersion line

    defaultConfig {
        applicationId = "com.example.chat_application"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            // TODO: replace with your real signing config
            signingConfig = signingConfigs.getByName("debug")
            // If you enable R8/Proguard later, add `isMinifyEnabled = true`
        }
    }
}

repositories {
    // Needed for com.github.yalantis:ucrop
    maven { url = uri("https://jitpack.io") }
}

dependencies {
    implementation("com.github.yalantis:ucrop:2.2.8")   // latest stable at time of writing
    // …other app dependencies (Flutter automatically injects its AARs)
}

flutter {
    source = "../.."   // leave as generated
}
