package co.peerbridge.investor.app

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.Intent
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import android.util.Log
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

import co.peerbridge.investor.app.BuildConfig

import com.google.firebase.FirebaseApp
import com.salesforce.marketingcloud.MarketingCloudSdk
import com.salesforce.marketingcloud.MCLogListener
import com.salesforce.marketingcloud.MarketingCloudConfig
import com.salesforce.marketingcloud.notifications.NotificationCustomizationOptions
import com.salesforce.marketingcloud.sfmcsdk.InitializationStatus
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdk
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdkModuleConfig
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.Permission
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    private var pendingPick: MethodChannel.Result? = null

    private val pickFileLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            val pending = pendingPick
            pendingPick = null
            if (pending == null) return@registerForActivityResult
            val uri = result.data?.data
            if (result.resultCode != Activity.RESULT_OK || uri == null) {
                pending.success(null)
                return@registerForActivityResult
            }
            try {
                pending.success(readPickedFile(uri))
            } catch (error: IllegalArgumentException) {
                pending.error("too_large", "Choose a file up to 2 MB.", null)
            } catch (error: Exception) {
                pending.error("pick_failed", "Could not read the selected file.", null)
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)


        if((ContextCompat.checkSelfPermission(this,Manifest.permission.READ_PHONE_STATE)!=PERMISSION_GRANTED))
        {
            ActivityCompat.requestPermissions(this, listOf(Manifest.permission.READ_PHONE_STATE).toTypedArray(),12);
        }

        //initializing firebase app

        FirebaseApp.initializeApp(this);


        //set loggin in debig level
        if(BuildConfig.DEBUG) {
            MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE)
            MarketingCloudSdk.setLogListener(MCLogListener.AndroidLogListener())
        }

        SFMCSdk.configure(applicationContext as Application, SFMCSdkModuleConfig.build {
            pushModuleConfig = MarketingCloudConfig.builder().apply {
                setApplicationId("4802ce88-90b6-4650-b601-5ddc6c551b98")
                setAccessToken("9s09xDWfePVBkc90fz8yrmXC")
                setSenderId("519669153883")
                setMarketingCloudServerUrl("https://mcnr5zh6qqbhr01jtprndxb74nry.device.marketingcloudapis.com/")
                setMid("526001950")
                setNotificationCustomizationOptions(
                        NotificationCustomizationOptions.create(R.mipmap.ic_launcher)
                )
                setDelayRegistrationUntilContactKeyIsSet(true)
            }.build(applicationContext)
        }) {

            when(it.status) {
                InitializationStatus.SUCCESS -> {
                    Log.v("PeerBridge", "Marketing Cloud init was successful")
                    println("syccess>>>>>>>>>>>>>>>>>>>>>>>>")
                }
                InitializationStatus.FAILURE -> {
                    Log.e("PeerBridge", "Marketing Cloud failed to initialize.")

                    println("failed to initilized");
                }
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sfmc_flutter").setMethodCallHandler { call, result ->

            handle(call, result);
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "peerbridge/files").setMethodCallHandler { call, result ->
            if (call.method != "pickFile") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingPick != null) {
                result.error("already_active", "File picker is already open.", null)
                return@setMethodCallHandler
            }
            pendingPick = result
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "*/*"
                putExtra(
                    Intent.EXTRA_MIME_TYPES,
                    arrayOf("application/pdf", "image/jpeg", "image/png")
                )
            }
            try {
                pickFileLauncher.launch(intent)
            } catch (error: Exception) {
                pendingPick = null
                result.error("pick_failed", "Could not open the file picker.", null)
            }
        }
    }

    private fun readPickedFile(uri: Uri): HashMap<String, Any> {
        var name = "certificate"
        contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE),
            null,
            null,
            null
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0) {
                    name = cursor.getString(nameIndex) ?: name
                }
                val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
                if (sizeIndex >= 0 && !cursor.isNull(sizeIndex) &&
                    cursor.getLong(sizeIndex) > 2L * 1024 * 1024
                ) {
                    throw IllegalArgumentException("too_large")
                }
            }
        }
        val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() }
            ?: throw IllegalStateException("empty")
        if (bytes.isEmpty() || bytes.size > 2 * 1024 * 1024) {
            throw IllegalArgumentException("too_large")
        }
        return hashMapOf("name" to name, "bytes" to bytes, "size" to bytes.size)
    }

    fun handle(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        if (call.method == "setContactKey") {
            val cKey = call.argument<String>("cId")
            if (cKey == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(setContactKey(cKey))
        } else if (call.method == "setTag") {

            val tag = call.argument<String>("tag")
            if (tag == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(setTag(tag))
        } else if (call.method == "removeTag") {
            val tag = call.argument<String>("tag")
            if (tag == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(removeTag(tag))
        } else if (call.method == "setAttribute") {
            val attrName = call.argument<String>("name")
            val attrValue = call.argument<String>("value")
            if (attrName == null || attrValue == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
                return
            }
            result.success(setAttribute(attrName, attrValue))
        } else if (call.method == "clearAttribute") {
            val attrName = call.argument<String>("name")
            if (attrName == null) {
                result.error("ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED", "ARGS_NOT_ALLOWED");
            }
            result.success(attrName?.let { clearAttribute(it) })
        } else if (call.method == "pushEnabled") {
            pushEnabled() { res ->
                result.success(res)
            }
        } else if (call.method == "enablePush") {
            result.success(setPushEnabled(true))
        } else if (call.method == "disablePush") {
            result.success(setPushEnabled(false))
        } else if (call.method == "sdkState") {
            getSDKState() { res ->
                result.success(res)
            }
        } else if (call.method == "enableVerbose") {
            result.success(setupVerbose(true))
        } else if (call.method == "disableVerbose") {
            result.success(setupVerbose(false))
        } else {
            result.notImplemented()
        }
    }


    fun setContactKey(contactKey: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->
            val registrationManager = sdk.registrationManager
            registrationManager.edit().run {
                setContactKey(contactKey)
                commit()
            }
        }
        return true
    }

    /*
     * Attribute Management
     */
    fun setAttribute(name: String, value: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->
            sdk.registrationManager.edit().run {
                // Set Attribute value
                setAttribute(name, value)
                commit()
            }
        }
        return true
    }

    fun clearAttribute(name: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->
            sdk.registrationManager.edit().run {
                clearAttribute(name)
                commit()
            }
        }
        return true
    }

    fun attributes(): Array<String> {
        return emptyArray<String>()
    }

    /*
     * TAG Management
     */
    fun setTag(tag: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->

            sdk.registrationManager.edit().run {
                addTags(tag)
                commit()
            }
        }
        return true
    }

    fun removeTag(tag: String): Boolean {
        MarketingCloudSdk.requestSdk { sdk ->
            sdk.registrationManager.edit().run {
                removeTags(tag)
                commit()
            }
        }
        return true
    }

    /*
     * Verbose Management
     */
    fun setupVerbose(status: Boolean): Boolean {
        if (status) {
            MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE)
            MarketingCloudSdk.setLogListener(MCLogListener.AndroidLogListener())
        } else {
            MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE)
            MarketingCloudSdk.setLogListener(MCLogListener.AndroidLogListener())
        }
        return true
    }

    /*
     * Verbose Management
     */
    fun pushEnabled(result: (Any?) -> Unit) {
        MarketingCloudSdk.requestSdk { sdk ->
            result.invoke(sdk.pushMessageManager.isPushEnabled())
        }
    }

    fun setPushEnabled(status: Boolean): Boolean {
        if (status) {
            MarketingCloudSdk.requestSdk { sdk -> sdk.pushMessageManager.enablePush() }
        } else {
            MarketingCloudSdk.requestSdk { sdk -> sdk.pushMessageManager.disablePush() }
        }
        return true
    }

    /*
     * SDKState Management
     */
    fun getSDKState(result: (Any?) -> Unit) {
        MarketingCloudSdk.requestSdk { sdk ->
            result.invoke(sdk.sdkState.toString())
        }
    }

}
