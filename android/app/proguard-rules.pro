# ── Flutter ───────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Supabase / Realtime / Postgrest ──────────────────────────
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── OkHttp (used by Supabase under the hood) ─────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ── Kotlin Coroutines ─────────────────────────────────────────
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# ── Kotlin Serialization ──────────────────────────────────────
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# ── JWT / jose4j ──────────────────────────────────────────────
-keep class org.jose4j.** { *; }
-dontwarn org.jose4j.**

# ── Conscrypt (TLS on older Android) ─────────────────────────
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# ── Prevent stripping of generic type info ────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ── Gson (used internally by some packages) ──────────────────
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*