# Flutter wrapper rules
-keep class io.flutter.** { *; }

# Zego Cloud SDK & UIKit
-keep class com.zego.** { *; }
-keep class im.zego.** { *; }
-keep class com.zegocloud.** { *; }
-dontwarn com.zego.**
-dontwarn im.zego.**
-dontwarn com.zegocloud.**

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Supabase & Serialization
-keepattributes *Annotation*, EnclosingMethod, Signature, InnerClasses
-dontwarn io.github.jan.supabase.**

# Desugaring
-keep class j$.** { *; }
