package com.analisismotoresoex.motoresoex

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	companion object {
		private const val TAG = "OexMainActivity"
	}

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		Log.i(TAG, "onCreate: intent.action=${intent?.action}, caller=${callingPackage ?: referrer}")
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
}
