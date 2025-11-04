# ustam Mobile App - ProGuard Rules
# Keep Flutter and Dart classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Socket.io classes
-keep class io.socket.** { *; }

# Keep HTTP classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep JSON serialization
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep location services
-keep class com.google.android.gms.location.** { *; }

# Keep camera and image picker
-keep class androidx.camera.** { *; }

# Keep notification classes
-keep class com.google.firebase.messaging.** { *; }

# Optimize but don't obfuscate for debugging
-dontobfuscate
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-allowaccessmodification

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}