package az.qazan.app

import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.os.Bundle
import android.os.Parcelable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hands a Qazan NFC card to Flutter when Android opens or resumes the app
 * because of it (the NDEF_DISCOVERED filter in the manifest).
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    /** A card read before the Flutter side started listening. */
    private var pending: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "az.qazan/nfc_intent",
        ).also { ch ->
            ch.setMethodCallHandler { call, result ->
                if (call.method == "takeInitial") {
                    result.success(pending)
                    pending = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Stored for takeInitial: Flutter is not listening yet.
        pending = readTag(intent)
        consume()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val tag = readTag(intent) ?: return
        setIntent(intent)
        consume()
        channel?.invokeMethod("onTag", tag) ?: run { pending = tag }
    }

    /** Stops a rotated or recreated activity from replaying the same tap. */
    private fun consume() {
        if (intent?.action == NfcAdapter.ACTION_NDEF_DISCOVERED) {
            intent.action = null
        }
    }

    private fun readTag(intent: Intent?): Map<String, String>? {
        if (intent?.action != NfcAdapter.ACTION_NDEF_DISCOVERED) return null
        @Suppress("DEPRECATION")
        val raw: Array<Parcelable> =
            intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES) ?: return null
        val token = raw.filterIsInstance<NdefMessage>()
            .flatMap { it.records.asList() }
            .firstOrNull { String(it.type, Charsets.UTF_8) == TAG_TYPE }
            ?.let { String(it.payload, Charsets.UTF_8).trim() }
            ?.takeIf { it.isNotEmpty() }
            ?: return null
        val uid = intent.getByteArrayExtra(NfcAdapter.EXTRA_ID)
            ?.joinToString("") { "%02X".format(it) }
            .orEmpty()
        return mapOf("token" to token, "uid" to uid)
    }

    private companion object {
        const val TAG_TYPE = "qazan.az:tag"
    }
}
