plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Only if using Firebase
}

android {
    namespace = "com.example.front_end"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.front_end"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    // Get Flutter version by running: flutter --version
    val flutterVersion = "1.0.0-<your-actual-flutter-version>"
    
    // Flutter dependencies
    debugImplementation("com.google.flutter:flutter_embedding_debug:$flutterVersion")
    profileImplementation("com.google.flutter:flutter_embedding_profile:$flutterVersion")
    releaseImplementation("com.google.flutter:flutter_embedding_release:$flutterVersion")

    // Core dependencies
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.0")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")

    // Firebase (if using)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
}