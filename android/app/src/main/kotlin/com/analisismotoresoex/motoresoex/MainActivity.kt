package com.analisismotoresoex.motoresoex

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
