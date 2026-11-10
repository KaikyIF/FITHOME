plugins {
    id("com.android.application")
    // Aplica o plugin do Flutter depois dos plugins Android e Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.fithome.fithome"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Defina um identificador único para o aplicativo (https://developer.android.com/studio/build/application-id.html).
        applicationId = "br.com.fithome.fithome"
        // Ajuste as versões do SDK conforme os requisitos do aplicativo.
        // Documentação https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Configure a assinatura para a distribuição do aplicativo.
            // Usa as chaves de depuração para executar `flutter run --release` durante os testes.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
