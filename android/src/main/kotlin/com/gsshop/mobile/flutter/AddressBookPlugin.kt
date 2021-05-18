package com.gsshop.mobile.flutter

import androidx.annotation.NonNull

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import android.provider.ContactsContract

import org.json.JSONException
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.ExecutionException

import  android.net.Uri


/** AddressBookPlugin */
class AddressBookPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {

    private var mContext: Context? = null
    private var methodChannel: MethodChannel? = null

    private var currentActivity: Activity? = null
    private lateinit var pendingResult: MethodChannel.Result

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val instance = AddressBookPlugin()
            
            instance.onAttachedToEngine(registrar.context(), registrar.messenger())
            registrar.addActivityResultListener(instance)
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        onAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
    }

    private fun onAttachedToEngine(applicationContext: Context, binaryMessenger: BinaryMessenger) {
        mContext = applicationContext
        methodChannel = MethodChannel(binaryMessenger, "com.gsshop.mobile.flutter.address_book")
        methodChannel?.setMethodCallHandler(this)
    }

    override fun onActivityResult(code: Int, resultCode: Int, data: Intent?): Boolean {
        if (code == 1000){
            var uri = data!!.getData() as Uri

            val cursor = currentActivity!!.getContentResolver().query(
                uri,
                    arrayOf(
                            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                            ContactsContract.CommonDataKinds.Phone.NUMBER
                    ),
                    null,
                    null,
                    null
            )

            if (cursor != null) {
                cursor.moveToFirst()
                var name = cursor.getString(0) as String
                var phoneNumber =  cursor.getString(1) as String

                pendingResult.success(object: HashMap<String, String>() {
                    init {
                        put("name", name)
                        put("phoneNumber", phoneNumber)
                    }
                })
            } else {
                pendingResult.success(null)
            }
            return true
        }
        return false
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when {
            call.method == "openAddressBook" -> {
                try {
                    if (currentActivity != null) {
                        pendingResult = result!!;
                        val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
                        currentActivity!!.startActivityForResult(intent, 1000)
                    }
                } catch(e: Exception) {
                    print(e.localizedMessage)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromActivity() {
    }
  
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        setActivity(binding.getActivity());
    }
  
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        setActivity(binding.getActivity())
        binding.addActivityResultListener(this);
    }
  
    override fun onDetachedFromActivityForConfigChanges() {
        setActivity(null);
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }

    private fun setActivity(activity: Activity?) {
        currentActivity = activity
    }
}