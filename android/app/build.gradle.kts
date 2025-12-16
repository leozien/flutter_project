plugins {
    id("com.android.application")
    id("kotlin-android")
    // Plugin Flutter
    id("dev.flutter.flutter-gradle-plugin")
    // Plugin Google Services (Wajib untuk Firebase)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // Pastikan ID ini sama dengan yang didaftarkan di Firebase
        applicationId = "com.example.flutter_application_1"
        
        // Min SDK harus minimal 23 untuk Firebase terbaru
        minSdk = 23 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Tambahkan dependency jika diperlukan di sini (implementations)
    // Tapi untuk firebase_core dll, biasanya otomatis dari pubspec.yaml
}