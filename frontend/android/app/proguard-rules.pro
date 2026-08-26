# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Play / Maps / Auth
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Secure storage / EncryptedSharedPreferences
-keep class androidx.security.crypto.** { *; }
-keep class com.google.crypto.tink.** { *; }

# Supabase / OkHttp (reflection)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class supabase.** { *; }

# native_geofence
-keep class com.chunkytofustudios.native_geofence.** { *; }

# Keep attributes needed when minify is re-enabled for Play
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable
