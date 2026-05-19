# Flutter default ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google ML Kit Text Recognition missing classes rules
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**

# Google Play Core Split Install missing classes rules (Deferred Components)
-dontwarn com.google.android.play.core.**
