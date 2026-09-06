package com.chevere.plan

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Chooser nativo: solo **Google Maps · Waze · Uber** (sin otras apps por ahora).
 * Importancia: Maps (primario) → Waze → Uber ([Intent.EXTRA_INITIAL_INTENTS]).
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.chevere.plan/navigation"
    private val mapsPackage = "com.google.android.apps.maps"
    private val wazePackage = "com.waze"
    private val uberPackage = "com.ubercab"

    override fun onCreate(savedInstanceState: Bundle?) {
        // API moderna (Android 12+) + backport: evita pantalla negra / flash del template viejo.
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "openChooser") {
                    try {
                        val googleMapsUri = call.argument<String>("googleMapsUri")
                        val wazeUri = call.argument<String>("wazeUri")
        if (googleMapsUri == null || wazeUri == null) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val uber = call.argument<String>("uberUri")
                            ?.takeIf { it.isNotBlank() }
                            ?: "https://m.uber.com/ul/?action=setPickup&pickup=my_location"
                        result.success(
                            openNativeChooser(
                                title = call.argument<String>("title") ?: "Abrir con",
                                googleMapsUri = googleMapsUri,
                                wazeUri = wazeUri,
                                uberUri = uber,
                            ),
                        )
                    } catch (e: Exception) {
                        result.error("LAUNCH", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun openNativeChooser(
        title: String,
        googleMapsUri: String,
        wazeUri: String,
        uberUri: String,
    ): Boolean {
        val ranked = ArrayList<Intent>()
        if (isInstalled(mapsPackage)) {
            ranked.add(packagedView(googleMapsUri, mapsPackage))
        }
        if (isInstalled(wazePackage)) {
            ranked.add(packagedView(wazeUri, wazePackage))
        }
        if (isInstalled(uberPackage)) {
            ranked.add(packagedView(uberUri, uberPackage))
        }
        if (ranked.isEmpty()) return false
        if (ranked.size == 1) {
            startActivity(ranked[0])
            return true
        }
        val primary = ranked[0]
        val rest = ranked.subList(1, ranked.size).toTypedArray()
        val chooser = Intent.createChooser(primary, title).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra(Intent.EXTRA_INITIAL_INTENTS, rest)
        }
        startActivity(chooser)
        return true
    }

    private fun packagedView(uri: String, packageName: String): Intent {
        return Intent(Intent.ACTION_VIEW, Uri.parse(uri)).apply {
            setPackage(packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    }

    private fun isInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }
}
