plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") version "2.1.0"



    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // Add the Google services Gradle plugin for Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.flutter_application_1" // Ensure this matches your Firebase project
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Unique Application ID (Change it if needed)
        applicationId = "com.example.flutter_application_1"

        // Minimum and target SDK versions
        minSdk = 23 
        targetSdk = flutter.targetSdkVersion

        // App Version
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true  // ✅ Enable for proper resource shrinking
            isShrinkResources = true // ✅ Prevents unnecessary resources
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Prevent duplicate files error when using Firebase
    packagingOptions {
        resources {
            excludes += "/META-INF/*"
        }
    }
}

flutter {
    source = "../.."
}

// Firebase Dependencies
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))

    // Firebase SDKs
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-database")
}
