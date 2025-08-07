package com.example.medicine // Replace with your actual package name

   import io.flutter.embedding.android.FlutterActivity
   import io.flutter.embedding.engine.FlutterEngine
   import io.flutter.plugin.common.MethodChannel
   import android.content.Intent
   import android.os.Bundle
   import android.provider.Settings
   import androidx.core.app.ActivityCompat

   class MainActivity: FlutterActivity() {
       private val CHANNEL = "com.example.medicine/battery_optimization"

       override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
           super.configureFlutterEngine(flutterEngine)
           MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
               if (call.method == "requestIgnoreBatteryOptimizations") {
                   val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                       data = android.net.Uri.parse("package:$packageName")
                   }
                   startActivity(intent)
                   result.success(true)
               } else {
                   result.notImplemented()
               }
           }
       }
   }