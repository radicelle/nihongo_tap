package com.nihongotap.nihongo_tap

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nihongo_tap/updater")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAppVersion" -> {
                        try {
                            val info = packageManager.getPackageInfo(packageName, 0)
                            val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                info.longVersionCode
                            } else {
                                @Suppress("DEPRECATION")
                                info.versionCode.toLong()
                            }
                            result.success(
                                mapOf(
                                    "versionName" to (info.versionName ?: ""),
                                    "versionCode" to versionCode.toInt()
                                )
                            )
                        } catch (_: Exception) {
                            result.success(null)
                        }
                    }

                    "openUrl" -> {
                        val url = call.arguments as? String
                        if (url.isNullOrBlank()) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
