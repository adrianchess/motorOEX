package com.analisismotoresoex.motoresoex

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		enableAndroid15EdgeToEdge()
	}

	override fun onPostResume() {
		super.onPostResume()
		enableAndroid15EdgeToEdge()
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"motor_oex/oex",
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"getEngineStatus" -> result.success(OexEngineRegistry.status(this))
				else -> result.notImplemented()
			}
		}
	}

	private fun enableAndroid15EdgeToEdge() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
			window.setDecorFitsSystemWindows(false)
		}

		if (Build.VERSION.SDK_INT >= 35) {
			val attributes = window.attributes
			attributes.layoutInDisplayCutoutMode =
				WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
			window.attributes = attributes
		}
	}
}
