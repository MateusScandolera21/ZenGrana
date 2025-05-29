plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.controle_financeiro"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.controle_financeiro"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Certifique-se de que as dependências do Flutter estejam aqui, se houver
    // Exemplo: testImplementation(kotlin("test-junit"))
    // implementation(platform("androidx.compose:compose-bom:2023.08.00")) // Exemplo, se você usa Compose

    // Suas dependências do Material Design e AppCompat (SINTAXE CORRETA PARA KTS)
    implementation("androidx.appcompat:appcompat:1.6.1") // OU a versão mais recente
    implementation("com.google.android.material:material:1.11.0") // OU a versão mais recente

    // ... outras dependências que já existiam ...
}